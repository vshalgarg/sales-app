import 'package:flutter/material.dart';

import 'pagination_controller.dart';

class LocalPaginationWidget<T> extends StatefulWidget {
  final List<T> items;

  final int pageSize;

  final Future<void> Function() refresh;

  final Widget Function(BuildContext context, T item) itemBuilder;

  const LocalPaginationWidget({
    super.key,
    required this.items,
    required this.pageSize,
    required this.refresh,
    required this.itemBuilder,
  });

  @override
  State<LocalPaginationWidget<T>> createState() =>
      _LocalPaginationWidgetState<T>();
}

class _LocalPaginationWidgetState<T>
    extends State<LocalPaginationWidget<T>> {
  late final PaginationController controller;

  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    controller = PaginationController();
  }
  @override
  void didUpdateWidget(covariant LocalPaginationWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items != widget.items) {
      setState(() {
        currentPage = 0;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  int get totalPages {
    if (widget.items.isEmpty) {
      return 1;
    }

    return (widget.items.length / widget.pageSize).ceil();
  }

  int get currentCount {
    return ((currentPage + 1) * widget.pageSize)
        .clamp(0, widget.items.length);
  }

  List<T> get currentItems {
    if (widget.items.isEmpty) {
      return [];
    }

    final startIndex = currentPage * widget.pageSize;

    final endIndex = (startIndex + widget.pageSize)
        .clamp(0, widget.items.length);

    return widget.items.sublist(
      startIndex,
      endIndex,
    );
  }

  Future<void> _nextPage() async {
    if (currentPage >= totalPages - 1) {
      return;
    }

    await controller.execute(
      direction: SwipeDirection.left,
      callback: () async {
        if (!mounted) return;

        setState(() {
          currentPage++;
        });
      },
    );
  }

  Future<void> _previousPage() async {
    if (currentPage == 0) {
      return;
    }

    await controller.execute(
      direction: SwipeDirection.right,
      callback: () async {
        if (!mounted) return;

        setState(() {
          currentPage--;
        });
      },
    );
  }

  Future<void> _firstPage() async {
    if (currentPage == 0) {
      return;
    }

    await controller.execute(
      direction: SwipeDirection.right,
      callback: () async {
        if (!mounted) return;

        setState(() {
          currentPage = 0;
        });
      },
    );
  }

  Future<void> _lastPage() async {
    if (currentPage >= totalPages - 1) {
      return;
    }

    await controller.execute(
      direction: SwipeDirection.left,
      callback: () async {
        if (!mounted) return;

        setState(() {
          currentPage = totalPages - 1;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ================= PAGINATION HEADER =================

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

            // FIRST PAGE
            IconButton(
              onPressed:
              currentPage == 0 ? null : _firstPage,
              icon: Icon(
                Icons.keyboard_double_arrow_left,
                color: currentPage == 0
                    ? Colors.white38
                    : Colors.white,
              ),
            ),

            // COUNT
            Text(
              "$currentCount of ${widget.items.length}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            // LAST PAGE
            IconButton(
              onPressed:
              currentPage >= totalPages - 1
                  ? null
                  : _lastPage,
              icon: Icon(
                Icons.keyboard_double_arrow_right,
                color: currentPage >= totalPages - 1
                    ? Colors.white38
                    : Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // ================= LIST =================

        Expanded(
          child: GestureDetector(
            onHorizontalDragEnd: (details) async {
              final velocity =
                  details.primaryVelocity ?? 0;

              // Swipe LEFT
              if (velocity < -250) {
                await _nextPage();
              }

              // Swipe RIGHT
              if (velocity > 250) {
                await _previousPage();
              }
            },

            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),

              transitionBuilder: (
                  child,
                  animation,
                  ) {
                final begin =
                controller.direction ==
                    SwipeDirection.left
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

              child: RefreshIndicator(
                key: ValueKey(currentPage),

                onRefresh: () async {
                  await widget.refresh();

                  if (!mounted) return;

                  setState(() {
                    currentPage = 0;
                  });
                },

                child: currentItems.isEmpty
                    ? const Center(
                  child: Text(
                    "No Data Found",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                )
                    : ListView.builder(
                  physics:
                  const AlwaysScrollableScrollPhysics(),

                  itemCount: currentItems.length,

                  itemBuilder: (context, index) {
                    return widget.itemBuilder(
                      context,
                      currentItems[index],
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