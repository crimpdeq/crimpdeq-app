import 'package:flutter/material.dart';

class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber({
    super.key,
    required this.value,
    this.fractionDigits = 1,
    this.style,
    this.suffix,
    this.duration = const Duration(milliseconds: 200),
  });

  final double value;
  final int fractionDigits;
  final TextStyle? style;
  final String? suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, animatedValue, _) {
        final text = animatedValue.toStringAsFixed(fractionDigits);
        return Text(
          suffix != null ? '$text$suffix' : text,
          style: style,
        );
      },
    );
  }
}
