import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Cabeçalho padrão das abas: ícone e ações em 44×44, título 22 e subtítulo 13.
///
/// A margem horizontal segue [AppSpacing.screen], para o conteúdo das cinco
/// abas começar no mesmo eixo.
class PageHeader extends StatelessWidget {
  static const double controlSize = 44;

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final List<Widget> actions;
  final Color? titleColor;
  final Color? subtitleColor;
  final EdgeInsetsGeometry padding;

  const PageHeader({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.actions = const [],
    this.titleColor,
    this.subtitleColor,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.screen,
      AppSpacing.lg,
      AppSpacing.screen,
      0,
    ),
  });

  /// Caixa 44×44 usada como ícone principal ou botão de ação.
  ///
  /// Com [expandChild], o filho recebe a caixa inteira (útil para um `Stack`
  /// com selo, como o carrinho). Sem isso, o filho fica centralizado.
  static Widget iconSlot({
    required Widget child,
    Color? backgroundColor,
    VoidCallback? onTap,
    List<BoxShadow>? boxShadow,
    double radius = AppRadius.tile,
    bool expandChild = false,
    String? semanticLabel,
  }) {
    final content = SizedBox(
      width: controlSize,
      height: controlSize,
      child: expandChild ? child : Center(child: child),
    );

    final slot = Container(
      width: controlSize,
      height: controlSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      ),
    );

    if (semanticLabel == null) return slot;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      excludeSemantics: true,
      child: slot,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget? subtitleChild =
        subtitleWidget ??
        (subtitle == null
            ? null
            : Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: subtitleColor ?? context.onBgMuted,
                ),
              ));

    return Padding(
      padding: padding,
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: titleColor ?? context.onBg,
                  ),
                ),
                if (subtitleChild != null) ...[
                  const SizedBox(height: 2),
                  subtitleChild,
                ],
              ],
            ),
          ),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            actions[i],
          ],
        ],
      ),
    );
  }
}
