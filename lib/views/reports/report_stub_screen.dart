import 'package:flutter/material.dart';

import 'package:promosells_flutter/widgets/my_card.dart';
import 'package:promosells_flutter/widgets/my_spacing.dart';
import 'package:promosells_flutter/widgets/my_text.dart';

/// Stand-in destination for `/report/:reportID` (Reportcomponents/Report.js)
/// until Stage 4 builds the real report detail screen. Submissions still
/// produce a real document number from the backend — this just doesn't
/// render its contents yet.
class ReportStubScreen extends StatelessWidget {
  const ReportStubScreen({super.key, required this.documentNumber});

  final String documentNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: MyText.titleMedium('Report')),
      body: Center(
        child: Padding(
          padding: MySpacing.all(24),
          child: MyCard(
            paddingAll: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 40),
                MySpacing.height(12),
                MyText.titleMedium('Submitted successfully'),
                MySpacing.height(4),
                MyText.bodyMedium('Document No: $documentNumber', muted: true),
                MySpacing.height(4),
                MyText.bodySmall('Full report view is coming in a later stage', muted: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
