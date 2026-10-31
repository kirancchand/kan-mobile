import '../../core/widgets/map_location_field.dart';
import '../../data/models/map_location.dart';
import '../../data/models/shop_org.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../data/models/organisation_draft.dart';
import '../../core/widgets/error_state.dart';
import '../../data/repositories/home_repository.dart';
import '../../state/app_state.dart';
import '../../data/repositories/auth_repository.dart';
import '../../state/admin_state.dart';
import '../../data/models/admin_hierarchy.dart';

class AddOrganisationScreen extends StatefulWidget {
  const AddOrganisationScreen(
      {super.key, this.branchAdmin = false, this.organisation});
  final ShopOrg? organisation;
  final bool branchAdmin;

  @override
  State<AddOrganisationScreen> createState() => _AddOrganisationScreenState();
}

class _AddOrganisationScreenState extends State<AddOrganisationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  bool _saving = false;
  bool _initializedOptions = false;
  bool get _editing => widget.organisation != null;
  MapLocation? _mapLocation;
  OrganisationOption? _type, _branch, _status;
  Future<OrganisationFormOptions>? _options;

  @override
  void initState() {
    super.initState();
    final organisation = widget.organisation;
    if (organisation != null) {
      _name.text = organisation.name;
      _address.text = organisation.address;
      _mapLocation = organisation.mapLocation;
    }
    final allowed = widget.branchAdmin
        ? context.read<AdminState>().account?.level == AdminLevel.branch
        : context.read<AppState>().currentUser != null;
    if (allowed) {
      _options = context.read<HomeRepository>().getOrganisationFormOptions();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_editing && !widget.organisation!.canEditOrganisation) return;
    if (_saving || !_formKey.currentState!.validate()) return;
    final session = context.read<AuthRepository>().tokens;
    final ownerId = session?.userId;
    if (ownerId == null || ownerId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please sign in again to add your organisation.'),
      ));
      return;
    }
    setState(() => _saving = true);
    try {
      final draft = OrganisationDraft(
          name: _name.text,
          address: _address.text,
          contact:
              _editing ? widget.organisation!.phone : session?.mobileNumber,
          email: _editing ? widget.organisation!.email : session?.email,
          type: _type!,
          branch: _branch!,
          status: _status!,
          ownerId: ownerId,
          mapLocation: _mapLocation);
      final repository = context.read<HomeRepository>();
      final refreshed = _editing
          ? await repository.updateOrganisation(widget.organisation!, draft)
          : await repository.createOrganisation(draft);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger.showSnackBar(SnackBar(
          content: Text(refreshed
              ? (_editing
                  ? 'Organisation updated'
                  : 'Organisation added to the directory')
              : 'Organisation saved. Refresh the directory to see it.')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not save organisation. Please try again.')),
      );
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  @override
  Widget build(BuildContext context) {
    final admin =
        widget.branchAdmin ? context.watch<AdminState>().account : null;
    final allowed = widget.branchAdmin
        ? admin?.level == AdminLevel.branch
        : context.watch<AppState>().currentUser != null;
    return Scaffold(
      appBar: AppBar(
          title: Text(_editing ? 'Edit Organisation' : 'Add Organisation')),
      body: !allowed || (_editing && !widget.organisation!.canEditOrganisation)
          ? const Center(child: Text('Sign in to add your organisation.'))
          : FutureBuilder<OrganisationFormOptions>(
              future: _options,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorState(
                      onRetry: () => setState(() {
                            _options = context
                                .read<HomeRepository>()
                                .getOrganisationFormOptions();
                          }));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final options = snapshot.data!;
                if (_editing && !_initializedOptions) {
                  final org = widget.organisation!;
                  OrganisationOption? match(List<OrganisationOption> values,
                      OrganisationOption? current, String label) {
                    for (final value in values) {
                      if (current != null
                          ? value.value == current.value
                          : value.label == label) {
                        return value;
                      }
                    }
                    return null;
                  }

                  _type = match(options.types, org.typeOption,
                      org.organisationType ?? '');
                  _branch =
                      match(options.branches, org.branchOption, org.branch);
                  _status =
                      match(options.statuses, org.statusOption, org.status);
                  _initializedOptions = true;
                }
                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.branchAdmin)
                          Text('Branch: ${admin!.territory}'),
                        const Text(
                            'Share your organisation with your community. These details will appear in the directory.'),
                        const SizedBox(height: AppSpacing.lg),
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                              labelText: 'Organisation name'),
                          textCapitalization: TextCapitalization.words,
                          validator: _required,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextFormField(
                          key: const ValueKey('organisation-address'),
                          controller: _address,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                              labelText: 'Organisation address'),
                          keyboardType: TextInputType.streetAddress,
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 2,
                          maxLines: 3,
                          validator: _required,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _selector('Organisation type', options.types, _type,
                            (value) => _type = value),
                        const SizedBox(height: AppSpacing.md),
                        _selector('Branch', options.branches, _branch,
                            (value) => _branch = value),
                        const SizedBox(height: AppSpacing.md),
                        _selector('Status', options.statuses, _status,
                            (value) => _status = value),
                        const SizedBox(height: AppSpacing.lg),
                        MapLocationField(
                          label: 'map location',
                          value: _mapLocation,
                          enabled: !_saving,
                          onChanged: (value) =>
                              setState(() => _mapLocation = value),
                        ),
                        FilledButton(
                          onPressed: _saving ? null : _save,
                          child: Text(_saving
                              ? 'Saving…'
                              : (_editing
                                  ? 'Save changes'
                                  : 'Add Organisation')),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _selector(
          String label,
          List<OrganisationOption> options,
          OrganisationOption? selected,
          void Function(OrganisationOption?) update) =>
      DropdownButtonFormField<OrganisationOption>(
        decoration: InputDecoration(labelText: label),
        initialValue: selected,
        isExpanded: true,
        hint: Text(options.isEmpty ? 'No options available' : 'Select $label'),
        items: options
            .map((option) =>
                DropdownMenuItem(value: option, child: Text(option.label)))
            .toList(),
        validator: (value) => value == null ? 'Select $label' : null,
        onChanged: _saving ? null : (value) => setState(() => update(value)),
      );
}
