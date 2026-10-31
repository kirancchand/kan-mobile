import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../root_shell.dart';
import '../../state/app_state.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

/// Decides whether to show the registration flow or the main app shell,
/// based on whether the user has completed onboarding.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _splashComplete = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashComplete) {
      return SplashScreen(
          onComplete: () => setState(() => _splashComplete = true));
    }
    final isRegistered = context.select<AppState, bool>((s) => s.isRegistered);
    return isRegistered ? const RootShell() : const LoginScreen();
  }
}
