import 'dart:developer';

import 'package:flutter/material.dart';

import '../model_classes/common/pagination_state.dart';
import 'pagination_controller.dart';

class PaginationWidget<T> extends StatefulWidget {
  final PaginationState pagination;

  final List<T> items;

  final bool loading;

  final Future<void> Function(int page) fetchPage;

  final Future<void> Function() refresh;

  final Widget Function(BuildContext context, T item) itemBuilder;

  const PaginationWidget({
    super.key,
    required this.pagination,
    required this.items,
    required this.loading,
    required this.fetchPage,
    required this.refresh,
    required this.itemBuilder,
  });

  @override
  State<PaginationWidget<T>> createState() =>
      _PaginationWidgetState<T>();
}

class _PaginationWidgetState<T>
    extends State<PaginationWidget<T>>
    with SingleTickerProviderStateMixin {

  late final PaginationController controller;

  @override
  void initState() {
    super.initState();

    controller = PaginationController();
  }

  Future<void> _nextPage() async {

    if (widget.pagination.currentPage >= widget.pagination.lastValidPage) {
      return;
    }

    await controller.execute(
      direction: SwipeDirection.right,
      callback: () async {
        await widget.fetchPage(
          widget.pagination.currentPage + 1,
        );
      },
    );
  }

  Future<void> _previousPage() async {
    if (widget.pagination.currentPage == 0) {
      return;
    }

    await controller.execute(
      direction: SwipeDirection.left,
      callback: () async {
        await widget.fetchPage(
          widget.pagination.currentPage - 1,
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final currentCount = ((widget.pagination.currentPage + 1) *
        widget.pagination.pageSize)
        .clamp(0, widget.pagination.totalElements);

    return Column(
      children: [

        Row(
          children: [

            const Text(
              "Showing Results",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            IconButton(
              onPressed:
              widget.pagination.currentPage == 0
                  ? null
                  : () {
                widget.fetchPage(0);
              },
              icon: const Icon(
                Icons.keyboard_double_arrow_left,
              ),
            ),

            Text(
              "$currentCount of ${widget.pagination.totalElements}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            IconButton(
              onPressed: widget.pagination.currentPage >=
                  widget.pagination.lastValidPage
                  ? null
                  : () async {
                await widget.fetchPage(widget.pagination.lastValidPage);
              },
              icon: const Icon(Icons.keyboard_double_arrow_right),
            ),
          ],
        ),

        const SizedBox(height: 5),

        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) async {
              final velocity = details.primaryVelocity ?? 0;

              if (velocity < -250) {
                await _nextPage();
              }

              if (velocity > 250) {
                await _previousPage();
              }
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                final begin = controller.direction == SwipeDirection.left
                    ? const Offset(1, 0)
                    : const Offset(-1, 0);

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: begin,
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
              child: widget.loading
                  ? const Center(
                key: ValueKey('pagination_loading'),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              )
                  : RefreshIndicator(
                key: ValueKey(
                  '${widget.pagination.currentPage}_'
                      '${widget.items.length}_'
                      '${widget.items.isNotEmpty ? widget.items.first.hashCode : 0}',
                ),
                onRefresh: widget.refresh,
                child: widget.items.isEmpty
                    ? const Center(
                  child: Text(
                    "No Data Found",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    return widget.itemBuilder(
                      context,
                      widget.items[index],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}