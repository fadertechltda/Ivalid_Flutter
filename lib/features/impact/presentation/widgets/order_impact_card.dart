import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/ivalid_card.dart';
import '../../domain/models/impact_metrics.dart';

/// Mini-card do checkout: mostra o impacto do pedido antes de confirmar.
/// Não aparece quando o carrinho está vazio.
class OrderImpactCard extends StatelessWidget {
  final ImpactMetrics metrics;

  const OrderImpactCard({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    if (metrics.totalItems == 0) return const SizedBox.shrink();

    final green = context.accent(AppColors.greenAccent);

    final parts = <String>[];
    if (metrics.itemsRescued > 0) {
      parts.add('${pluralize(metrics.itemsRescued, 'item resgatado', 'itens resgatados')} do desperdício');
    }
    if (metrics.itemsDonated > 0) {
      parts.add('${pluralize(metrics.itemsDonated, 'item doado', 'itens doados')} a ONGs parceiras');
    }

    return IvalidCard(
      // softBg é translúcido; compõe sobre a superfície para não deixar a
      // sombra do card aparecer por baixo do fundo.
      color: Color.alphaBlend(
        context.softBg(AppColors.greenAccent),
        context.surface,
      ),
      borderColor: AppColors.greenAccent.withValues(alpha: 0.25),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.eco_rounded, color: green, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Impacto deste pedido',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  parts.join(' · '),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: context.onBgAlpha(0.75),
                  ),
                ),
                if (metrics.savedReais > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Você economiza ${formatReais(metrics.savedReais)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.onBgAlpha(0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
