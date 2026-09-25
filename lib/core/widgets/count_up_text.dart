import 'package:flutter/material.dart';

/// Texto numérico que anima de 0 (ou do valor anterior) até [value].
///
/// * Usa algarismos tabulares para o texto não "tremer" durante a animação.
/// * Respeita a opção de acessibilidade "reduzir animações".
class CountUpText extends StatelessWidget {
  final double value;
  final String Function(double value) format;
  final TextStyle style;
  final Duration duration;

  const CountUpText({
    super.key,
    required this.value,
    required this.format,
    required this.style,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    if (MediaQuery.disableAnimationsOf(context)) {
      return Text(format(value), style: textStyle);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => Text(format(animated), style: textStyle),
    );
  }
}
