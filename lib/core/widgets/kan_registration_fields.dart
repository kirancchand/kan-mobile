import 'package:flutter/material.dart';
import '../../data/models/kan_registration.dart';
import '../../data/models/gender_option.dart';
import '../../data/services/kan_master_api.dart';

/// Shared API registration fields for residents and branch-created users.
class KanRegistrationFields extends StatefulWidget {
  const KanRegistrationFields({super.key, this.enabled = true, this.masterApi});
  final KanMasterApi? masterApi;
  final bool enabled;
  @override
  State<KanRegistrationFields> createState() => KanRegistrationFieldsState();
}

class KanRegistrationFieldsState extends State<KanRegistrationFields> {
  late final KanMasterApi _masterApi;
  List<GenderOption> _genders = const [];
  GenderOption? _gender;
  bool _loadingGenders = true;
  bool _genderLoadFailed = false;

  @override
  void initState() {
    super.initState();
    _masterApi = widget.masterApi ?? KanMasterApi();
    _loadGenders();
  }

  Future<void> _loadGenders() async {
    setState(() {
      _loadingGenders = true;
      _genderLoadFailed = false;
    });
    try {
      final options = await _masterApi.getGenders();
      if (!mounted) return;
      setState(() {
        _genders = options;
        _gender = options.isEmpty ? null : options.first;
        _genderLoadFailed = options.isEmpty;
        _loadingGenders = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingGenders = false;
        _genderLoadFailed = true;
      });
    }
  }

  final _fields = <String, TextEditingController>{
    for (final key in [
      'username',
      'firstName',
      'middleName',
      'lastName',
      'email',
      'mobno',
      'password',
      'dateofbirth'
    ])
      key: TextEditingController(),
    'branchValue': TextEditingController(),
    'branchLabel': TextEditingController(),
  };
  String _text(String key) => _fields[key]!.text.trim();
  KanRegistration get registration => KanRegistration(
        username:
            _text('username').isEmpty ? _text('mobno') : _text('username'),
        firstName: _text('firstName'),
        middleName: _text('middleName'),
        lastName: _text('lastName'),
        email: _text('email'),
        mobile: _text('mobno'),
        password: _fields['password']!.text,
        dateOfBirth: _text('dateofbirth'),
        genderValue: int.parse(_gender!.value),
        genderLabel: _gender!.label,
        branchValue: int.parse(_text('branchValue')),
        branchLabel: _text('branchLabel'),
      );

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    if (widget.masterApi == null) _masterApi.dispose();
    super.dispose();
  }

  String? _dateError(String? value) {
    final match =
        RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(value?.trim() ?? '');
    if (match == null) return 'Use DD/MM/YYYY';
    final day = int.parse(match[1]!);
    final month = int.parse(match[2]!);
    final year = int.parse(match[3]!);
    final date = DateTime(year, month, day);
    if (year < 1900 ||
        date.year != year ||
        date.month != month ||
        date.day != day ||
        date.isAfter(DateTime.now())) {
      return 'Enter a valid date of birth';
    }
    return null;
  }

  Widget _field(String key, String label,
          {bool optional = false,
          String? hint,
          String? Function(String?)? validate,
          TextInputType? keyboard}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          key: ValueKey('register-$key'),
          controller: _fields[key],
          enabled: widget.enabled,
          decoration: InputDecoration(labelText: label, hintText: hint),
          keyboardType: keyboard,
          obscureText: key == 'password',
          autocorrect: key != 'password',
          enableSuggestions: key != 'password',
          validator: validate ??
              (value) => !optional && (value == null || value.trim().isEmpty)
                  ? 'Enter $label'
                  : null,
        ),
      );

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field('firstName', 'First name'),
          _field('middleName', 'Middle name (optional)', optional: true),
          _field('lastName', 'Last name'),
          _field('mobno', 'Mobile number',
              keyboard: TextInputType.phone,
              validate: (v) => RegExp(r'^[0-9]{10}$').hasMatch(v?.trim() ?? '')
                  ? null
                  : 'Enter a 10-digit mobile number'),
          _field('username', 'Username (optional)',
              optional: true, hint: 'Defaults to your mobile number'),
          _field('email', 'Email',
              keyboard: TextInputType.emailAddress,
              validate: (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                      .hasMatch(v?.trim() ?? '')
                  ? null
                  : 'Enter a valid email'),
          _field('password', 'Password',
              validate: (v) =>
                  (v?.isNotEmpty ?? false) ? null : 'Enter Password'),
          _field('dateofbirth', 'Date of birth',
              hint: 'DD/MM/YYYY',
              keyboard: TextInputType.datetime,
              validate: _dateError),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<GenderOption>(
              key: ValueKey('register-gender-$_loadingGenders'),
              initialValue: _gender,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Gender'),
              hint:
                  Text(_loadingGenders ? 'Loading genders…' : 'Select gender'),
              items: _genders
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option.label),
                      ))
                  .toList(),
              onChanged: !widget.enabled || _loadingGenders
                  ? null
                  : (value) => setState(() => _gender = value),
              validator: (value) => _loadingGenders
                  ? 'Please wait for genders to load'
                  : value == null
                      ? 'Select gender'
                      : null,
            ),
          ),
          if (_genderLoadFailed)
            TextButton.icon(
              onPressed: widget.enabled ? _loadGenders : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Unable to load genders. Retry'),
            ),
          const Text('Enter the branch details provided for your account.'),
          const SizedBox(height: 12),
          _field('branchValue', 'Branch ID',
              keyboard: TextInputType.number, validate: _positiveId),
          _field('branchLabel', 'Branch name'),
        ],
      );

  String? _positiveId(String? value) =>
      (int.tryParse(value?.trim() ?? '') ?? 0) > 0
          ? null
          : 'Enter a positive numeric ID';
}
