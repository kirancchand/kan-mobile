import 'package:flutter/material.dart';

import 'admin/admin_entry_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'services/services_home_screen.dart';
import '../core/widgets/village_bottom_bar.dart';

/// Bottom-nav shell matching Section 6's top-level structure: Home,
/// Services, Profile, and Admin Panel.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    ServicesHomeScreen(),
    ProfileScreen(),
    AdminEntryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: VillageBottomBar(
        selectedIndex: _index,
        onSelected: (index) => setState(() => _index = index),
      ),
    );
  }
}
