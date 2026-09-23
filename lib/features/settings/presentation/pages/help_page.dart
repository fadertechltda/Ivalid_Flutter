import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ivalid/core/theme/app_colors.dart';

import '../widgets/settings_widgets.dart';

/// Central de ajuda — perguntas frequentes e canais de contato.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const List<({String question, String answer})> _faq = [
    (
      question: 'O que é o Ivalid?',
      answer:
          'É um app que reúne produtos próximos da data de validade com '
          'descontos. Assim você economiza e ajuda a reduzir o desperdício '
          'de alimentos.',
    ),
    (
      question: 'Os produtos estão vencidos?',
      answer:
          'Não. Todos os produtos estão dentro do prazo de validade. O selo '
          'em cada anúncio mostra quantos dias faltam para vencer.',
    ),
    (
      question: 'Como funciona o Ivalid Pago?',
      answer:
          'É a carteira do app. Você pode adicionar saldo, cadastrar cartões '
          'e usar o cashback recebido por doações nas suas compras.',
    ),
    (
      question: 'Como funcionam as doações?',
      answer:
          'Ao doar produtos ou valores você sobe de nível (Bronze, Prata e '
          'Ouro) e aumenta o percentual de cashback das suas compras.',
    ),
    (
      question: 'Como acompanho meu pedido?',
      answer:
          'Na aba Pedidos você vê o status em tempo real, desde a confirmação '
          'até a retirada na loja.',
    ),
    (
      question: 'Esqueci minha senha, e agora?',
      answer:
          'Vá em Configurações > Segurança > Alterar senha. Enviaremos um '
          'link de redefinição para o e-mail da sua conta.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.onBg),
        title: Text(
          'Central de ajuda',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: context.onBg,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          const SettingsSectionLabel('Perguntas frequentes'),
          Container(
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.outline.withValues(alpha: 0.4)),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Column(
                children: [
                  for (final item in _faq)
                    ExpansionTile(
                      iconColor: AppColors.redPrimary,
                      collapsedIconColor: context.onBgAlpha(0.4),
                      title: Text(
                        item.question,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.onBg,
                        ),
                      ),
                      childrenPadding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.answer,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.5,
                            color: context.onBgAlpha(0.65),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SettingsSectionLabel('Fale com a gente'),
          SettingsCard(
            children: [
              SettingsTile(
                icon: Icons.email_outlined,
                title: 'suporte@ivalid.com.br',
                subtitle: 'Toque para copiar o e-mail',
                onTap: () => _copy(context, 'suporte@ivalid.com.br'),
              ),
              SettingsTile(
                icon: Icons.phone_in_talk_outlined,
                title: '0800 123 4567',
                subtitle: 'Seg. a sex., das 8h às 18h',
                iconColor: AppColors.greenAccent,
                onTap: () => _copy(context, '08001234567'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copiado: $value'),
        backgroundColor: AppColors.greenAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
