import '../../core/widgets/kan_registration_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/village_carousel.dart';
import '../../state/app_state.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registration = GlobalKey<KanRegistrationFieldsState>();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final appState = context.read<AppState>();
    try {
      final details = _registration.currentState!.registration;
      await appState.register(
        name: details.fullName,
        phone: details.mobile,
        registration: details,
        locationId: details.branchValue.toString(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created. Please log in.')));
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error is StateError
                  ? error.message.toString()
                  : 'Could not create account. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Join your village')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),
                const VillageCarousel(),
                const SizedBox(height: AppSpacing.xl),
                Text('Make yourself at home', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text('A few details to connect you with your village.',
                    style: textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.lg),
                KanRegistrationFields(
                    key: _registration, enabled: !_isSubmitting),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Register & Continue',
                  onPressed: _submit,
                  isLoading: _isSubmitting,
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 260.ms)
            .slideY(begin: 0.03, end: 0, curve: Curves.easeOut),
      ),
    );
  }
}
