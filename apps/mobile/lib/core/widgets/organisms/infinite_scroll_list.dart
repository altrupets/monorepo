import 'package:flutter/material.dart';
import 'package:altrupets/core/widgets/atoms/skeleton_loader.dart';
import 'package:altrupets/core/widgets/atoms/app_empty_state.dart';

/// Generic paginated list with skeleton loading and empty state.
///
/// Detects scroll position at 80% threshold to trigger [onLoadMore].
/// Shows [SkeletonLoader] placeholders during initial load and an
/// [AppEmptyState] when no items exist.
class InfiniteScrollList extends StatefulWidget {
  const InfiniteScrollList({
    required this.itemCount,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.isLoading,
    required this.hasMore,
    super.key,
    this.emptyIcon,
    this.emptyTitle,
    this.emptyMessage,
    this.onRefresh,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final VoidCallback onLoadMore;
  final bool isLoading;
  final bool hasMore;
  final IconData? emptyIcon;
  final String? emptyTitle;
  final String? emptyMessage;
  final Future<void> Function()? onRefresh;

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoading) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * 0.8;

    if (currentScroll >= threshold) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initial loading: show skeleton placeholders
    if (widget.isLoading && widget.itemCount == 0) {
      return ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: SkeletonLoader(width: double.infinity, height: 72),
          );
        },
      );
    }

    // Empty state
    if (widget.itemCount == 0 && !widget.isLoading) {
      return AppEmptyState(
        icon: widget.emptyIcon ?? Icons.inbox_outlined,
        title: widget.emptyTitle ?? 'Sin resultados',
        message: widget.emptyMessage,
      );
    }

    // Items list with optional trailing skeleton
    final totalCount =
        widget.itemCount + (widget.isLoading && widget.hasMore ? 1 : 0);

    Widget listView = ListView.builder(
      controller: _scrollController,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index >= widget.itemCount) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SkeletonLoader(width: double.infinity, height: 72),
          );
        }
        return widget.itemBuilder(context, index);
      },
    );

    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    return listView;
  }
}
