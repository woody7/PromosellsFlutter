import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/views/customers/customer_list_screen.dart';
import 'package:promosells_flutter/views/shell/overview_screen.dart';
import 'package:promosells_flutter/views/shell/placeholder_screen.dart';
import 'package:promosells_flutter/views/stocklist/stocklist_screen.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final Widget page;
  final bool adminOnly;

  const _NavItem({required this.label, required this.icon, required this.page, this.adminOnly = false});
}

/// Persistent shell (top bar + drawer nav) that hosts every top-level
/// section once signed in. Mirrors TopNavBar.js's role gating: "Stock
/// Reports" (Report) and "Users" only show for Admin.
///
/// This scaffold switches sections in place via a drawer + IndexedStack
/// rather than full GetX named routes — each placeholder becomes a real,
/// independently routed screen (with its own controller and, where needed,
/// URL params like customerId) as it gets built.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final AuthController _auth = Get.find<AuthController>();

  List<_NavItem> get _items => [
        const _NavItem(label: 'Overview', icon: LucideIcons.layout_dashboard, page: OverviewScreen()),
        const _NavItem(label: 'Stock List', icon: LucideIcons.package, page: StocklistScreen()),
        const _NavItem(label: 'Customers', icon: LucideIcons.users, page: CustomerListScreen()),
        const _NavItem(
            label: 'Customer Map', icon: LucideIcons.map, page: PlaceholderScreen(title: 'Customer Map', icon: LucideIcons.map)),
        const _NavItem(
            label: 'Incident Report',
            icon: LucideIcons.clipboard_list,
            page: PlaceholderScreen(title: 'Incident Report by Date', icon: LucideIcons.clipboard_list)),
        _NavItem(
            label: 'Stock Reports',
            icon: LucideIcons.chart_bar,
            page: const PlaceholderScreen(title: 'Stock Reports', icon: LucideIcons.chart_bar),
            adminOnly: true),
        _NavItem(
            label: 'Users',
            icon: LucideIcons.shield,
            page: const PlaceholderScreen(title: 'User Management', icon: LucideIcons.shield),
            adminOnly: true),
        const _NavItem(
            label: 'Change Password',
            icon: LucideIcons.key_round,
            page: PlaceholderScreen(title: 'Change Password', icon: LucideIcons.key_round)),
      ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final visibleItems = _items.where((item) => !item.adminOnly || _auth.isAdmin).toList();
      final safeIndex = _selectedIndex < visibleItems.length ? _selectedIndex : 0;

      return Scaffold(
        appBar: AppBar(
          title: MyText.titleMedium(visibleItems[safeIndex].label),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.log_out),
              tooltip: 'Logout',
              onPressed: () => _auth.logout(),
            ),
          ],
        ),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: [
                DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyText.titleLarge('Promosells'),
                      MyText.bodySmall(_auth.session.value?.email ?? '', muted: true),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: visibleItems.length,
                    itemBuilder: (context, index) {
                      final item = visibleItems[index];
                      return ListTile(
                        leading: Icon(item.icon),
                        title: MyText.bodyMedium(item.label),
                        selected: index == safeIndex,
                        onTap: () {
                          setState(() => _selectedIndex = index);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: IndexedStack(
          index: safeIndex,
          children: visibleItems.map((item) => item.page).toList(),
        ),
      );
    });
  }
}
