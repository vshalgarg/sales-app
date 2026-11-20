
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:page_turn_animation/page_turn_animation.dart';

import '../constants/app_spacing.dart';
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

class _LocalPaginationWidgetState<T> extends State<LocalPaginationWidget<T>>
    with SingleTickerProviderStateMixin {
  late final PaginationController controller;

  final GlobalKey _pageKey = GlobalKey();

  int currentPage = 0;

  ui.Image? _capturedPage;
  ui.Image? _targetPage;

  late final AnimationController _turnController;
  late final CurvedAnimation _turnAnimation;

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

    _turnAnimation = CurvedAnimation(
      parent: _turnController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant LocalPaginationWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.items != widget.items) {
      currentPage = 0;
    }
  }

  @override
  void dispose() {
    controller.dispose();

    _capturedPage?.dispose();
    _targetPage?.dispose();

    _turnAnimation.dispose();
    _turnController.dispose();

    super.dispose();
  }

  int get totalPages {
    if (widget.items.isEmpty) return 1;

    return (widget.items.length / widget.pageSize).ceil();
  }

  int get currentCount {
    return ((currentPage + 1) * widget.pageSize)
        .clamp(0, widget.items.length);
  }

  List<T> get currentItems {
    if (widget.items.isEmpty) return [];

    final startIndex = currentPage * widget.pageSize;

    final endIndex = (startIndex + widget.pageSize).clamp(
      0,
      widget.items.length,
    );

    return widget.items.sublist(startIndex, endIndex);
  }

  Future<ui.Image?> _capturePage() async {
    final context = _pageKey.currentContext;

    if (context == null) return null;

    final renderObject = context.findRenderObject();

    if (renderObject is! RenderRepaintBoundary) return null;

    try {
      return await renderObject.toImage(pixelRatio: 2.0);
    } catch (_) {
      return null;
    }
  }

  Future<void> _changePage({
    required int page,
    required bool forward,
  }) async {
    if (_isTurning) return;

    if (page < 0 || page >= totalPages) return;

    if (page == currentPage) return;

    final oldPage = await _capturePage();

    if (oldPage == null || !mounted) return;

    _capturedPage?.dispose();
    _capturedPage = oldPage;

    if (forward) {
      _turnDirection = PageTurnDirection.forward;
      _turnEdge = PageTurnEdge.left;
    } else {
      _turnDirection = PageTurnDirection.backward;
      _turnEdge = PageTurnEdge.left;
    }

    setState(() {
      currentPage = page;
    });

    await WidgetsBinding.instance.endOfFrame;

    if (!mounted) return;

    final newPage = await _capturePage();

    if (newPage == null || !mounted) {
      _disposeImages();
      return;
    }

    _targetPage?.dispose();
    _targetPage = newPage;

    setState(() {
      _isTurning = true;
    });

    _turnController.reset();

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
    }

    _disposeImages();
  }

  Future<void> _nextPage() async {
    if (currentPage >= totalPages - 1) return;

    await controller.execute(
      direction: SwipeDirection.left,
      callback: () async {
        await _changePage(
          page: currentPage + 1,
          forward: true,
        );
      },
    );
  }

  Future<void> _previousPage() async {
    if (currentPage == 0) return;

    await controller.execute(
      direction: SwipeDirection.right,
      callback: () async {
        await _changePage(
          page: currentPage - 1,
          forward: false,
        );
      },
    );
  }

  Future<void> _firstPage() async {
    if (currentPage == 0) return;

    await controller.execute(
      direction: SwipeDirection.right,
      callback: () async {
        await _changePage(
          page: 0,
          forward: false,
        );
      },
    );
  }

  Future<void> _lastPage() async {
    if (currentPage >= totalPages - 1) return;

    await controller.execute(
      direction: SwipeDirection.left,
      callback: () async {
        await _changePage(
          page: totalPages - 1,
          forward: true,
        );
      },
    );
  }

  void _disposeImages() {
    _capturedPage?.dispose();
    _capturedPage = null;

    _targetPage?.dispose();
    _targetPage = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: AppSpacing.lg),
            const Text(
              "Showing Results",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: currentPage == 0 || _isTurning
                  ? null
                  : _firstPage,
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

        const SizedBox(height: AppSpacing.sm),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: (details) async {
                  if (_isTurning) return;

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
                    RepaintBoundary(
                      key: _pageKey,
                      child: _buildCurrentPage(),
                    ),
                    if (_isTurning &&
                        _capturedPage != null &&
                        _targetPage != null)
                      IgnorePointer(
                        child: _turnDirection ==
                            PageTurnDirection.forward
                            ? PageTurnAnimation(
                          image: _capturedPage!,
                          animation: _turnAnimation,
                          direction: PageTurnDirection.forward,
                          edge: PageTurnEdge.left,
                          style: const PageTurnStyle(
                            shadowOpacity: 0.35,
                            shadowBlurRadius: 8,
                            curlIntensity: 1.0,
                          ),
                        )
                            : Stack(
                          fit: StackFit.expand,
                          children: [
                            RawImage(
                              image: _capturedPage!,
                              fit: BoxFit.fill,
                            ),
                            PageTurnAnimation(
                              image: _targetPage!,
                              animation: _turnAnimation,
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

        if (!mounted) return;

        setState(() {
          currentPage = 0;
        });
      },
      child: ListView.separated(
        key: ValueKey("page_$currentPage"),
        padding: const EdgeInsets.only(bottom: 100),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: currentItems.length,
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: AppSpacing.cardSeparator,
          );
        },
        itemBuilder: (context, index) {
          return widget.itemBuilder(
            context,
            currentItems[index],
          );
        },
      ),
    );
  }
}
