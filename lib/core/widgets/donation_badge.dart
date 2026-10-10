import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Selo "DOAÇÃO" usado para diferenciar itens destinados a ONGs (carrinho e
/// checkout). Usa o verde do fluxo solidário e texto, não só cor.
class DonationBadge extends StatelessWidget {
  const DonationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.textOn(AppColors.greenAccent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.softBg(AppColors.greenAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_rounded, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            'DOAÇÃO',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
