import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../state/delivery_session.dart';
import 'delivery_dashboard.dart';

class DeliveryEntryScreen extends StatelessWidget {
  const DeliveryEntryScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      context.watch<DeliverySession>().currentUser == null
          ? const DeliveryLoginScreen()
          : const DeliveryDashboard();
}

class DeliveryLoginScreen extends StatefulWidget {
  const DeliveryLoginScreen({super.key});
  @override
  State<DeliveryLoginScreen> createState() => _DeliveryLoginScreenState();
}

class _DeliveryLoginScreenState extends State<DeliveryLoginScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _pin = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _pin.dispose();
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
      await context.read<DeliverySession>().login(_phone.text, _pin.text);
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Delivery login')),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(padding: const EdgeInsets.all(24), children: [
                  Text('Collect orders in your region',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  const Text(
                      'Sign in with your delivery account. Your assigned region determines which products you can pick up.'),
                  const SizedBox(height: 24),
                  Form(
                      key: _form,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                                controller: _phone,
                                enabled: !_busy,
                                decoration: const InputDecoration(
                                    labelText: 'Delivery mobile number'),
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10)
                                ],
                                validator: (value) =>
                                    RegExp(r'^\d{10}$').hasMatch(value ?? '')
                                        ? null
                                        : 'Enter a 10-digit mobile number'),
                            const SizedBox(height: 16),
                            TextFormField(
                                controller: _pin,
                                enabled: !_busy,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: 'Delivery PIN'),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4)
                                ],
                                validator: (value) => (value?.length ?? 0) == 4
                                    ? null
                                    : 'Enter your 4-digit PIN',
                                onFieldSubmitted: (_) => _login()),
                            if (_error != null)
                              Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Semantics(
                                      liveRegion: true,
                                      child: Text(_error!,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error)))),
                            const SizedBox(height: 20),
                            FilledButton(
                                onPressed: _busy ? null : _login,
                                child: Text(_busy
                                    ? 'Signing in…'
                                    : 'Log in to deliveries')),
                          ])),
                  const SizedBox(height: 24),
                  const Text(
                      'Delivery sign-in is not available yet. Contact your administrator.'),
                ]))),
      );
}
