import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_network_image.dart';
import '../../data/models/shop_org.dart';
import '../../data/models/organisation_content.dart';
import '../../data/repositories/home_repository.dart';
import '../profile/organisation_advertisements_screen.dart';
import '../profile/organisation_members_screen.dart';
import '../profile/organisation_products_screen.dart';
import 'add_organisation_screen.dart';

class OrganisationDetailScreen extends StatelessWidget {
  const OrganisationDetailScreen({super.key, required this.organisation});

  final ShopOrg organisation;

  @override
  Widget build(BuildContext context) {
    final shop = organisation;
    final isBusiness = shop.isBusiness;
    final canManage = shop.canEditOrganisation;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Organisation details'),
          Text(shop.branch, style: Theme.of(context).textTheme.labelSmall),
        ]),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
              children: [
                _profileCard(context, isBusiness, canManage),
                const SizedBox(height: AppSpacing.md),
                _productCatalog(context, canManage),
                const SizedBox(height: AppSpacing.md),
                _advertisements(canManage),
                if (!isBusiness) ...[
                  _committee(context, canManage),
                  const SizedBox(height: AppSpacing.md),
                  _coreAttributes(context),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _profileCard(BuildContext context, bool isBusiness, bool canManage) {
    final colors = Theme.of(context).colorScheme;
    final kind = organisation.organisationType?.isNotEmpty == true
        ? organisation.organisationType!
        : organisation.category.label;
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: organisation.photoUrl?.isNotEmpty == true
                  ? AppNetworkImage(
                      url: organisation.imageUrl,
                      width: 52,
                      height: 52,
                      borderRadius: AppRadius.md)
                  : Container(
                      width: 52,
                      height: 52,
                      color: colors.primaryContainer,
                      child: Icon(
                          isBusiness
                              ? Icons.storefront
                              : Icons.groups_2_outlined,
                          color: colors.primary)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Wrap(spacing: AppSpacing.xs, children: [
                    _pill(
                        context,
                        organisation.status.isEmpty
                            ? 'Active'
                            : organisation.status),
                    _pill(context, kind),
                  ]),
                  const SizedBox(height: AppSpacing.xs),
                  Text(organisation.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  if (organisation.address.isNotEmpty)
                    Text('⌖ ${organisation.address}',
                        style: Theme.of(context).textTheme.bodySmall),
                ])),
            if (canManage)
              IconButton(
                  tooltip: 'Edit details',
                  onPressed: () => _edit(context),
                  icon: const Icon(Icons.edit_outlined)),
          ]),
          const Divider(height: AppSpacing.lg),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: _contactAction(
                context,
                icon: Icons.call_outlined,
                label: 'Call',
                enabled: organisation.phone.isNotEmpty,
                onTap: () => _launchContact(
                  context,
                  Uri(scheme: 'tel', path: organisation.phone.trim()),
                  'Could not open the phone app.',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _contactAction(
                context,
                icon: Icons.email_outlined,
                label: 'Email',
                enabled: organisation.email.isNotEmpty,
                onTap: () => _launchContact(
                  context,
                  Uri(scheme: 'mailto', path: organisation.email.trim()),
                  'Could not open the email app.',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _contactAction(
                context,
                icon: Icons.location_on_outlined,
                label: 'Route',
                enabled: organisation.mapLocation != null,
                onTap: () => _launchContact(
                  context,
                  Uri.https('www.google.com', '/maps/search/', {
                    'api': '1',
                    'query': organisation.mapLocation!.coordinates,
                  }),
                  'Could not open directions.',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _contactAction(
                context,
                icon: Icons.ios_share_outlined,
                label: 'Share',
                enabled: true,
                onTap: () => _shareDetails(context),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _pill(BuildContext context, String label) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      );

  Widget _contactAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                size: 19,
                color: enabled
                    ? colors.primary
                    : colors.onSurface.withValues(alpha: 0.38)),
            const SizedBox(height: AppSpacing.xs),
            Text(label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: enabled
                        ? colors.onSurface
                        : colors.onSurface.withValues(alpha: 0.38))),
          ]),
        ),
      ),
    );
  }

  Future<void> _launchContact(
      BuildContext context, Uri uri, String errorMessage) async {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {}
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  Future<void> _shareDetails(BuildContext context) async {
    final lines = [
      organisation.name,
      if (organisation.address.isNotEmpty) organisation.address,
      if (organisation.phone.isNotEmpty) 'Phone: ${organisation.phone}',
      if (organisation.email.isNotEmpty) 'Email: ${organisation.email}',
      if (organisation.mapLocation != null)
        'Location: ${organisation.mapLocation!.coordinates}',
    ];
    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Organisation details copied to clipboard.')),
    );
  }

  Widget _coreAttributes(BuildContext context) => AppCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('CORE ATTRIBUTES',
                style: Theme.of(context).textTheme.labelLarge),
            const Divider(height: AppSpacing.lg),
            _detail(context, 'Address', organisation.address),
            _detail(context, 'Contact number', organisation.phone),
            _detail(context, 'Email', organisation.email),
            _detail(context, 'Branch', organisation.branch),
            _detail(context, 'Status', organisation.status),
            _detail(context, 'Opening hours', organisation.timings),
            _detail(context, 'Map coordinates',
                organisation.mapLocation?.coordinates ?? ''),
          ]),
        ),
      );

  Widget _committee(BuildContext context, bool canManage) =>
      _OrganisationMembersSection(
          organisation: organisation, canManage: canManage);

  Widget _productCatalog(BuildContext context, bool canManage) =>
      _ProductCatalogSection(organisation: organisation, canManage: canManage);

  Widget _advertisements(bool canManage) => _OrganisationAdvertisementsSection(
      organisation: organisation, canManage: canManage);

  void _edit(BuildContext context) => Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) => AddOrganisationScreen(organisation: organisation)));

  Widget _detail(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child:
                  Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
              child: SelectableText(value.isEmpty ? 'Not provided' : value,
                  textAlign: TextAlign.end,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600))),
        ]),
      );
}

