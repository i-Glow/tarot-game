import 'package:flutter/material.dart';

/// A reusable text animation that moves from bottom to top, slowing in the center
class VerticalTextAnimation extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback? onComplete;
  final Duration duration;

  const VerticalTextAnimation({
    super.key,
    required this.text,
    this.textStyle,
    this.onComplete,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<VerticalTextAnimation> createState() => _VerticalTextAnimationState();
}

class _VerticalTextAnimationState extends State<VerticalTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Position animation: start slightly above center, slide to exact center
    _positionAnimation = Tween<double>(
      begin: -0.3, // Start a bit above center
      end: 0.0, // End at exact center (Alignment.center)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Opacity animation: fade in, stay visible, then quick fade out
    _opacityAnimation = TweenSequence<double>([
      // Fade in
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      // Stay visible
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 50),
      // Quick fade out
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fill(
          child: Align(
            alignment: Alignment(0, _positionAnimation.value),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Text(
                widget.text,
                style:
                    widget.textStyle ??
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
