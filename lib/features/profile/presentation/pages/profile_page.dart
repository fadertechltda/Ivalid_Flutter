import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ivalid/core/theme/app_colors.dart';
import '../../../donation/domain/services/donation_gamification_service.dart';
import '../../../home/presentation/pages/favorites_page.dart';
import '../../../settings/presentation/pages/account_data_page.dart';
import '../../../settings/presentation/pages/help_page.dart';
import '../../../settings/presentation/pages/security_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../impact/presentation/widgets/impact_summary_card.dart';
import '../providers/profile_provider.dart';
import 'ivalid_pago_page.dart';

/// Tela de Perfil — migrada fielmente de ProfileScreen.kt
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _ProfilePageContent();
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    final fidelityLevel = provider.fidelityLevel;
    final neededToNext = provider.donationsNeededForNextLevel;

    // Cores do nível de fidelidade
    final Color levelColor;
    final IconData levelIcon;
    switch (fidelityLevel) {
      case FidelityLevel.bronze:
        levelColor = context.accent(const Color(0xFFCD7F32));
        levelIcon = Icons.shield_outlined;
        break;
      case FidelityLevel.prata:
        levelColor = context.accent(const Color(0xFF8E8E93));
        levelIcon = Icons.shield_rounded;
        break;
      case FidelityLevel.ouro:
        levelColor = const Color(0xFFFFB800);
        levelIcon = Icons.workspace_premium_rounded;
        break;
    }
    final levelBgColor = context.isDarkMode
        ? context.surface
        : levelColor.withValues(alpha: 0.07);

    return Scaffold(
      backgroundColor: context.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── HEADER com gradiente ───────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.redPrimary.withValues(alpha: 0.10),
                    context.bg,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.redPrimary.withValues(alpha: 0.2),
                              AppColors.redPrimary.withValues(alpha: 0.08),
                            ],
                          ),
                          border: Border.all(
                            color: context.surface,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.redPrimary.withValues(alpha: 0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 34,
                          color: AppColors.redPrimary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info do usuário
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.isLoading
                                  ? 'Carregando...'
                                  : provider.userName,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: context.onBg,
                              ),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => _showPremiumSheet(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.redPrimary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: AppColors.redPrimary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Premium Ivalid',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.redPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Settings
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: context.cardShadow,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SettingsPage(),
                                ),
                              );
                            },
                            child: Icon(
                              Icons.settings_outlined,
                              color: context.onBg,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── CARDS & LIST ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ─── Card Fidelidade / Doações ──────────────────────
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: levelBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: levelColor.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: levelColor.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Ícone do nível
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: levelColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  levelIcon,
                                  color: levelColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nível ${fidelityLevel.label.split(' ').first} (${provider.totalDonations} ${provider.totalDonations == 1 ? 'doação' : 'doações'})',
                                      style: GoogleFonts.inter(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        color: levelColor,
                                      ),
                                    ),
                                    Text(
                                      'Cashback de ${fidelityLevel.label.split(' ').last}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: context.onBgAlpha(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Disponível',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: context.onBgAlpha(0.4),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'R\$ ${provider.availableCashback.toStringAsFixed(2).replaceAll('.', ',')}',
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.greenAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (neededToNext != null) ...[
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Faltam $neededToNext doações para o próximo nível',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: context.onBgAlpha(0.6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: LinearProgressIndicator(
                                value: _calculateProgress(
                                    provider.totalDonations, fidelityLevel),
                                minHeight: 6,
                                color: levelColor,
                                backgroundColor:
                                    levelColor.withValues(alpha: 0.15),
                              ),
                            ),
                          ] else
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: Row(
                                children: [
                                  Icon(Icons.emoji_events_rounded, color: levelColor, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Nível máximo alcançado!',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: levelColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Card "Seu impacto" ─────────────────────────────
                  const ImpactSummaryCard(),

                  const SizedBox(height: 16),

                  // ─── Card "Ivalid Pago" ─────────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: context.cardShadow,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const IvalidPagoPage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.redPrimary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.credit_card_rounded,
                                  color: AppColors.redPrimary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Ivalid',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.redPrimary,
                                          ),
                                        ),
                                        Text(
                                          'Pago',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: context.onBg,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Gerencie pagamentos e saldos',
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
                                color: context.onBgAlpha(0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── Menu Items ─────────────────────────────────────
                  _buildSectionLabel(context, 'Geral'),
                  const SizedBox(height: 4),
                  _ProfileMenuItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Conversas',
                    onTap: () => _showEmptyStateSheet(
                      context,
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Nenhuma conversa',
                      message:
                          'Quando você falar com uma loja sobre um pedido, a '
                          'conversa aparece aqui.',
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notificações',
                    onTap: () => _openPage(context, const SettingsPage()),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Dados da conta',
                    onTap: () async {
                      await _openPage(context, const AccountDataPage());
                      await provider.loadUserProfile();
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.favorite_border_rounded,
                    label: 'Favoritos',
                    onTap: () => _openPage(context, const FavoritesPage()),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.local_activity_outlined,
                    label: 'Cupons',
                    onTap: () => _showEmptyStateSheet(
                      context,
                      icon: Icons.local_activity_outlined,
                      title: 'Nenhum cupom disponível',
                      message:
                          'Cupons de desconto conquistados em doações e '
                          'promoções aparecem aqui.',
                    ),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    label: 'Endereços',
                    onTap: () {
                      _showAddressDialog(context, provider);
                    },
                  ),

                  const SizedBox(height: 20),
                  _buildSectionLabel(context, 'Suporte'),
                  const SizedBox(height: 4),

                  _ProfileMenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Ajuda',
                    onTap: () => _openPage(context, const HelpPage()),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.security_outlined,
                    label: 'Segurança',
                    onTap: () => _openPage(context, const SecurityPage()),
                  ),
                  _ProfileMenuItem(
                    icon: Icons.settings_outlined,
                    label: 'Configurações',
                    onTap: () => _openPage(context, const SettingsPage()),
                  ),

                  const SizedBox(height: 20),

                  // Sair da conta
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.redPrimary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: () {
                          provider.logout(() {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          });
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.exit_to_app_rounded, color: AppColors.redPrimary, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'Sair da conta',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.redPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Version
                  Text(
                    'Ivalid v1.0.0',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: context.onBgAlpha(0.3),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: context.onBgAlpha(0.35),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Future<void> _openPage(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _showEmptyStateSheet(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ctx.onBgAlpha(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: ctx.softBg(AppColors.redPrimary),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.redPrimary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: ctx.onBg,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: ctx.onBgAlpha(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumSheet(BuildContext context) {
    _showEmptyStateSheet(
      context,
      icon: Icons.workspace_premium_rounded,
      title: 'Premium Ivalid',
      message:
          'Você tem acesso a cashback nas compras, ofertas exclusivas e '
          'prioridade nas reservas de produtos.',
    );
  }

  double _calculateProgress(int totalDonations, FidelityLevel level) {
    final max = level.maxDonations ?? totalDonations;
    final totalOfLevelSpan = max - level.minDonations + 1;
    return (totalDonations - level.minDonations).toDouble() /
        totalOfLevelSpan.toDouble();
  }

  void _showAddressDialog(BuildContext context, ProfileProvider provider) {
    provider.setAddressDialogVisible(true);
    showDialog(
      context: context,
      builder: (ctx) {
        return ChangeNotifierProvider.value(
          value: provider,
          child: const _AddressDialog(),
        );
      },
    ).then((_) {
      provider.setAddressDialogVisible(false);
    });
  }
}

// ─── Item de Menu do Perfil ───────────────────────────────────────────────────
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: context.chipBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: context.onBgAlpha(0.6),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: context.onBg,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: context.onBgAlpha(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Modal de Endereço ────────────────────────────────────────────────────────
class _AddressDialog extends StatelessWidget {
  const _AddressDialog();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: context.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.redPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.redPrimary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Meu Endereço',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: context.onBg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fields
            _buildTextField(context,
              value: provider.cep,
              label: 'CEP',
              keyboardType: TextInputType.number,
              isLoading: provider.isAddressLoading,
              onChanged: (v) {
                final clean = v.replaceAll(RegExp(r'[^0-9]'), '');
                if (clean.length <= 8) {
                  provider.updateAddressField('cep', clean);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(context,
              value: provider.street,
              label: 'Endereço',
              onChanged: (v) => provider.updateAddressField('street', v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(context,
                    value: provider.number,
                    label: 'Número',
                    onChanged: (v) => provider.updateAddressField('number', v),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(context,
                    value: provider.complement,
                    label: 'Complemento',
                    onChanged: (v) => provider.updateAddressField('complement', v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(context,
              value: provider.neighborhood,
              label: 'Bairro',
              onChanged: (v) => provider.updateAddressField('neighborhood', v),
            ),
            const SizedBox(height: 12),
            _buildTextField(context,
              value: provider.city,
              label: 'Cidade',
              onChanged: (v) => provider.updateAddressField('city', v),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: provider.isSavingAddress
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final saved = await provider.saveAddress();
                        navigator.pop();
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              saved
                                  ? 'Endereço salvo com sucesso!'
                                  : 'Não foi possível salvar o endereço.',
                            ),
                            backgroundColor: saved
                                ? AppColors.greenAccent
                                : AppColors.redPrimary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: provider.isSavingAddress
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Salvar Endereço',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String value,
    required String label,
    TextInputType? keyboardType,
    bool isLoading = false,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: context.onBg),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: context.onBgAlpha(0.5),
        ),
        filled: true,
        fillColor: context.chipBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.redPrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.redPrimary,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