class _OrganisationMembersSection extends StatefulWidget {
  const _OrganisationMembersSection(
      {required this.organisation, required this.canManage});

  final ShopOrg organisation;
  final bool canManage;

  @override
  State<_OrganisationMembersSection> createState() =>
      _OrganisationMembersSectionState();
}

class _OrganisationMembersSectionState
    extends State<_OrganisationMembersSection> {
  Future<List<OrganisationMember>>? _members;

  @override
  void initState() {
    super.initState();
    final home = context.read<HomeRepository?>();
    if (home != null) {
      _members = home.organisationContent.members(widget.organisation);
    }
  }

  Future<void> _viewAllMembers() async {
    final membersFuture = _members;
    if (membersFuture == null) return;
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => OrganisationMembersScreen(
          organisation: widget.organisation,
          members: membersFuture,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Members',
                      style: Theme.of(context).textTheme.titleMedium),
                  TextButton(
                    style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      minimumSize: const Size(0, 30),
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      foregroundColor: Colors.grey.shade500,
                    ),
                    onPressed: _viewAllMembers,
                    child: const Text('View all  >>'),
                  ),
                ],
              ),
            ),
            if (widget.canManage)
              TextButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Add member is not available yet.'))),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Member')),
          ]),
          if (_members == null)
            const Text('Sign in to view organisation members.')
          else
            FutureBuilder<List<OrganisationMember>>(
              future: _members,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Text('Could not load organisation members.');
                }
                final members = snapshot.data ?? const [];
                if (members.isEmpty) {
                  return const Text('No members listed.');
                }
                return Column(
                  children: members
                      .map((member) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: OrganisationMemberCard(member: member),
                          ))
                      .toList(),
                );
              },
            ),
        ],
      );
}

class _ProductCatalogSection extends StatefulWidget {
  const _ProductCatalogSection({
    required this.organisation,
    required this.canManage,
  });

  final ShopOrg organisation;
  final bool canManage;

  @override
  State<_ProductCatalogSection> createState() => _ProductCatalogSectionState();
}

class _ProductCatalogSectionState extends State<_ProductCatalogSection> {
  Future<List<OrganisationProduct>>? _products;

  @override
  void initState() {
    super.initState();
    final home = context.read<HomeRepository?>();
    if (widget.canManage && home != null) {
      _products = home.organisationContent.products(widget.organisation);
    }
  }

