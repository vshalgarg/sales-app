import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:page_turn_animation/page_turn_animation.dart';

import 'pagination_controller.dart';

class LocalPaginationWidget<T> extends StatefulWidget {
  final List<T> items;
  final int pageSize;
  final Future<void> Function() refresh;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final bool loading;
  const LocalPaginationWidget({
    super.key,
    required this.items,
    required this.pageSize,
    required this.refresh,
    required this.itemBuilder,
    this.loading = false,
  });

  @override
  State<LocalPaginationWidget<T>> createState() =>
      _LocalPaginationWidgetState<T>();
}

class _LocalPaginationWidgetState<T> extends State<LocalPaginationWidget<T>>
    with SingleTickerProviderStateMixin {
  late final PaginationController controller;

  final GlobalKey _pageKey = GlobalKey();

  int currentPage = 0;

  ui.Image? _capturedPage;
  ui.Image? _destinationPage;

  late final AnimationController _turnController;

  bool _isTurning = false;

  PageTurnDirection _turnDirection = PageTurnDirection.forward;
  PageTurnEdge _turnEdge = PageTurnEdge.left;

  @override
  void initState() {
    super.initState();

    controller = PaginationController();

    _turnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void didUpdateWidget(covariant LocalPaginationWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.items, widget.items)) {
      _turnController.stop();
      _turnController.reset();

      _disposeImages();

      setState(() {
        currentPage = 0;
        _isTurning = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();

    _capturedPage?.dispose();
    _destinationPage?.dispose();

    _turnController.dispose();

    super.dispose();
  }

  // PAGINATION

  int get totalPages {
    if (widget.items.isEmpty) {
      return 1;
    }

    return (widget.items.length / widget.pageSize).ceil();
  }

  int get currentCount {
    return ((currentPage + 1) * widget.pageSize).clamp(0, widget.items.length);
  }

  List<T> get currentItems {
    if (widget.items.isEmpty) {
      return [];
    }

    final startIndex = currentPage * widget.pageSize;

    final endIndex = (startIndex + widget.pageSize).clamp(
      0,
      widget.items.length,
    );

    return widget.items.sublist(startIndex, endIndex);
  }

  // CAPTURE PAGE

  Future<ui.Image?> _capturePage() async {
    final context = _pageKey.currentContext;

    if (context == null) {
      return null;
    }

    final renderObject = context.findRenderObject();

    if (renderObject is! RenderRepaintBoundary) {
      return null;
    }

    try {
      return await renderObject.toImage(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
    } catch (_) {
      return null;
    }
  }

  // PAGE TURN
  //
  // This intentionally follows Supplier's PaginationWidget:
  // - capture the currently visible page
  // - animate that captured page with PageTurnDirection.forward
  // - use the left edge for next and right edge for previous
  // - keep the destination page underneath the turning image
  Future<void> _changePage({
    required int page,
    required bool forward,
  }) async {
    if (_isTurning) return;
    if (page < 0 || page >= totalPages || page == currentPage) return;

    final currentPageImage = await _capturePage();
    if (currentPageImage == null || !mounted) return;

    _capturedPage?.dispose();
    _capturedPage = currentPageImage;

    // Match Supplier's exact direction/edge strategy.
    _turnDirection = PageTurnDirection.forward;
    _turnEdge = forward ? PageTurnEdge.left : PageTurnEdge.right;

    // Switch to the destination page and let Flutter lay it out and paint.
    _turnController.reset();
    _destinationPage?.dispose();
    _destinationPage = null;
    setState(() {
      currentPage = page;
    });

// Wait for the destination page to build and paint.
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      _disposeImages();
      return;
    }

// Give ListView.builder another frame to render its children.
    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) {
      _disposeImages();
      return;
    }

// Capture the fully rendered destination page.
    _destinationPage = await _capturePage();

    if (!mounted || _destinationPage == null) {
      _disposeImages();
      return;
    }

    setState(() {
      _isTurning = true;
    });

    await WidgetsBinding.instance.endOfFrame;

    try {
      await _turnController.forward();

      if (!mounted) return;

      setState(() {
        _isTurning = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isTurning = false;
      });
    } finally {
      _disposeImages();
    }
  }

  // NEXT

  Future<void> _nextPage() async {
    if (currentPage >= totalPages - 1) {
      return;
    }

    await controller.execute(
      direction: SwipeDirection.left,
      callback: () async {
        await _changePage(page: currentPage + 1, forward: true);
      },
    );
  }

  // PREVIOUS

  Future<void> _previousPage() async {
    if (currentPage == 0) {
      return;
    }

    await controller.execute(
      direction: SwipeDirection.right,
      callback: () async {
        await _changePage(page: currentPage - 1, forward: false);
      },
    );
  }

  // FIRST

  Future<void> _firstPage() async {
    if (currentPage == 0) {
      return;
    }

    await controller.execute(
      direction: SwipeDirection.right,
      callback: () async {
        await _changePage(page: 0, forward: false);
      },
    );
  }

  // LAST

  Future<void> _lastPage() async {
    if (currentPage >= totalPages - 1) {
      return;
    }

    await controller.execute(
      direction: SwipeDirection.left,
      callback: () async {
        await _changePage(page: totalPages - 1, forward: true);
      },
    );
  }

  // DISPOSE CAPTURED IMAGES

  void _disposeImages() {
    _capturedPage?.dispose();
    _capturedPage = null;
    _destinationPage?.dispose();
    _destinationPage = null;
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER
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
              onPressed: currentPage == 0 || _isTurning ? null : _firstPage,
              icon: Icon(
                Icons.keyboard_double_arrow_left,
                color: currentPage == 0 || _isTurning
                    ? Colors.white38
                    : Colors.white,
              ),
            ),

            Text(
              "$currentCount of ${widget.items.length}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            IconButton(
              onPressed: currentPage >= totalPages - 1 || _isTurning
                  ? null
                  : _lastPage,
              icon: Icon(
                Icons.keyboard_double_arrow_right,
                color: currentPage >= totalPages - 1 || _isTurning
                    ? Colors.white38
                    : Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // PAGE
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,

                onHorizontalDragEnd: (details) async {
                  if (_isTurning) {
                    return;
                  }

                  final velocity = details.primaryVelocity ?? 0;

                  // SWIPE LEFT ΓåÆ NEXT PAGE
                  if (velocity < -250) {
                    await _nextPage();
                  }
                  // SWIPE RIGHT ΓåÆ PREVIOUS PAGE
                  else if (velocity > 250) {
                    await _previousPage();
                  }
                },

                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ----------------------------------------------------------------
                    // CURRENT LIVE PAGE
                    // ----------------------------------------------------------------
                    RepaintBoundary(key: _pageKey, child: _buildCurrentPage()),

                    // Use the captured destination as an opaque page underneath
                    // the turning image. The live page remains mounted below
                    // so the RepaintBoundary can be captured on the next turn.
                    if (_isTurning && _destinationPage != null)
                      Positioned.fill(
                        child: RawImage(
                          image: _destinationPage,
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                        ),
                      ),

                    // ----------------------------------------------------------------
                    // PAGE TURN
                    // ----------------------------------------------------------------
                    if (_isTurning && _capturedPage != null)
                      IgnorePointer(
                        child: PageTurnAnimation(
                          image: _capturedPage!,
                          animation: _turnController,
                          direction: PageTurnDirection.forward,
                          edge: _turnEdge,
                          style: const PageTurnStyle(
                            shadowOpacity: 0.35,
                            shadowBlurRadius: 8,
                            curlIntensity: 1.0,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // CURRENT PAGE CONTENT

  Widget _buildCurrentPage() {
    if (widget.loading && currentPage == 0) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (widget.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 250),
            Center(
              child: Text(
                "No Data Found",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await widget.refresh();

        if (!mounted) {
          return;
        }

        setState(() {
          currentPage = 0;
        });
      },
      child: ListView.builder(
        key: ValueKey("page_$currentPage"),
        padding: const EdgeInsets.only(bottom: 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: currentItems.length,
        itemBuilder: (context, index) {
          return widget.itemBuilder(context, currentItems[index]);
        },
      ),
    );
  }
}
