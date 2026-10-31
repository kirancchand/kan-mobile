import 'package:flutter/material.dart';

/// Admin access remains unavailable until authenticated role assignment exists.
class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Admin Login')),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
              'Administrator sign-in is not available. Contact your administrator for access.'),
        ),
      );
}
