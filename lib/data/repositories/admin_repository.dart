import '../models/kan_registration.dart';
import '../models/map_location.dart';
import '../models/admin_hierarchy.dart';
import '../models/admin_models.dart';
import '../models/shop_org.dart';
import 'auth_repository.dart';
import 'home_repository.dart';
import '../models/app_user.dart';
import '../services/kan_master_api.dart';

/// Admin hierarchy loaded from the backend and current registered records.
class AdminRepository {
  AdminRepository(
      {Iterable<AdminAccount> assignedAccounts = const [],
      AuthRepository? authRepository,
      HomeRepository? homeRepository,
      KanMasterApi? masterApi})
      : _assignedAccounts = List.unmodifiable(assignedAccounts),
        _authRepository = authRepository,
        _homeRepository = homeRepository,
        _masterApi = masterApi ?? KanMasterApi(authRepository: authRepository);

  /// Main Admin view opened to every signed-in user from the Admin tab.
  static const everyoneAccount = AdminAccount(
      id: 'main_all_users',
      name: 'Main Administrator',
      level: AdminLevel.main,
      territory: 'All states');

  final List<AdminAccount> _assignedAccounts;
  final AuthRepository? _authRepository;
  final HomeRepository? _homeRepository;
  final KanMasterApi _masterApi;
  final _remoteStates = <String, AdminAccount>{};
  final _remoteDistricts = <String, AdminAccount>{};
  final _remoteAreas = <String, AdminAccount>{};
  final _remoteBranches = <String, AdminAccount>{};

  AdminAccount _requireBranch(String viewerId) {
    final account = accountById(viewerId);
    if (account.level != AdminLevel.branch || account.locationId == null) {
      throw StateError('Sign in as a branch admin to add records.');
    }
    return account;
  }

