import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ivalid/core/providers/settings_provider.dart';
import 'package:ivalid/core/theme/app_colors.dart';

import '../widgets/settings_widgets.dart';
import 'account_data_page.dart';
import 'help_page.dart';
import 'security_page.dart';

/// Tela de Configurações — tema, notificações, conta e suporte.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.onBg),
        title: Text(
          'Configurações',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: context.onBg,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          const SettingsSectionLabel('Aparência'),
          SettingsCard(
            children: [
              SettingsSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Modo escuro',
                subtitle: 'Reduz o brilho e economiza bateria',
                value: settings.isDarkMode,
                onChanged: (v) => settings.toggleDarkMode(v),
              ),
              _ThemeModeSelector(settings: settings),
            ],
          ),

          const SettingsSectionLabel('Notificações'),
          SettingsCard(
            children: [
              SettingsSwitchTile(
                icon: Icons.notifications_active_outlined,
                title: 'Notificações push',
                subtitle: 'Receber alertas no celular',
                value: settings.pushEnabled,
                onChanged: (v) => settings.setPushEnabled(v),
              ),
              SettingsSwitchTile(
                icon: Icons.local_offer_outlined,
                title: 'Ofertas e promoções',
                subtitle: 'Produtos perto do vencimento com desconto',
                value: settings.offersEnabled,
                onChanged: settings.pushEnabled
                    ? (v) => settings.setOffersEnabled(v)
                    : null,
              ),
              SettingsSwitchTile(
                icon: Icons.receipt_long_outlined,
                title: 'Status dos pedidos',
                subtitle: 'Avisos sobre preparo e retirada',
                value: settings.ordersEnabled,
                onChanged: settings.pushEnabled
                    ? (v) => settings.setOrdersEnabled(v)
                    : null,
              ),
              SettingsSwitchTile(
                icon: Icons.volume_up_outlined,
                title: 'Som das notificações',
                value: settings.soundEnabled,
                onChanged: (v) => settings.setSoundEnabled(v),
              ),
            ],
          ),

          const SettingsSectionLabel('Conta'),
          SettingsCard(
            children: [
              SettingsTile(
                icon: Icons.person_outline_rounded,
                title: 'Dados da conta',
                subtitle: 'Nome, e-mail e informações do perfil',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountDataPage()),
                ),
              ),
              SettingsTile(
                icon: Icons.security_outlined,
                title: 'Segurança',
                subtitle: 'Senha e verificação de e-mail',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SecurityPage()),
                ),
              ),
            ],
          ),

          const SettingsSectionLabel('Suporte'),
          SettingsCard(
            children: [
              SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Central de ajuda',
                subtitle: 'Perguntas frequentes e contato',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpPage()),
                ),
              ),
              SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'Sobre o Ivalid',
                subtitle: 'Versão 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 28),
          Center(
            child: Text(
              'Ivalid v1.0.0',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: context.onBgAlpha(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Ivalid',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.softBg(AppColors.redPrimary),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.eco_rounded, color: AppColors.redPrimary),
      ),
      children: [
        Text(
          'O Ivalid conecta pessoas a produtos próximos do vencimento com '
          'descontos, reduzindo o desperdício de alimentos e incentivando '
          'doações.',
          style: GoogleFonts.inter(fontSize: 13, color: context.onBgAlpha(0.7)),
        ),
      ],
    );
  }
}

/// Seletor de tema: Claro, Escuro ou Sistema.
class _ThemeModeSelector extends StatelessWidget {
  final SettingsProvider settings;

  const _ThemeModeSelector({required this.settings});

  @override
  Widget build(BuildContext context) {
    const options = <ThemeMode, ({String label, IconData icon})>{
      ThemeMode.light: (label: 'Claro', icon: Icons.light_mode_outlined),
      ThemeMode.dark: (label: 'Escuro', icon: Icons.dark_mode_outlined),
      ThemeMode.system: (label: 'Sistema', icon: Icons.phone_android_rounded),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tema do aplicativo',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.onBgAlpha(0.6),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final entry in options.entries) ...[
                Expanded(
                  child: _ThemeOptionChip(
                    label: entry.value.label,
                    icon: entry.value.icon,
                    isSelected: settings.themeMode == entry.key,
                    onTap: () => settings.setThemeMode(entry.key),
                  ),
                ),
                if (entry.key != options.keys.last) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? context.softBg(AppColors.redPrimary)
                : context.chipBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.redPrimary
                  : context.outline.withValues(alpha: 0.4),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.redPrimary : context.onBgAlpha(0.5),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.redPrimary : context.onBgAlpha(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
