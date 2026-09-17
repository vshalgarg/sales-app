import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:page_turn_animation/page_turn_animation.dart';

import '../model_classes/common/pagination_state.dart';

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
  State<PaginationWidget<T>> createState() => _PaginationWidgetState<T>();
}

class _PaginationWidgetState<T> extends State<PaginationWidget<T>>
    with SingleTickerProviderStateMixin {
  // PAGE CAPTURE

  final GlobalKey _pageKey = GlobalKey();

  ui.Image? _capturedPage;
  ui.Image? _targetPage;

  // ANIMATION

  late final AnimationController _turnController;

  late final CurvedAnimation _turnAnimation;

  bool _isTurning = false;

  bool _isFetching = false;

  PageTurnDirection _turnDirection = PageTurnDirection.forward;

  PageTurnEdge _turnEdge = PageTurnEdge.right;

  @override
  void initState() {
    super.initState();

    _turnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _turnAnimation = CurvedAnimation(
      parent: _turnController,
      curve: Curves.decelerate,
    );
  }

  @override
  void dispose() {
    _capturedPage?.dispose();
    _turnController.dispose();
    _turnAnimation.dispose();
    _targetPage?.dispose();
    super.dispose();
  }

  // CAPTURE CURRENT PAGE

  Future<ui.Image?> _captureCurrentPage() async {
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

  // START PAGE TURN

  Future<void> _changePage({required int page, required bool forward}) async {
    if (_isTurning || _isFetching || widget.loading) {
      return;
    }

    // Capture current page BEFORE API call.
    final currentPageImage = await _captureCurrentPage();

    if (currentPageImage == null || !mounted) {
      return;
    }

    _capturedPage?.dispose();
    _capturedPage = currentPageImage;

    if (forward) {
      _turnDirection = PageTurnDirection.forward;
      _turnEdge = PageTurnEdge.left;

      setState(() {
        _isTurning = true;
        _isFetching = true;
      });

      _turnController.reset();

      // Start curl immediately.
      final animationFuture = _turnController.forward();

      try {
        // Fetch NEXT page while curl is happening.
        await widget.fetchPage(page);

        if (!mounted) return;

        _isFetching = false;

        // Wait for curl to finish.
        await animationFuture;

        if (!mounted) return;

        setState(() {
          _isTurning = false;
        });

        _disposeCapturedPage();
      } catch (_) {
        _isFetching = false;

        if (mounted) {
          await _turnController.reverse();

          if (!mounted) return;

          setState(() {
            _isTurning = false;
          });
        }

        _disposeCapturedPage();
      }
    } else {
      try {
        _isFetching = true;

        await widget.fetchPage(page);

        if (!mounted) return;

        _isFetching = false;

        final previousPageImage = await _captureCurrentPage();

        if (previousPageImage == null || !mounted) {
          return;
        }

        _targetPage?.dispose();
        _targetPage = previousPageImage;

        _turnDirection = PageTurnDirection.backward;
        _turnEdge = PageTurnEdge.right;

        setState(() {
          _isTurning = true;
        });

        _turnController.reset();

        await _turnController.forward();

        if (!mounted) return;

        setState(() {
          _isTurning = false;
        });

        _disposeCapturedPage();

        _targetPage?.dispose();
        _targetPage = null;
      } catch (_) {
        if (!mounted) return;

        setState(() {
          _isTurning = false;
          _isFetching = false;
        });

        _disposeCapturedPage();

        _targetPage?.dispose();
        _targetPage = null;
      }
    }
  }

  // RUN ANIMATION

  Future<void> _runTurnAnimation() async {
    try {
      await _turnController.forward();
    } catch (_) {}
  }

  // DISPOSE IMAGE

  void _disposeCapturedPage() {
    _capturedPage?.dispose();
    _capturedPage = null;
  }

  // NEXT

  Future<void> _nextPage() async {
    if (widget.pagination.currentPage >= widget.pagination.lastValidPage) {
      return;
    }

    await _changePage(page: widget.pagination.currentPage + 1, forward: true);
  }

  // PREVIOUS

  Future<void> _previousPage() async {
    if (widget.pagination.currentPage <= 0) {
      return;
    }

    await _changePage(page: widget.pagination.currentPage - 1, forward: false);
  }

  // FIRST

  Future<void> _firstPage() async {
    if (widget.pagination.currentPage == 0) {
      return;
    }

    await _changePage(page: 0, forward: false);
  }

  // LAST

  Future<void> _lastPage() async {
    if (widget.pagination.currentPage >= widget.pagination.lastValidPage) {
      return;
    }

    await _changePage(page: widget.pagination.lastValidPage, forward: true);
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    final currentCount =
        ((widget.pagination.currentPage + 1) * widget.pagination.pageSize)
            .clamp(0, widget.pagination.totalElements);

    return Column(
      children: [
        // HEADER
        Row(
          children: [
            const Text(
              'Showing Results',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            // FIRST PAGE
            IconButton(
              onPressed:
                  _isTurning ||
                      widget.loading ||
                      widget.pagination.currentPage == 0
                  ? null
                  : _firstPage,
              icon: const Icon(Icons.keyboard_double_arrow_left),
            ),

            Text(
              '$currentCount of '
              '${widget.pagination.totalElements}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            // LAST PAGE
            IconButton(
              onPressed:
                  _isTurning ||
                      widget.loading ||
                      widget.pagination.currentPage >=
                          widget.pagination.lastValidPage
                  ? null
                  : _lastPage,
              icon: const Icon(Icons.keyboard_double_arrow_right),
            ),
          ],
        ),

        const SizedBox(height: 5),

        // PAGE CONTENT
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              final availableHeight = constraints.maxHeight;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,

                onHorizontalDragEnd: (details) async {
                  if (_isTurning || _isFetching || widget.loading) {
                    return;
                  }

                  final velocity = details.primaryVelocity ?? 0;

                  if (velocity < -250) {
                    await _nextPage();
                  } else if (velocity > 250) {
                    await _previousPage();
                  }
                },

                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RepaintBoundary(key: _pageKey, child: _buildCurrentPage()),

                    if (_isTurning)
                      IgnorePointer(
                        child: _turnDirection == PageTurnDirection.forward
                            ? PageTurnAnimation(
                                image: _capturedPage!,
                                animation: _turnAnimation,
                                direction: PageTurnDirection.forward,
                                edge: _turnEdge,
                                style: const PageTurnStyle(
                                  shadowOpacity: 0.35,
                                  shadowBlurRadius: 8,
                                  curlIntensity: 1.0,
                                ),
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (_capturedPage != null)
                                    RawImage(
                                      image: _capturedPage,
                                      fit: BoxFit.fill,
                                    ),

                                  if (_targetPage != null)
                                    PageTurnAnimation(
                                      image: _targetPage!,
                                      animation: _turnController,
                                      direction: PageTurnDirection.backward,
                                      edge: PageTurnEdge.left,
                                      style: const PageTurnStyle(
                                        shadowOpacity: 0.35,
                                        shadowBlurRadius: 8,
                                        curlIntensity: 1.0,
                                      ),
                                    ),
                                ],
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

  // CURRENT PAGE

  Widget _buildCurrentPage() {
    if (widget.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 250),
            Center(
              child: Text(
                'No Data Found',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.refresh,
      child: ListView.builder(
        key: ValueKey('page_${widget.pagination.currentPage}'),
        padding: const EdgeInsets.only(bottom: 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          return widget.itemBuilder(context, widget.items[index]);
        },
      ),
    );
  }
}
