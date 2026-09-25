import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Card padrão do design system Ivalid: superfície do tema, cantos de raio 18 e
/// sombra suave. Reproduz o "Impact Card" da aba Doação, agora reutilizável.
///
/// Se [onTap] for informado, o card ganha efeito de toque (ripple).
class IvalidCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Cor de fundo; por padrão usa `context.surface`.
  final Color? color;

  /// Borda opcional (ex.: cards com tom de destaque).
  final Color? borderColor;

  final double radius;

  const IvalidCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color,
    this.borderColor,
    this.radius = AppRadius.card,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: color ?? context.surface,
        clipBehavior: Clip.antiAlias,
        // `shape` e `borderRadius` não podem coexistir no Material: a borda
        // (opcional) e o raio vão juntos no shape.
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: borderColor == null
              ? BorderSide.none
              : BorderSide(color: borderColor!),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
