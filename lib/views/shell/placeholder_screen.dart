import 'package:flutter/material.dart';

import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Stand-in for a screen not yet ported from the React app. Swapped out
/// screen-by-screen as each one gets built for real.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: MySpacing.all(24),
        child: MyCard(
          paddingAll: 32,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
              MySpacing.height(12),
              MyText.titleMedium(title),
              MySpacing.height(4),
              MyText.bodySmall('Coming soon', muted: true),
            ],
          ),
        ),
      ),
    );
  }
}
