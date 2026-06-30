import 'dart:math';
import 'package:flutter/material.dart';

/// A beautiful, stateless typing indicator chat bubble.
/// The animated dots are handled by a self-contained child widget.
class TypingBubble extends StatelessWidget {
  final Color bubbleColor;
  final Color dotColor;
  final double radius;
  final EdgeInsets padding;

  const TypingBubble({
    super.key,
    this.bubbleColor = Colors.grey,
    this.dotColor = Colors.black54,
    this.radius = 20.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: padding,
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bubbleColor,
            bubbleColor.withOpacity(0.8),
          ],
        ),
      ),
      child: const _AnimatedDots(),
    );
  }
}

// ─── Animated dots (stateful, but hidden inside the stateless bubble) ───
class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = Theme.of(context).primaryColor.withOpacity(0.7);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(3, (index) {
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.25,
            index * 0.25 + 0.5,
            curve: Curves.easeInOut,
          ),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.7, end: 1.3).animate(animation),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.4, end: 1.0).animate(animation),
              child: CircleAvatar(
                radius: 6,
                backgroundColor: dotColor,
              ),
            ),
          ),
        );
      }),
    );
  }
}