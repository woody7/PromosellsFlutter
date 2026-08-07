import 'package:flutter/material.dart';

/// Shows a themed spinner dead-center over (or in place of) page content —
/// the single source of truth for "where the spinner goes," so every screen
/// shows it in exactly the same spot instead of each screen inventing its
/// own placement.
///
/// Adapted from AdroitERP's AppLoadingOverlay (same two-mode API), but uses
/// a plain themed CircularProgressIndicator instead of AdroitERP's
/// OrbitLogoSpinner, which is a hand-drawn animation of that app's own
/// brand mark — not something to carry over into a different product.
/// Swap the spinner here once Promosells has its own brand animation.
///
/// Two modes:
///   - [replaceContent] (default true): while loading, the spinner is the
///     ONLY thing shown — use for a page's initial data load.
///   - [replaceContent] = false: the spinner overlays on top of existing
///     content (with a light scrim) — use for an in-progress action on a
///     page that already has real content on it (e.g. submitting a form).
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.replaceContent = true,
    this.spinnerSize = 32,
  });

  final bool isLoading;
  final Widget child;
  final bool replaceContent;
  final double spinnerSize;

  @override
  Widget build(BuildContext context) {
    final spinner = SizedBox(
      width: spinnerSize,
      height: spinnerSize,
      child: CircularProgressIndicator(
        strokeWidth: spinnerSize / 10,
        color: Theme.of(context).colorScheme.primary,
      ),
    );

    if (isLoading && replaceContent) {
      return Center(child: spinner);
    }

    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.surface.withAlpha(160),
              child: Center(child: spinner),
            ),
          ),
      ],
    );
  }
}
