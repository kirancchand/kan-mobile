import 'kerala_state_map.dart';
import 'kerala_district_map.dart';
import '../../data/models/admin_hierarchy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/location_map.dart';
import '../../data/models/map_location.dart';
import '../../data/models/state_geometry.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/services/kan_master_api.dart';
import '../../state/admin_state.dart';
import 'admin_directory_screen.dart';

class AdminMapScreen extends StatefulWidget {
  const AdminMapScreen({super.key, required this.targetId, this.tileProvider});
  final String targetId;
  final TileProvider? tileProvider;

  @override
  State<AdminMapScreen> createState() => _AdminMapScreenState();
}

class _AdminMapScreenState extends State<AdminMapScreen> {
  bool _users = true;
  bool _businesses = true;
  bool _districtAreas = true;
  late final KanMasterApi _areaApi;
  AreaListPage? _areaPage;
  int _areaPageNumber = 0;
  bool _areasLoading = false;
  String? _areasError;
  Map<String, StateGeometry>? _selectedAreaBranches;
  String? _selectedAreaName;
  String? _selectedAreaId;
  bool _branchesLoading = false;
  String? _branchesError;
  Map<String, StateGeometry>? _areaBranchGeometry;
  bool _areaBranchGeometryLoading = false;
  String? _areaBranchGeometryError;

  /// Draws every branch of an API area from getBranchGeoByAreaId, or a single
  /// API branch from getBranchGeoById.
  Future<void> _loadAreaBranchGeometry() async {
    final token = context.read<AuthRepository?>()?.tokens?.accessToken;
    final account =
        context.read<AdminRepository>().accountById(widget.targetId);
    final areaId = account.masterAreaId;
    final branchId = account.masterBranchId;
    if (areaId == null && branchId == null) return;
    if (token == null || token.isEmpty) {
      setState(() => _areaBranchGeometryError =
          'Sign in with backend credentials to load branches.');
      return;
    }
    setState(() {
      _areaBranchGeometryLoading = true;
      _areaBranchGeometryError = null;
    });
    try {
      final branches = branchId != null
          ? await _areaApi.getBranchGeometryById(
              accessToken: token, branchId: branchId)
          : await _areaApi.getBranchGeometryByAreaId(
              accessToken: token, areaId: areaId!);
      if (mounted) setState(() => _areaBranchGeometry = branches);
    } catch (error) {
      if (mounted) {
        setState(() => _areaBranchGeometryError = error is StateError
            ? error.message.toString()
            : 'Could not load branch boundaries.');
      }
    } finally {
      if (mounted) setState(() => _areaBranchGeometryLoading = false);
    }
  }

  Future<void> _loadAreas({int? page}) async {
    final token = context.read<AuthRepository?>()?.tokens?.accessToken;
    final districtAccount =
        context.read<AdminRepository>().accountById(widget.targetId);
    final districtId = districtAccount.masterDistrictId ??
        (int.tryParse(widget.targetId) == null ? null : widget.targetId);
    if (token == null || token.isEmpty || districtId == null) {
      setState(() =>
          _areasError = 'Sign in with backend credentials to load areas.');
      return;
    }
    final requestedPage = page ?? _areaPageNumber;
    setState(() {
      _areasLoading = true;
      _areasError = null;
    });
    try {
      final result = await _areaApi.listAreas(
        accessToken: token,
        districtId: districtId,
        page: requestedPage,
        pageSize: 1000000,
      );
      if (!mounted) return;
      setState(() {
        _areaPage = result;
        _areaPageNumber = requestedPage;
      });
    } catch (error) {
      if (mounted)
        setState(() => _areasError = error is StateError
            ? error.message.toString()
            : 'Could not load district areas.');
    } finally {
      if (mounted) setState(() => _areasLoading = false);
    }
  }

