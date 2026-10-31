import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/media_picker.dart';
import '../../core/widgets/error_state.dart';
import '../../data/models/media_attachment.dart';
import '../../data/models/organisation_content.dart';
import '../../data/models/organisation_draft.dart';
import '../../data/models/shop_org.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/services/organisation_content_api.dart';

class OrganisationAdvertisementsScreen extends StatefulWidget {
  const OrganisationAdvertisementsScreen(
      {super.key, required this.organisation, this.onAdvertisementAdded});
  final ShopOrg organisation;
  final ValueChanged<OrganisationAdvertisement>? onAdvertisementAdded;
  @override
  State<OrganisationAdvertisementsScreen> createState() =>
      _OrganisationAdvertisementsScreenState();
}

class _OrganisationAdvertisementsScreenState
    extends State<OrganisationAdvertisementsScreen> {
  late final OrganisationContentApi _api;
  Future<List<OrganisationAdvertisement>>? _future;
  OrganisationAdvertisement? _latestCreatedAdvertisement;

  @override
  void initState() {
    super.initState();
    _api = context.read<HomeRepository>().organisationContent;
    if (widget.organisation.canEditOrganisation) {
      _future = _api.advertisements(widget.organisation);
    }
  }

  Future<void> _refresh() async {
    final future = _api.advertisements(widget.organisation);
    setState(() {
      _future = future;
    });
    try {
      await future;
    } catch (_) {/* Display retry state. */}
  }

  Future<void> _refreshUntilPresent(
      OrganisationAdvertisement expectedAdvertisement) async {
    List<OrganisationAdvertisement> latest = const [];
    for (var attempt = 0; attempt < 5; attempt++) {
      if (!mounted) return;
      try {
        latest = await _api.advertisements(widget.organisation);
      } catch (_) {
        if (attempt == 4) return;
      }
      if (latest.any((ad) =>
          ad.name == expectedAdvertisement.name &&
          ad.description == expectedAdvertisement.description &&
          ad.startDate == expectedAdvertisement.startDate &&
          ad.endDate == expectedAdvertisement.endDate)) {
        setState(() {
          _future = Future.value(latest);
          _latestCreatedAdvertisement = null;
        });
        return;
      }
      if (!mounted) return;
      if (attempt < 4) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    }
    if (mounted) {
      setState(() {
        _future = Future.value(latest);
      });
    }
  }

  Future<void> _add() async {
    final savedAdvertisement = await Navigator.push<OrganisationAdvertisement>(
        context,
        MaterialPageRoute(
            builder: (_) => _AddAdvertisementScreen(
                organisation: widget.organisation, api: _api)));
    if (savedAdvertisement != null && mounted) {
      setState(() => _latestCreatedAdvertisement = savedAdvertisement);
      widget.onAdvertisementAdded?.call(savedAdvertisement);
      await _refreshUntilPresent(savedAdvertisement);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Organisation advertisements')),
        body: !widget.organisation.canEditOrganisation
            ? const Center(child: Text('You cannot manage this organisation.'))
            : FutureBuilder<List<OrganisationAdvertisement>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ErrorState(
                        title: 'Could not load advertisements',
                        onRetry: _refresh);
                  }
                  final advertisements = snapshot.data!;
                  final optimisticAd = _latestCreatedAdvertisement;
                  final alreadyLoaded = optimisticAd == null ||
                      advertisements.any((ad) =>
                          ad.name == optimisticAd.name &&
                          ad.description == optimisticAd.description &&
                          ad.startDate == optimisticAd.startDate &&
                          ad.endDate == optimisticAd.endDate);
                  final visibleAdvertisements = [
                    if (optimisticAd != null && !alreadyLoaded) optimisticAd,
                    ...advertisements,
                  ];
                  return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: [
                          Text(widget.organisation.name,
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                              onPressed: _add,
                              icon: const Icon(Icons.add),
                              label: const Text('Add advertisement')),
                          if (visibleAdvertisements.isEmpty)
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Text('No advertisements added yet.')),
                          for (final ad in visibleAdvertisements)
                            Card(
                                child: ListTile(
                              title: Text(ad.name),
                              subtitle: Text(
                                  '${ad.description}\n${ad.startDate} – ${ad.endDate}'),
                              isThreeLine: true,
                            )),
                        ],
                      ));
                }),
      );
}

class _AddAdvertisementScreen extends StatefulWidget {
  const _AddAdvertisementScreen(
      {required this.organisation, required this.api});
  final ShopOrg organisation;
  final OrganisationContentApi api;
  @override
  State<_AddAdvertisementScreen> createState() =>
      _AddAdvertisementScreenState();
}

