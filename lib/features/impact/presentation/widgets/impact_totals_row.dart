import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../domain/models/impact_metrics.dart';

/// Linha com os três indicadores de impacto (salvos, doados, economizados),
/// no mesmo formato do Impact Card da aba Doação. Usada no card do Perfil e na
/// tela da calculadora.
class ImpactTotalsRow extends StatelessWidget {
  final ImpactMetrics metrics;

  const ImpactTotalsRow({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final divider = Container(
      width: 1,
      height: 40,
      color: context.outline.withValues(alpha: 0.5),
    );

    return Row(
      children: [
        Expanded(
          child: StatTile(
            icon: Icons.eco_rounded,
            value: formatCount(metrics.totalItems),
            label: 'Itens salvos',
            color: AppColors.greenAccent,
          ),
        ),
        divider,
        Expanded(
          child: StatTile(
            icon: Icons.volunteer_activism_rounded,
            value: formatCount(metrics.itemsDonated),
            label: 'Itens doados',
            color: AppColors.redPrimary,
          ),
        ),
        divider,
        Expanded(
          child: StatTile(
            icon: Icons.savings_rounded,
            value: formatReais(metrics.savedReais),
            label: 'Economizados',
            color: AppColors.yellowAccent,
          ),
        ),
      ],
    );
  }
}