  Future<void> _loadBranchesForArea(AreaListItem area) async {
    final token = context.read<AuthRepository?>()?.tokens?.accessToken;
    if (token == null || token.isEmpty) {
      setState(() => _branchesError =
          'Sign in with backend credentials to load branches.');
      return;
    }
    setState(() {
      _selectedAreaId = area.id;
      _selectedAreaName = area.name;
      _selectedAreaBranches = null;
      _branchesLoading = true;
      _branchesError = null;
    });
    try {
      final branches = await _areaApi.getBranchGeometryByAreaId(
          accessToken: token, areaId: area.id);
      if (mounted && _selectedAreaId == area.id) {
        setState(() => _selectedAreaBranches = branches);
      }
    } catch (error) {
      if (mounted && _selectedAreaId == area.id) {
        setState(() => _branchesError = error is StateError
            ? error.message.toString()
            : 'Could not load branches for ${area.name}.');
      }
    } finally {
      if (mounted && _selectedAreaId == area.id) {
        setState(() => _branchesLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _areaApi.dispose();
    super.dispose();
  }

  bool _loadingChildren = false;
  String? _childrenError;

  @override
  void initState() {
    super.initState();
    _areaApi = KanMasterApi(authRepository: context.read<AuthRepository?>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadChildren();
      final account =
          context.read<AdminRepository>().accountById(widget.targetId);
      if (account.level == AdminLevel.district) _loadAreas(page: 0);
      if (account.level == AdminLevel.area ||
          account.level == AdminLevel.branch) {
        _loadAreaBranchGeometry();
      }
    });
  }

  Future<void> _loadChildren() async {
    final repo = context.read<AdminRepository>();
    final viewer = context.read<AdminState>().account;
    final token = context.read<AuthRepository?>()?.tokens?.accessToken;
    if (viewer == null ||
        token == null ||
        !repo.canView(viewer.id, widget.targetId)) {
      return;
    }
    final overview =
        repo.getOverview(viewerId: viewer.id, targetId: widget.targetId);
    final isApiArea = overview.account.level == AdminLevel.area &&
        overview.account.masterAreaId != null;
    if ((overview.account.level != AdminLevel.main &&
            overview.account.level != AdminLevel.state &&
            !isApiArea) ||
        overview.children.any((child) => !child.isDemo)) {
      return;
    }
    setState(() {
      _loadingChildren = true;
      _childrenError = null;
    });
    try {
      if (overview.account.level == AdminLevel.main) {
        await repo.loadStatesForMain(
            mainAccountId: widget.targetId, accessToken: token);
      } else if (overview.account.level == AdminLevel.state) {
        await repo.loadDistrictsForState(
            stateAccountId: widget.targetId, accessToken: token);
      } else {
        await repo.loadBranchesForArea(
            areaAccountId: widget.targetId, accessToken: token);
      }
    } catch (_) {
      if (mounted) _childrenError = 'Could not load subadmin territories.';
    } finally {
      if (mounted) setState(() => _loadingChildren = false);
    }
  }

  void _open(String id) => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdminMapScreen(targetId: id, tileProvider: widget.tileProvider),
      ));

