import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../state/app_state.dart';
import '../admin/admin_entry_screen.dart';
import '../delivery/delivery_entry_screen.dart';
import 'registration_screen.dart';
import 'splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context
          .read<AppState>()
          .login(_username.text.trim(), password: _password.text);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error is StateError
            ? error.message.toString()
            : 'Unable to log in. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(children: [
              const SizedBox(height: 16),
              const VillageMark(onLight: true),
              const SizedBox(height: 20),
              Text('Village Connect',
                  textAlign: TextAlign.center,
                  style: text.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text('Shop local. Share more. Belong together.',
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 24),
              const Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _CommunityLabel(AppIcons.storefront, 'Local shops'),
                    _CommunityLabel(AppIcons.usersThree, 'Neighbours'),
                    _CommunityLabel(AppIcons.leaf, 'Everyday services'),
                  ]),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(28)),
                child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome back', style: text.headlineSmall),
                        const SizedBox(height: 8),
                        Text('Log in to reconnect with your community.',
                            style: text.bodyMedium
                                ?.copyWith(color: context.tokens.textMuted)),
                        const SizedBox(height: 24),
                        TextFormField(
                          key: const ValueKey('login-username'),
                          controller: _username,
                          enabled: !_busy,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          decoration: const InputDecoration(
                              labelText: 'Username or mobile number'),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter your username or mobile number'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          key: const ValueKey('login-password'),
                          controller: _password,
                          enabled: !_busy,
                          obscureText: true,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: const [AutofillHints.password],
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter your password'
                              : null,
                          onFieldSubmitted: (_) => _login(),
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Semantics(
                                liveRegion: true,
                                child: Text(_error!,
                                    style: text.bodyMedium?.copyWith(
                                        color: theme.colorScheme.error))),
                          ),
                        const SizedBox(height: 20),
                        AppButton(
                            label: 'Log in',
                            onPressed: _login,
                            isLoading: _busy),
                        const SizedBox(height: 16),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 8),
                        Center(
                            child: Text('New to the neighbourhood?',
                                style: text.bodyMedium)),
                        const SizedBox(height: 8),
                        AppButton(
                            label: 'Create an account',
                            variant: AppButtonVariant.secondary,
                            onPressed: _busy
                                ? null
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const RegistrationScreen()))),
                      ],
                    )),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary),
                icon: const Icon(AppIcons.truck),
                label: const Text('Delivery login'),
                onPressed: _busy
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => const DeliveryEntryScreen())),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary),
                onPressed: _busy
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => const AdminEntryScreen())),
                child: const Text('Village administrator login'),
              ),
            ]),
          ),
        ),
      )),
    );
  }
}

class _CommunityLabel extends StatelessWidget {
  const _CommunityLabel(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface),
        const SizedBox(width: 6),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
      ]);
}
