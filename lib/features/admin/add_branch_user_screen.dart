import '../../core/widgets/kan_registration_fields.dart';
import '../../core/widgets/map_location_field.dart';
import '../../data/models/map_location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../data/models/admin_hierarchy.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/admin_repository.dart';
import '../../state/admin_state.dart';

class AddBranchUserScreen extends StatefulWidget {
  const AddBranchUserScreen({super.key});

  @override
  State<AddBranchUserScreen> createState() => _AddBranchUserScreenState();
}

class _AddBranchUserScreenState extends State<AddBranchUserScreen> {
  final _form = GlobalKey<FormState>();
  final _registration = GlobalKey<KanRegistrationFieldsState>();
  UserType? _type;
  bool _saving = false;
  MapLocation? _mapLocation;
  String? _error;

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    final admin = context.read<AdminState>().account;
    if (admin == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final details = _registration.currentState!.registration;
      final user = await context.read<AdminRepository>().addUser(
            viewerId: admin.id,
            name: details.fullName,
            phone: details.mobile,
            registration: details,
            userType: _type!,
            mapLocation: _mapLocation,
          );
      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(user.apiRegistered
                ? 'User registered and added to your branch'
                : 'Registration failed. Please try again.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error is StateError
            ? error.message.toString()
            : 'Could not add user. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminState>().account;
    return Scaffold(
      appBar: AppBar(title: const Text('Add User')),
      body: admin?.level != AdminLevel.branch
          ? const Center(child: Text('Sign in as a branch admin to add users.'))
          : Form(
              key: _form,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Branch: ${admin!.territory}'),
                    const SizedBox(height: AppSpacing.md),
                    KanRegistrationFields(
                        key: _registration, enabled: !_saving),
                    DropdownButtonFormField<UserType>(
                      decoration: const InputDecoration(labelText: 'User type'),
                      hint: const Text('Select user type'),
                      isExpanded: true,
                      items: UserType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.label),
                              ))
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _type = value),
                      validator: (value) =>
                          value == null ? 'Select a user type' : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_error != null)
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    MapLocationField(
                      label: 'map location',
                      value: _mapLocation,
                      enabled: !_saving,
                      onChanged: (value) =>
                          setState(() => _mapLocation = value),
                    ),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? 'Saving…' : 'Add User'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
