import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';

import 'package:promosells_flutter/controllers/auth_controller.dart';
import 'package:promosells_flutter/views/customers/customer_list_screen.dart';
import 'package:promosells_flutter/views/customers/customer_map_screen.dart';
import 'package:promosells_flutter/views/reports/incident_report_screen.dart';
import 'package:promosells_flutter/views/reports/report_list_screen.dart';
import 'package:promosells_flutter/views/shell/change_password_screen.dart';
import 'package:promosells_flutter/views/shell/overview_screen.dart';
import 'package:promosells_flutter/views/shell/user_management_screen.dart';
import 'package:promosells_flutter/views/stocklist/stocklist_screen.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final Widget page;
  final bool adminOnly;

  const _NavItem({required this.label, required this.icon, required this.page, this.adminOnly = false});
}

/// Width at which the shell switches from a mobile Drawer to a persistent
/// sidebar — matches the threshold already used for the Overview
/// dashboard's card/chart layout switch, so the whole app agrees on what
/// counts as "wide."
const _wideBreakpoint = 900.0;

/// Content beyond this width is centered with empty margins either side
/// rather than stretching edge-to-edge, same idea as AdroitERP's layout
/// on very wide monitors.
const _maxContentWidth = 1200.0;

/// Persistent shell (top bar + nav) that hosts every top-level section once
/// signed in. Mirrors TopNavBar.js's role gating: "Stock Reports" (Report)
/// and "Users" only show for Admin.
///
/// Below [_wideBreakpoint], nav is a mobile Drawer (hamburger icon).
/// At or above it, nav is a persistent sidebar and content gets a max-width
/// constraint — the responsive/desktop treatment deferred from Stage 2
/// (see ROADMAP.md's decisions log for why it didn't happen earlier).
///
/// This scaffold switches sections in place via nav + IndexedStack rather
/// than full GetX named routes — each screen would become independently
/// routed (with its own controller and, where needed, URL params like
/// customerId) if that's ever needed; nothing here currently requires it.
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
        const _NavItem(label: 'Customer Map', icon: LucideIcons.map, page: CustomerMapScreen()),
        const _NavItem(label: 'Incident Report', icon: LucideIcons.clipboard_list, page: IncidentReportScreen()),
        const _NavItem(label: 'Stock Reports', icon: LucideIcons.chart_bar, page: ReportListScreen(), adminOnly: true),
        const _NavItem(label: 'Users', icon: LucideIcons.shield, page: UserManagementScreen(), adminOnly: true),
        const _NavItem(label: 'Change Password', icon: LucideIcons.key_round, page: ChangePasswordScreen()),
      ];

  Widget _navHeader() {
    return DrawerHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MyText.titleLarge('Promosells'),
          MyText.bodySmall(_auth.session.value?.email ?? '', muted: true),
        ],
      ),
    );
  }

  Widget _navList({
    required List<_NavItem> visibleItems,
    required int safeIndex,
    required bool closeDrawerOnTap,
  }) {
    return ListView.builder(
      itemCount: visibleItems.length,
      itemBuilder: (context, index) {
        final item = visibleItems[index];
        return ListTile(
          leading: Icon(item.icon),
          title: MyText.bodyMedium(item.label),
          selected: index == safeIndex,
          onTap: () {
            setState(() => _selectedIndex = index);
            if (closeDrawerOnTap) Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final visibleItems = _items.where((item) => !item.adminOnly || _auth.isAdmin).toList();
      final safeIndex = _selectedIndex < visibleItems.length ? _selectedIndex : 0;

      final content = Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: IndexedStack(
            index: safeIndex,
            children: visibleItems.map((item) => item.page).toList(),
          ),
        ),
      );

      return LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _wideBreakpoint;

        if (isWide) {
          return Scaffold(
            appBar: AppBar(
              title: MyText.titleMedium(visibleItems[safeIndex].label),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.log_out),
                  tooltip: 'Logout',
                  onPressed: () => _auth.logout(),
                ),
              ],
            ),
            body: Row(
              children: [
                SizedBox(
                  width: 260,
                  child: Material(
                    elevation: 1,
                    child: Column(
                      children: [
                        _navHeader(),
                        Expanded(child: _navList(visibleItems: visibleItems, safeIndex: safeIndex, closeDrawerOnTap: false)),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: content),
              ],
            ),
          );
        }

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
                  _navHeader(),
                  Expanded(child: _navList(visibleItems: visibleItems, safeIndex: safeIndex, closeDrawerOnTap: true)),
                ],
              ),
            ),
          ),
          body: content,
        );
      });
    });
  }
}
