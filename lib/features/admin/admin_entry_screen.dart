import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/shimmer_list_placeholder.dart';
import '../../data/models/admin_hierarchy.dart';
import '../../data/repositories/admin_repository.dart';
import '../../state/admin_state.dart';
import 'admin_login_screen.dart';
import 'head_admin/head_admin_dashboard.dart';

/// Admin Panel tab (Section 5/6). Open to every user: anyone visiting the
/// tab is signed in to the Main Admin account. Signing in here doesn't touch
/// [AppState].
class AdminEntryScreen extends StatelessWidget {
  const AdminEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminState = context.watch<AdminState>();

    if (!adminState.isLoggedIn) {
      final main = context
          .read<AdminRepository>()
          .accounts
          .where((account) => account.level == AdminLevel.main)
          .firstOrNull;
      if (main == null) return const AdminLoginScreen();
      // AdminState notifies listeners, so sign in after this frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!adminState.isLoggedIn) adminState.login(main);
      });
      return const Scaffold(body: ShimmerListPlaceholder());
    }

    return HeadAdminDashboard(key: ValueKey(adminState.account!.id));
  }
}
