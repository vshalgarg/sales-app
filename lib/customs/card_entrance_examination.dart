import 'package:flutter/material.dart';

/// Reusable entrance animation for list cards.
/// Cards fade in and move slightly upward, with an optional stagger delay.
class CardEntranceAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const CardEntranceAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<CardEntranceAnimation> createState() => _CardEntranceAnimationState();
}

class _CardEntranceAnimationState extends State<CardEntranceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fade = curved;
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(curved);

    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