  void _details(String name, String details) => showModalBottomSheet<void>(
        context: context,
        builder: (_) => SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                Text(details),
              ]),
        )),
      );

  @override
  Widget build(BuildContext context) {
    final viewer = context.watch<AdminState>().account;
    final repo = context.read<AdminRepository>();
    if (viewer == null || !repo.canView(viewer.id, widget.targetId)) {
      return Scaffold(
          appBar: AppBar(title: const Text('Territory map')),
          body: const Center(
              child: Text('Sign in with an authorised admin account.')));
    }
    return ListenableBuilder(
      listenable: Listenable.merge([
        context.read<AuthRepository?>()?.changes,
        context.read<HomeRepository?>()?.changes,
      ]),
      builder: (context, _) {
        final overview =
            repo.getOverview(viewerId: viewer.id, targetId: widget.targetId);
        final users =
            repo.getUsers(viewerId: viewer.id, targetId: widget.targetId);
        final businesses = overview.businesses;
        final boundary =
            repo.getBoundary(viewerId: viewer.id, targetId: widget.targetId);
        final children = {
          for (final child in overview.children)
            child: repo.getBoundary(viewerId: viewer.id, targetId: child.id),
        };
        final territoryActions = <String, VoidCallback>{};
        // Prefer the API account when a demo territory has the same name.
        for (final demo in [true, false]) {
          for (final child
              in overview.children.where((child) => child.isDemo == demo)) {
            territoryActions[child.territory.trim().toLowerCase()] =
                () => _open(child.id);
          }
        }
        final childBoundaries = [
          for (final entry in children.entries)
            if (entry.value.isNotEmpty)
              MapBoundary(
                  points: entry.value,
                  label: entry.key.territory,
                  color: Colors.purple,
                  onTap: () => _open(entry.key.id)),
        ];
        final missing =
            (_users ? users.where((u) => u.mapLocation == null).length : 0) +
                (_businesses
                    ? businesses.where((b) => b.mapLocation == null).length
                    : 0);
        final isMain = overview.account.level == AdminLevel.main;
        final isState = overview.account.level == AdminLevel.state;
        final isRealState = isState &&
            !overview.account.isDemo &&
            overview.account.masterStateId != null;
        final isRealDistrict = overview.account.level == AdminLevel.district &&
            !overview.account.isDemo &&
            overview.account.masterDistrictId != null;
        final isDistrictAdmin = overview.account.level == AdminLevel.district;
        final isRealBranch = overview.account.level == AdminLevel.branch &&
            overview.account.masterBranchId != null;
        final isRealArea = isRealBranch ||
            overview.account.level == AdminLevel.area &&
                overview.account.masterAreaId != null;
        final isKeralaDistrict =
            overview.account.level == AdminLevel.district &&
                overview.account.parentId != null &&
                repo
                        .accountById(overview.account.parentId!)
                        .territory
                        .toLowerCase() ==
                    'kerala';
        final pins = <MapPin>[
          if (_users)
            for (final user in users)
              if (user.mapLocation != null)
                MapPin(user.mapLocation!, user.name, Colors.blue,
                    icon: Icons.person_pin_circle,
                    onTap: () => _details(user.name,
                        'User • ${user.userType.label}\nBranch: ${user.branch.territory}\n${user.mapLocation!.coordinates}\n${user.isDemoLocation ? 'Demo location' : 'Saved location'}')),
          if (_businesses)
            for (final business in businesses)
              if (business.mapLocation != null)
                MapPin(business.mapLocation!, business.name, Colors.deepOrange,
                    icon: business.isOrganisation
                        ? Icons.apartment
                        : Icons.storefront,
                    onTap: () => _details(business.name,
                        '${business.category}\nBranch: ${business.branch.territory}\n${business.mapLocation!.coordinates}\n${business.isDemoLocation ? 'Demo location' : 'Saved location'}')),
          for (final entry in children.entries)
            if (entry.value.isNotEmpty)
              MapPin(entry.value.first, 'Open ${entry.key.territory}',
                  Colors.purple,
                  icon: Icons.account_tree, onTap: () => _open(entry.key.id)),
        ];
        return Scaffold(
          appBar: AppBar(title: Text('${overview.account.territory} map')),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Text(overview.account.level.label,
                style: Theme.of(context).textTheme.titleLarge),
            if (!isMain &&
                !isState &&
                !isKeralaDistrict &&
                !isRealDistrict &&
                !isRealArea)
              const Text(
                  'No boundary data is available. Only saved locations are shown.'),
            Wrap(spacing: 8, children: [
              FilterChip(
                  label: const Text('Users'),
                  avatar: const Icon(Icons.person, color: Colors.blue),
                  selected: _users,
                  onSelected: (value) => setState(() => _users = value)),
              FilterChip(
                  label: const Text('Businesses & organisations'),
                  avatar:
                      const Icon(Icons.storefront, color: Colors.deepOrange),
                  selected: _businesses,
                  onSelected: (value) => setState(() => _businesses = value)),
            ]),
            if (isRealState)
              KeralaDistrictMap(
                stateId: overview.account.masterStateId!,
                territoryActions: territoryActions,
                stateName: overview.account.territory,
                accessToken:
                    context.read<AuthRepository?>()?.tokens?.accessToken,
                pins: pins,
                tileProvider: widget.tileProvider,
              )
            else if (isMain || isState)
              KeralaStateMap(
                allStates: isMain,
                territoryActions: isMain ? territoryActions : const {},
                childBoundaries: isMain ? const [] : childBoundaries,
                stateName: overview.account.territory,
                accessToken:
                    context.read<AuthRepository?>()?.tokens?.accessToken,
                pins: pins,
                tileProvider: widget.tileProvider,
              )
            else if (isRealDistrict)
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (_areaPage == null && !_areasLoading && _areasError == null)
                  Builder(builder: (context) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && _areaPage == null && !_areasLoading) {
                        _loadAreas(page: 0);
                      }
                    });
                    return const SizedBox.shrink();
                  }),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('District areas')),
                    ButtonSegment(value: false, label: Text('Current map')),
                  ],
                  selected: {_districtAreas},
                  onSelectionChanged: (selection) =>
                      setState(() => _districtAreas = selection.first),
                ),
                KeralaDistrictMap(
                  districtId: overview.account.masterDistrictId!,
                  showAreas: _districtAreas,
                  childBoundaries: childBoundaries,
                  districtName: overview.account.territory,
                  stateName:
                      repo.accountById(overview.account.parentId!).territory,
                  accessToken:
                      context.read<AuthRepository?>()?.tokens?.accessToken,
                  pins: pins,
                  tileProvider: widget.tileProvider,
                )
              ])
            else if (isRealArea)
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (_areaBranchGeometryLoading) const LinearProgressIndicator(),
                if (_areaBranchGeometryError != null)
                  Row(children: [
                    Expanded(child: Text(_areaBranchGeometryError!)),
                    IconButton(
                        tooltip: 'Retry branch boundaries',
                        onPressed: _loadAreaBranchGeometry,
                        icon: const Icon(Icons.refresh)),
                  ]),
                LocationMap(
                  tileProvider: widget.tileProvider,
                  pins: pins,
                  boundaries: [
                    for (final branch in _areaBranchGeometry?.values ??
                        const <StateGeometry>[])
                      for (final polygon in branch.polygons)
                        MapBoundary(
                          points: polygon.outer,
                          holes: polygon.holes,
                          label: branch.name,
                          color: Colors.deepOrange,
                          onTap: territoryActions[
                              branch.name.trim().toLowerCase()],
                        ),
                  ],
                ),
                if (_areaBranchGeometry != null && _areaBranchGeometry!.isEmpty)
                  const Text('No branch boundaries returned for this area.'),
              ])
            else if (isKeralaDistrict)
              KeralaDistrictMap(
                childBoundaries: childBoundaries,
                accessToken:
                    context.read<AuthRepository?>()?.tokens?.accessToken,
                pins: pins,
                tileProvider: widget.tileProvider,
              )
            else
              LocationMap(
                tileProvider: widget.tileProvider,
                pins: pins,
                boundaries: [
                  if (boundary.isNotEmpty)
                    MapBoundary(
                        points: boundary,
                        label: overview.account.territory,
                        color: Colors.teal),
                  ...childBoundaries,
                ],
              ),
            if (overview.children.isNotEmpty)
              const Text(
                  'Tap a subadmin territory on the map or select it below to explore the next level.'),
            Text(isRealBranch
                ? 'Orange: branch API boundary for this territory.'
                : isRealArea
                    ? 'Orange: branch API boundaries for this area. Tap a branch to explore it.'
                    : isRealDistrict
                        ? 'Indigo: district API boundary for this territory.'
                        : isRealState
                            ? 'Indigo: district API boundaries for this state. Select a territory below to explore it.'
                            : isMain || isState
                                ? 'Teal: state API boundaries. Only saved locations are shown. Select a territory below to explore it.'
                                : 'Teal: current territory • Purple: subadmin boundaries. Tap a purple hierarchy pin or a territory below to explore it. Tap a user or business pin for details.'),
            if (!isMain &&
                !isState &&
                !isKeralaDistrict &&
                !isRealDistrict &&
                !isRealArea &&
                boundary.isEmpty)
              const Text('Boundary unavailable for this territory.'),
            if (!_users && !_businesses)
              const Text(
                  'Select Users or Businesses & organisations to show record locations.'),
            if (users.isEmpty && businesses.isEmpty)
              const Text('No users or businesses in this territory yet.'),
            if (missing > 0) Text('$missing records have no saved location.'),
            Wrap(spacing: 8, children: [
              for (final businessList in [false, true])
                TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminDirectoryScreen(
                              targetId: widget.targetId,
                              businesses: businessList),
                        )),
                    child: Text(businessList
                        ? 'View all businesses'
                        : 'View all users')),
            ]),
            if (_loadingChildren) const LinearProgressIndicator(),
            if (_childrenError != null) ...[
              Text(_childrenError!),
              TextButton(
                  onPressed: _loadChildren,
                  child: const Text('Retry subadmins')),
            ],
            Text('View by hierarchy',
                style: Theme.of(context).textTheme.titleLarge),
            if (isDistrictAdmin &&
                _areaPage == null &&
                !_areasLoading &&
                _areasError == null)
              Builder(builder: (context) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _areaPage == null && !_areasLoading) {
                    _loadAreas(page: 0);
                  }
                });
                return const SizedBox.shrink();
              }),
            if (overview.children.isEmpty && !isDistrictAdmin)
              Text(overview.account.level == AdminLevel.branch
                  ? 'Branch level — no lower hierarchy.'
                  : 'No subadmin territories configured yet.'),
            // District areas are listed below with their branch drill-down.
            for (final child in overview.children)
              if (!isDistrictAdmin || child.level != AdminLevel.area)
                ListTile(
                    key: ValueKey('map-hierarchy-${child.id}'),
                    title: Text('${child.level.label} • ${child.territory}'),
                    subtitle:
                        Text('${child.name}${child.isDemo ? ' • Dummy' : ''}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(child.id)),
            if (isDistrictAdmin) ...[
              Text(
                  'Subadmins (${_areaPage == null ? (_areasLoading ? 'Loading…' : '—') : _areaPage!.items.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              if (_areasLoading) const LinearProgressIndicator(),
              if (_areasError != null)
                Row(children: [
                  Expanded(child: Text(_areasError!)),
                  IconButton(
                      tooltip: 'Retry areas',
                      onPressed: () => _loadAreas(),
                      icon: const Icon(Icons.refresh)),
                ]),
              for (final area in _areaPage?.items ?? const <AreaListItem>[])
                ListTile(
                  key: ValueKey('map-district-area-${area.id}'),
                  leading: const Icon(Icons.location_city, color: Colors.teal),
                  title: Text('Subadmin • ${area.name}'),
                  subtitle: const Text('District area'),
                  selected: _selectedAreaId == area.id,
                  onTap: () => _loadBranchesForArea(area),
                ),
              if (_selectedAreaName != null) ...[
                Text('Branches in $_selectedAreaName',
                    style: Theme.of(context).textTheme.titleMedium),
                if (_branchesLoading) const LinearProgressIndicator(),
                if (_branchesError != null) Text(_branchesError!),
                if (_selectedAreaBranches != null)
                  LocationMap(
                    tileProvider: widget.tileProvider,
                    pins: const [],
                    boundaries: [
                      for (final branch in _selectedAreaBranches!.values)
                        for (final polygon in branch.polygons)
                          MapBoundary(
                            points: polygon.outer,
                            holes: polygon.holes,
                            label: branch.name,
                            color: Colors.deepOrange,
                          ),
                    ],
                  ),
              ],
              if (_areaPage != null && _areaPage!.items.isEmpty)
                const Text('No areas are configured for this district.'),
            ],
            Text('Locations in this territory',
                style: Theme.of(context).textTheme.titleLarge),
            if (_users)
              for (final user in users)
                _record(user.name, 'User • ${user.branch.territory}',
                    user.mapLocation, user.isDemoLocation),
            if (_businesses)
              for (final business in businesses)
                _record(
                    business.name,
                    '${business.category} • ${business.branch.territory}',
                    business.mapLocation,
                    business.isDemoLocation),
          ]),
        );
      },
    );
  }

  Widget _record(String name, String details, MapLocation? point, bool demo) =>
      ListTile(
        title: Text(name),
        subtitle: Text(
            '$details\n${point == null ? 'Location not set' : '${point.coordinates} • ${demo ? 'Demo location' : 'Saved location'}'}'),
        onTap: () =>
            _details(name, '$details\n${point?.label ?? 'Location not set'}'),
      );
}
