import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Título de seção padrão: barra vertical de destaque + texto Inter w800/16.
/// Mesmo visual usado em "Escolha itens para doar".
class SectionTitle extends StatelessWidget {
  final String title;
  final Color barColor;
  final Widget? trailing;

  const SectionTitle(
    this.title, {
    super.key,
    this.barColor = AppColors.redPrimary,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.onBg,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
