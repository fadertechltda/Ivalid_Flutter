import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Grade de duas colunas cuja altura acompanha o conteúdo de cada card.
///
/// Evita `childAspectRatio` fixo, que corta o botão ou deixa um vão quando o
/// texto muda de tamanho.
class SliverContentGrid extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const SliverContentGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
  });

  @override
  Widget build(BuildContext context) {
    final rows = (itemCount / 2).ceil();
    return SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, row) {
          final left = row * 2;
          final right = left + 1;
          return Padding(
            padding: EdgeInsets.only(bottom: row == rows - 1 ? 0 : spacing),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: itemBuilder(context, left)),
                SizedBox(width: spacing),
                Expanded(
                  child: right < itemCount
                      ? itemBuilder(context, right)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        }, childCount: rows),
      ),
    );
  }
}