  Future<AppUser> addUser({
    required String viewerId,
    required String name,
    required String phone,
    required UserType userType,
    KanRegistration? registration,
    MapLocation? mapLocation,
  }) {
    final branch = _requireBranch(viewerId);
    if (name.trim().isEmpty ||
        !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phone.trim())) {
      throw ArgumentError('Enter a name and valid phone number.');
    }
    final auth = _authRepository;
    if (auth == null) throw StateError('User registration is unavailable.');
    return auth.register(
      name: name.trim(),
      phone: phone.trim(),
      locationId: branch.locationId!,
      userType: userType,
      registration: registration,
      mapLocation: mapLocation,
    );
  }

  Future<ShopOrg> addOrganisation({
    required String viewerId,
    required String name,
    required String phone,
    required String address,
    required String timings,
    required ShopCategory category,
    MapLocation? mapLocation,
  }) {
    final branch = _requireBranch(viewerId);
    final home = _homeRepository;
    if (home == null) {
      throw StateError('Organisation registration is unavailable.');
    }
    return home.addOrganisation(
      name: name,
      phone: phone,
      address: address,
      timings: timings,
      category: category,
      mapLocation: mapLocation,
      ownerId: branch.id,
      locationId: branch.locationId!,
    );
  }

  /// Returns residents only after checking the viewer's reporting hierarchy.
  List<AdminResident> getUsers({
    required String viewerId,
    required String targetId,
  }) {
    if (!canView(viewerId, targetId)) {
      throw StateError('This admin is outside your assigned hierarchy.');
    }
    final users = <AdminResident>[];
    for (final branch in accounts.where((account) =>
        account.level == AdminLevel.branch && canView(targetId, account.id))) {
      for (final user in _authRepository?.registeredUsers ?? []) {
        if (user.locationId != branch.locationId) continue;
        users.add(AdminResident(
          id: user.id,
          name: user.name,
          phone: user.phone,
          userType: user.userType,
          mapLocation: user.mapLocation,
          branch: branch,
        ));
      }
    }
    users.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return List.unmodifiable(users);
  }

  /// No synthetic boundaries are inferred from record positions.
  List<MapLocation> getBoundary(
      {required String viewerId, required String targetId}) {
    if (!canView(viewerId, targetId)) {
      throw StateError('This admin is outside your assigned hierarchy.');
    }
    return const [];
  }

  // Lookup caches. Every change to the remote maps must call [_invalidate];
  // rebuilding these on each lookup froze large district pages.
  List<AdminAccount>? _accountsCache;
  Map<String, AdminAccount>? _byIdCache;
  Map<String, List<AdminAccount>>? _childrenCache;

  void _invalidate() {
    _accountsCache = null;
    _byIdCache = null;
    _childrenCache = null;
  }

  List<AdminAccount> get accounts => _accountsCache ??= List.unmodifiable([
        ..._assignedAccounts,
        ..._remoteStates.values,
        ..._remoteDistricts.values,
        ..._remoteAreas.values,
        ..._remoteBranches.values
      ]);

  Map<String, AdminAccount> get _byId => _byIdCache ??= () {
        final byId = <String, AdminAccount>{};
        for (final account in accounts) {
          byId.putIfAbsent(account.id, () => account);
        }
        return byId;
      }();

  Map<String, List<AdminAccount>> get _childrenById => _childrenCache ??= () {
        final children = <String, List<AdminAccount>>{};
        for (final account in accounts) {
          final parentId = account.parentId;
          if (parentId != null) {
            (children[parentId] ??= []).add(account);
          }
        }
        return children;
      }();

  /// Loads state territories from the API.
  Future<void> loadStatesForMain(
      {required String mainAccountId, required String accessToken}) async {
    if (accountById(mainAccountId).level != AdminLevel.main) {
      throw StateError('State lookup requires a main admin.');
    }
    final states = await _masterApi.getStates(accessToken: accessToken);
    final previousIds = _remoteStates.keys.toSet();
    _remoteStates
        .removeWhere((_, account) => account.parentId == mainAccountId);
    for (final state in states) {
      final id = 'state_api_${state.id}';
      _remoteStates[id] = AdminAccount(
          id: id,
          name: '${state.name} State Administrator',
          level: AdminLevel.state,
          territory: state.name,
          parentId: mainAccountId,
          masterStateId: state.id);
    }
    final removed = previousIds.difference(_remoteStates.keys.toSet());
    _remoteDistricts
        .removeWhere((_, account) => removed.contains(account.parentId));
    _invalidate();
    _removeOrphans();
  }

  Future<void> loadDistrictsForState(
      {required String stateAccountId, required String accessToken}) async {
    final state = accountById(stateAccountId);
    if (state.level != AdminLevel.state) {
      throw StateError('District lookup requires a state admin.');
    }
    var stateId = state.masterStateId;
    // Older accounts may have no API ID. Resolve their territory through the
    // state master instead of assuming every state has Kerala's ID.
    if (stateId == null) {
      final states = await _masterApi.getStates(accessToken: accessToken);
      final matches = states.where((option) =>
          option.name.trim().toLowerCase() ==
          state.territory.trim().toLowerCase());
      if (matches.length != 1) {
        throw StateError(
            'Could not identify ${state.territory} in the state master.');
      }
      stateId = matches.single.id;
    }
    final districts = await _masterApi.getDistrictsByState(
        accessToken: accessToken, stateId: stateId);
    _remoteDistricts
        .removeWhere((_, account) => account.parentId == stateAccountId);
    for (final district in districts) {
      final id = '${stateAccountId}_district_api_${district.id}';
      _remoteDistricts[id] = AdminAccount(
        id: id,
        name: '${district.name} District Administrator',
        level: AdminLevel.district,
        territory: district.name,
        masterDistrictId: district.id,
        parentId: stateAccountId,
      );
    }
    _invalidate();
    _removeOrphans();
  }

  /// Loads a district's subadmins from `/master/area/getByDistrict/{id}`.
  Future<void> loadAreasForDistrict(
      {required String districtAccountId, required String accessToken}) async {
    final district = accountById(districtAccountId);
    if (district.level != AdminLevel.district) {
      throw StateError('Area lookup requires a district admin.');
    }
    final districtId = district.masterDistrictId ??
        await _resolveDistrictId(district, accessToken);
    final page = await _masterApi.listAreas(
        accessToken: accessToken,
        districtId: districtId,
        page: 0,
        pageSize: 1000000);
    _remoteAreas
        .removeWhere((_, account) => account.parentId == districtAccountId);
    for (final area in page.items) {
      final id = '${districtAccountId}_area_api_${area.id}';
      _remoteAreas[id] = AdminAccount(
        id: id,
        name: '${area.name} Area Administrator',
        level: AdminLevel.area,
        territory: area.name,
        masterAreaId: area.id,
        parentId: districtAccountId,
      );
    }
    _invalidate();
    _removeOrphans();
  }

  /// Loads an area's branches from `/master/branch/getByArea/{areaId}`.
  Future<void> loadBranchesForArea(
      {required String areaAccountId, required String accessToken}) async {
    final area = accountById(areaAccountId);
    final areaId = area.masterAreaId;
    if (area.level != AdminLevel.area || areaId == null) {
      throw StateError('Branch lookup requires an API area admin.');
    }
    final branches = await _masterApi.getBranchesByArea(
        accessToken: accessToken, areaId: areaId);
    _remoteBranches
        .removeWhere((_, account) => account.parentId == areaAccountId);
    for (final branch in branches) {
      final id = '${areaAccountId}_branch_api_${branch.id}';
      _remoteBranches[id] = AdminAccount(
        id: id,
        name: '${branch.name} Branch Administrator',
        level: AdminLevel.branch,
        territory: branch.name,
        masterBranchId: branch.id,
        parentId: areaAccountId,
      );
    }
    _invalidate();
  }

  /// Drops API accounts whose parent territory was removed by a reload.
  void _removeOrphans() {
    _remoteAreas
        .removeWhere((_, account) => !_byId.containsKey(account.parentId));
    _invalidate();
    _remoteBranches
        .removeWhere((_, account) => !_byId.containsKey(account.parentId));
    _invalidate();
  }

  /// Resolve district accounts without an API ID by name through the
  /// state and district masters.
  Future<String> _resolveDistrictId(
      AdminAccount district, String accessToken) async {
    final state =
        district.parentId == null ? null : accountById(district.parentId!);
    var stateId = state?.masterStateId;
    if (stateId == null && state != null) {
      final states = await _masterApi.getStates(accessToken: accessToken);
      final matches = states.where((option) =>
          option.name.trim().toLowerCase() ==
          state.territory.trim().toLowerCase());
      if (matches.length == 1) stateId = matches.single.id;
    }
    if (stateId != null) {
      final districts = await _masterApi.getDistrictsByState(
          accessToken: accessToken, stateId: stateId);
      final matches = districts.where((option) =>
          option.name.trim().toLowerCase() ==
          district.territory.trim().toLowerCase());
      if (matches.length == 1) return matches.single.id;
    }
    throw StateError(
        'Could not identify ${district.territory} in the district master.');
  }

  AdminAccount accountById(String id) =>
      _byId[id] ?? (throw ArgumentError.value(id, 'id', 'Unknown admin'));

  bool canView(String viewerId, String targetId) {
    accountById(viewerId);
    AdminAccount? current = accountById(targetId);
    while (current != null) {
      if (current.id == viewerId) return true;
      current =
          current.parentId == null ? null : accountById(current.parentId!);
    }
    return false;
  }

  /// Restricts hierarchy data to the signed-in account's subtree.
  /// A future backend must enforce this scope using its authenticated session.
  AdminOverview getOverview(
      {required String viewerId, required String targetId}) {
    if (!canView(viewerId, targetId)) {
      throw StateError('This admin is outside your assigned hierarchy.');
    }
    // Walk only the target's subtree, then keep the original account order.
    final subtree = <String>{};
    final pending = [targetId];
    while (pending.isNotEmpty) {
      final id = pending.removeLast();
      if (!subtree.add(id)) continue;
      pending.addAll((_childrenById[id] ?? const []).map((a) => a.id));
    }
    final descendants =
        accounts.where((a) => subtree.contains(a.id)).toList();
    final branches = descendants.where((a) => a.level == AdminLevel.branch);
    final businesses = <AdminBusiness>[];
    for (final branch in branches) {
      final shops = (_homeRepository?.shops ?? <ShopOrg>[]).where((s) =>
          branch.locationId != null && s.locationId == branch.locationId);
      for (final shop in shops) {
        businesses.add(AdminBusiness(
          name: shop.name,
          category: shop.category.label,
          branch: branch,
          isOrganisation: shop.category == ShopCategory.organization,
          address: shop.address,
          phone: shop.phone,
          mapLocation: shop.mapLocation,
        ));
      }
    }
    return AdminOverview(
      account: accountById(targetId),
      children: List.of(_childrenById[targetId] ?? const <AdminAccount>[]),
      descendantCount: descendants.length - 1,
      locations: const [],
      businesses: businesses,
    );
  }

  Future<List<RegisteredEntity>> getRegisteredEntities(
          String locationId) async =>
      const [];
  Future<List<LocationTransaction>> getTransactions(String locationId) async =>
      const [];
  Future<LocationAnalytics?> getAnalyticsForLocation(String locationId) async =>
      null;
  Future<List<LocationAnalytics>> getAllLocationAnalytics() async => const [];
}
