import 'package:flutter/material.dart';

/// Reusable detail page layout template.
///
/// Provides a standard [Scaffold] with a [CustomScrollView] and
/// [SliverAppBar] for any detail screen (rescue alert, adoption listing,
/// animal profile, organization). Supports an optional hero image,
/// status bar, scrollable content sections, and a sticky footer.
///
/// Pages inject real data through the widget slots -- this template
/// only defines WHERE things go, not what data they display.
class DetailTemplate extends StatelessWidget {
  const DetailTemplate({
    required this.title,
    required this.sections,
    super.key,
    this.heroWidget,
    this.heroHeight = 250,
    this.statusBar,
    this.stickyFooter,
    this.actions,
    this.onBack,
  });

  /// Page title shown in the [SliverAppBar].
  final String title;

  /// Main content sections rendered as children of a [SliverList].
  final List<Widget> sections;

  /// Optional hero widget displayed in the [SliverAppBar] flexible space
  /// (photo carousel, map, illustration, etc.).
  final Widget? heroWidget;

  /// Expanded height of the [SliverAppBar] when [heroWidget] is provided.
  /// Defaults to 250.
  final double heroHeight;

  /// Optional status bar rendered below the hero area for status
  /// badges, chips, or other summary information.
  final Widget? statusBar;

  /// Optional sticky footer displayed via [Scaffold.bottomNavigationBar].
  /// Stays fixed at the bottom during scroll -- typically a
  /// [StickyActionFooter] or similar action bar.
  final Widget? stickyFooter;

  /// Optional [SliverAppBar] trailing actions (share, edit, etc.).
  final List<Widget>? actions;

  /// If provided, shows a back button that calls this callback.
  /// When null, the default back navigation behavior applies.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final hasHero = heroWidget != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(title),
            pinned: true,
            expandedHeight: hasHero ? heroHeight : null,
            leading: onBack != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBack,
                  )
                : null,
            actions: actions,
            flexibleSpace: hasHero
                ? FlexibleSpaceBar(
                    background: heroWidget,
                  )
                : null,
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              if (statusBar != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: statusBar,
                ),
              ...sections,
              // Bottom padding so content is not obscured by sticky footer.
              const SizedBox(height: 80),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: stickyFooter,
    );
  }
}