  Future<void> _openProducts() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OrganisationProductsScreen(organisation: widget.organisation),
      ),
    );
    if (!mounted || _products == null) return;
    setState(() {
      final home = context.read<HomeRepository?>();
      if (home != null) {
        _products = home.organisationContent.products(widget.organisation);
      }
    });
  }

  String _name(OrganisationProduct product) =>
      product.name.isNotEmpty ? product.name : 'Product ${product.productId}';

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Product Catalog',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (widget.canManage)
                    TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        minimumSize: const Size(0, 30),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        foregroundColor: Colors.grey.shade500,
                      ),
                      onPressed: _openProducts,
                      child: const Text('Browse all products  >>'),
                    )
                  else
                    Text('Showing up to 10 products',
                        style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (widget.canManage)
              TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Add Product'),
                onPressed: _openProducts,
              ),
          ]),
          if (widget.canManage) ...[
            const SizedBox(height: AppSpacing.sm),
            if (_products == null)
              const _ProductCatalogMessage(
                  message: 'Sign in to view this product catalog.')
            else
              FutureBuilder<List<OrganisationProduct>>(
                future: _products,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return _ProductCatalogMessage(
                      message: 'Could not load products.',
                      onRetry: () => setState(() {
                        final home = context.read<HomeRepository?>();
                        if (home != null) {
                          _products = home.organisationContent
                              .products(widget.organisation);
                        }
                      }),
                    );
                  }
                  final products = snapshot.data ?? const [];
                  if (products.isEmpty) {
                    return const _ProductCatalogMessage(
                        message: 'No products added yet.');
                  }
                  return Column(
                    children: products
                        .take(10)
                        .map((product) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: AppCard(
                                child: ListTile(
                                  leading: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: Icon(Icons.inventory_2_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                  title: Text(_name(product)),
                                  subtitle: Text(
                                      '${product.description}\n${product.quantity} in stock'),
                                  isThreeLine: true,
                                  trailing: Text('₹${product.price}'),
                                ),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
          ] else
            const _ProductCatalogMessage(
                message: 'Sign in to browse this product catalog.'),
        ],
      );
}

class _ProductCatalogMessage extends StatelessWidget {
  const _ProductCatalogMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(children: [
            Expanded(child: Text(message)),
            if (onRetry != null)
              IconButton(
                  tooltip: 'Retry',
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh)),
          ]),
        ),
      );
}

class _OrganisationAdvertisementsSection extends StatefulWidget {
  const _OrganisationAdvertisementsSection({
    required this.organisation,
    required this.canManage,
  });

  final ShopOrg organisation;
  final bool canManage;

  @override
  State<_OrganisationAdvertisementsSection> createState() =>
      _OrganisationAdvertisementsSectionState();
}

class _OrganisationAdvertisementsSectionState
    extends State<_OrganisationAdvertisementsSection> {
  Future<List<OrganisationAdvertisement>>? _advertisements;
  OrganisationAdvertisement? _latestCreatedAdvertisement;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final home = context.read<HomeRepository?>();
    if (widget.canManage && home != null) {
      _advertisements =
          home.organisationContent.advertisements(widget.organisation);
    }
  }

  void _rememberAdvertisement(OrganisationAdvertisement advertisement) {
    if (mounted) {
      setState(() => _latestCreatedAdvertisement = advertisement);
    }
  }

  Future<void> _openManager() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => OrganisationAdvertisementsScreen(
          organisation: widget.organisation,
          onAdvertisementAdded: _rememberAdvertisement,
        ),
      ),
    );
    if (!mounted) return;
    setState(_load);
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Advertisements',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (widget.canManage)
                    TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        minimumSize: const Size(0, 30),
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        foregroundColor: Colors.grey.shade500,
                      ),
                      onPressed: _openManager,
                      child: const Text('View all  >>'),
                    ),
                ],
              ),
            ),
            if (widget.canManage)
              TextButton.icon(
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: _openManager,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Add offer / adv / events'),
              ),
          ]),
          if (!widget.canManage)
            const _ProductCatalogMessage(
                message: 'Sign in to view organisation advertisements.')
          else if (_advertisements == null)
            const _ProductCatalogMessage(
                message: 'Sign in to view organisation advertisements.')
          else
            FutureBuilder<List<OrganisationAdvertisement>>(
              future: _advertisements,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _ProductCatalogMessage(
                    message: 'Could not load advertisements.',
                    onRetry: () => setState(_load),
                  );
                }
                final advertisements = snapshot.data ?? const [];
                final latest = _latestCreatedAdvertisement;
                final alreadyLoaded = latest == null ||
                    advertisements.any((ad) =>
                        ad.name == latest.name &&
                        ad.description == latest.description &&
                        ad.startDate == latest.startDate &&
                        ad.endDate == latest.endDate);
                final visibleAdvertisements = [
                  if (latest != null && !alreadyLoaded) latest,
                  ...advertisements,
                ];
                if (visibleAdvertisements.isEmpty) {
                  return const _ProductCatalogMessage(
                      message: 'No advertisements added yet.');
                }
                return Column(
                  children: visibleAdvertisements
                      .map((advertisement) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: AppCard(
                              child: ListTile(
                                leading: Icon(
                                  Icons.campaign_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                title: Text(advertisement.name),
                                subtitle: Text(
                                  '${advertisement.description}\n${advertisement.startDate} – ${advertisement.endDate}',
                                ),
                                isThreeLine: true,
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
        ],
      );
}
