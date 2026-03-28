import 'package:flutter/material.dart';
import 'package:altrupets/core/widgets/molecules/app_tabs.dart';

/// Reusable list page layout template.
///
/// Provides a standard [Scaffold] structure for any list screen
/// (rescues, adoptions, notifications, organizations) with optional
/// slots for search, filters, tabs, and a FAB.
///
/// Pages inject real data through the widget slots -- this template
/// only defines WHERE things go, not what data they display.
class ListTemplate extends StatelessWidget {
  const ListTemplate({
    required this.title,
    required this.listContent,
    super.key,
    this.searchBar,
    this.filterBar,
    this.tabs,
    this.floatingActionButton,
    this.actions,
    this.onBack,
  });

  /// Page title shown in the [AppBar].
  final String title;

  /// Main list area -- typically an [InfiniteScrollList], [ListView], etc.
  final Widget listContent;

  /// Optional search bar slot rendered above the list content.
  final Widget? searchBar;

  /// Optional filter chip bar slot rendered below the search bar.
  final Widget? filterBar;

  /// If provided, wraps the body in a [DefaultTabController] + [TabBarView]
  /// via [AppTabs]. Each tab page receives [listContent] through the
  /// [AppTabs.children] property.
  final AppTabs? tabs;

  /// Optional floating action button.
  final Widget? floatingActionButton;

  /// Optional [AppBar] trailing actions.
  final List<Widget>? actions;

  /// If provided, shows a back button that calls this callback.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              )
            : null,
        actions: actions,
      ),
      body: tabs != null ? _buildTabbedBody() : _buildBody(),
      floatingActionButton: floatingActionButton,
    );
  }

  /// Builds the body with [AppTabs] wrapping the list content.
  ///
  /// The [AppTabs] molecule already provides [DefaultTabController],
  /// [TabBar], and [TabBarView] so we replace [listContent] with the
  /// full tabbed layout, prepending optional header slots.
  Widget _buildTabbedBody() {
    return Column(
      children: [
        if (searchBar != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: searchBar,
          ),
        if (filterBar != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: filterBar,
          ),
        Expanded(child: tabs!),
      ],
    );
  }

  /// Builds the standard (non-tabbed) body with optional header slots.
  Widget _buildBody() {
    return Column(
      children: [
        if (searchBar != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: searchBar,
          ),
        if (filterBar != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: filterBar,
          ),
        Expanded(child: listContent),
      ],
    );
  }
}
