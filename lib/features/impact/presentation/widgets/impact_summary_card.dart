import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ivalid_card.dart';
import '../pages/impact_calculator_page.dart';
import '../providers/impact_provider.dart';
import 'impact_totals_row.dart';

/// Card "Seu impacto" exibido no Perfil. Mostra os totais do usuário e leva à
/// calculadora completa ao toque.
class ImpactSummaryCard extends StatelessWidget {
  const ImpactSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final totals = context.watch<ImpactProvider>().totals;
    final green = context.accent(AppColors.greenAccent);

    return IvalidCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ImpactCalculatorPage()),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.softBg(AppColors.greenAccent),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.eco_rounded, color: green, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seu impacto',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: context.onBg,
                      ),
                    ),
                    Text(
                      totals.isEmpty
                          ? 'Simule e acompanhe seu impacto'
                          : 'Toque para simular seu impacto',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: context.onBgAlpha(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.onBgAlpha(0.35),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ImpactTotalsRow(metrics: totals),
        ],
      ),
    );
  }
}
