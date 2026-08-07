import 'package:flutter/material.dart';

import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Defense-in-depth guard for Admin-only screens. AppShell's drawer already
/// hides these from non-Admins (matching TopNavBar.js), so this shouldn't
/// normally be reachable — but ReportList.jsx and UserManagement.js each
/// have their own internal role check too, in case of a future deep link or
/// route added without updating the nav gating. Matches that belt-and-
/// suspenders pattern rather than trusting nav-level gating alone.
class AccessDeniedView extends StatelessWidget {
  const AccessDeniedView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: MySpacing.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block, color: Theme.of(context).colorScheme.error, size: 32),
            MySpacing.height(8),
            MyText.titleMedium('Access Denied'),
            MySpacing.height(4),
            MyText.bodyMedium(message, muted: true, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