class _AddAdvertisementScreenState extends State<_AddAdvertisementScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _description = TextEditingController();
  DateTime? _start, _end;
  MediaAttachment? _image;
  List<OrganisationOption>? _types;
  String? _typeId, _typeError;
  bool _loadingTypes = true;
  bool _saving = false, _picking = false;
  String? _validation;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    setState(() {
      _loadingTypes = true;
      _typeError = null;
    });
    try {
      final types = await widget.api.advertisementTypes();
      if (mounted) {
        setState(() {
          _types = types;
          _loadingTypes = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _typeError = 'Could not load advertisement types.';
          _loadingTypes = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    setState(() => _picking = true);
    try {
      final image = await MediaPicker()
          .pick(MediaKind.image, remainingBytes: MediaPicker.maxFileBytes);
      if (mounted && image != null) setState(() => _image = image);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error is FormatException
                ? error.message
                : 'Could not open the image. Please try again.')));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _pickDate(bool start) async {
    final now = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
        context: context,
        initialDate: start ? _start ?? now : _end ?? _start ?? now,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));
    if (picked != null && mounted) {
      setState(() {
        if (start) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_saving || _picking) return;
    final valid = _form.currentState!.validate();
    setState(() {
      _validation = _typeId == null
          ? 'Choose an advertisement type.'
          : _image == null
              ? 'Choose an advertisement image.'
              : _start == null || _end == null
                  ? 'Choose both dates.'
                  : _end!.isBefore(_start!)
                      ? 'End date must be on or after start date.'
                      : null;
    });
    if (!valid || _validation != null) return;
    setState(() => _saving = true);
    try {
      await widget.api.addAdvertisement(
          widget.organisation,
          OrganisationAdvertisementDraft(
              name: _name.text,
              description: _description.text,
              startDate: _start!,
              endDate: _end!,
              advertisementTypeId: _typeId!,
              image: _image!));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Advertisement added')));
      Navigator.pop(
        context,
        OrganisationAdvertisement(
          name: _name.text.trim(),
          description: _description.text.trim(),
          startDate: _dateValue(_start!),
          endDate: _dateValue(_end!),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not add advertisement. Please try again.')));
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  String _dateValue(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  String _dateLabel(DateTime? value, String placeholder) => value == null
      ? placeholder
      : MaterialLocalizations.of(context).formatMediumDate(value);

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Add advertisement')),
        body: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Text(widget.organisation.name),
              const SizedBox(height: 16),
              if (_loadingTypes)
                const Center(child: CircularProgressIndicator())
              else if (_typeError != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_typeError!),
                    TextButton(
                        onPressed: _loadTypes,
                        child: const Text('Retry loading types')),
                  ],
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _typeId,
                  decoration:
                      const InputDecoration(labelText: 'Advertisement type'),
                  items: (_types ?? const <OrganisationOption>[])
                      .map((type) => DropdownMenuItem(
                            value: type.value,
                            child: Text(type.label),
                          ))
                      .toList(),
                  validator: (value) =>
                      value == null ? 'Choose an advertisement type.' : null,
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _typeId = value),
                ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _name,
                  enabled: !_saving,
                  decoration:
                      const InputDecoration(labelText: 'Advertisement name'),
                  validator: _required),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _description,
                  enabled: !_saving,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 2,
                  maxLines: 4,
                  validator: _required),
              const SizedBox(height: 16),
              if (_image != null) ...[
                Image.memory(_image!.bytes,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder: (_, error, stack) =>
                        const Text('Image preview unavailable')),
                Text(_image!.name),
              ],
              OutlinedButton.icon(
                  onPressed: _saving || _picking ? null : _pickImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(_picking
                      ? 'Opening image…'
                      : _image == null
                          ? 'Choose image'
                          : 'Change image')),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                  onPressed: _saving ? null : () => _pickDate(true),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_dateLabel(_start, 'Start date'))),
              OutlinedButton.icon(
                  onPressed: _saving ? null : () => _pickDate(false),
                  icon: const Icon(Icons.event),
                  label: Text(_dateLabel(_end, 'End date'))),
              if (_validation != null)
                Text(_validation!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 24),
              FilledButton(
                  onPressed: _saving || _picking ? null : _save,
                  child: Text(_saving ? 'Saving…' : 'Add advertisement')),
            ])),
      ));
}
