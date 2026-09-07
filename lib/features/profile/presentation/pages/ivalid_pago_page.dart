import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/payment_provider.dart';
import 'add_card_page.dart';

class IvalidPagoPage extends StatefulWidget {
  const IvalidPagoPage({super.key});

  @override
  State<IvalidPagoPage> createState() => _IvalidPagoPageState();
}

class _IvalidPagoPageState extends State<IvalidPagoPage> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onBackgroundLight, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PAGAMENTOS',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: AppColors.onBackgroundLight,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.redPrimary, size: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Leitor de QR Code para pagamentos indisponível no momento.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── CARD DE SALDO PREMIUM (GLASSMORPHISM EFFECT) ───────────
              _buildBalanceCard(context, paymentProvider),
              
              const SizedBox(height: 28),

              // ─── AÇÕES RÁPIDAS ──────────────────────────────────────────
              _buildQuickActionsRow(context),

              const SizedBox(height: 32),

              // ─── FORMAS DE PAGAMENTO (HORIZONTAL CARDS) ──────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Formas de pagamento',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onBackgroundLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showCardsManagementSheet(context, paymentProvider),
                    child: Text(
                      'Ver todos',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.redPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodsList(context, paymentProvider),

              const SizedBox(height: 32),

              // ─── OUTROS SERVIÇOS ─────────────────────────────────────────
              Text(
                'Outros serviços',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onBackgroundLight,
                ),
              ),
              const SizedBox(height: 16),
              _buildOtherServicesGrid(context),

              const SizedBox(height: 32),

              // ─── HISTÓRICO DE TRANSAÇÕES ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Histórico de Transação',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onBackgroundLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Histórico completo em desenvolvimento.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(
                      'Ver mais',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.redPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTransactionsList(context, paymentProvider),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, PaymentProvider provider) {
    return Container(
      width: double.infinity,
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE63946), // Vermelho primário
            Color(0xFFB5179E), // Gradiente para rosa/roxo moderno
            Color(0xFF7209B7), // Profundo futurista
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.redPrimary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Efeitos decorativos circulares desfocados
          Positioned(
            right: -30,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Conteúdo do Card
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Saldo disponível',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        _showBalance ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _showBalance = !_showBalance),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _showBalance
                          ? Text(
                              'R\$ ${provider.balance.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            )
                          : Text(
                              '••••••',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ivalid Pago digital card',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _quickActionItem(
          icon: Icons.add_rounded,
          label: 'Adicionar',
          onTap: () {
            // Simular adição de saldo
            _showAddBalanceDialog(context);
          },
        ),
        _quickActionItem(
          icon: Icons.swap_horiz_rounded,
          label: 'Transferir',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Função de transferência indisponível nesta versão.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        _quickActionItem(
          icon: Icons.local_activity_outlined,
          label: 'Cupons',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Você não tem cupons ativos no momento.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        _quickActionItem(
          icon: Icons.credit_card_rounded,
          label: 'Cartões',
          onTap: () => _showPaymentOptionsSheet(context),
        ),
      ],
    );
  }

  Widget _quickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.redPrimary,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onBackgroundLight.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsList(BuildContext context, PaymentProvider provider) {
    return SizedBox(
      height: 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: provider.cards.length + 1,
        itemBuilder: (ctx, index) {
          if (index == 0) {
            // Card de Cadastrar Novo Cartão
            return Container(
              width: 140,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.redPrimary.withValues(alpha: 0.3),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.redPrimary.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: () => _showPaymentOptionsSheet(context),
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.redPrimary.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AppColors.redPrimary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Cadastrar\nnovo cartão',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.redPrimary,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          final card = provider.cards[index - 1];
          return _buildCreditCardItem(context, card, provider);
        },
      ),
    );
  }

  Widget _buildCreditCardItem(BuildContext context, CreditCardModel card, PaymentProvider provider) {
    // Escolher a cor baseada no tipo de cartão ou bandeira
    final Gradient cardGrad;
    switch (card.brand) {
      case 'VISA':
        cardGrad = const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        );
        break;
      case 'MASTERCARD':
        cardGrad = const LinearGradient(
          colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
        );
        break;
      case 'ELO':
        cardGrad = const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
        );
        break;
      case 'AMERICANEXPRESS':
        cardGrad = const LinearGradient(
          colors: [Color(0xFF134E5E), Color(0xFF71B280)],
        );
        break;
      case 'HIPERCARD':
        cardGrad = const LinearGradient(
          colors: [Color(0xFFD31027), Color(0xFFEA384D)],
        );
        break;
      default:
        cardGrad = const LinearGradient(
          colors: [Color(0xFF3A6073), Color(0xFF3A6073)],
        );
    }

    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: cardGrad,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onLongPress: () {
            _showDeleteCardConfirmation(context, card, provider);
          },
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cartão ${card.brand} final ${card.number.substring(card.number.length - 4)} selecionado.'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandIconMini(card.brand),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        card.type,
                        style: GoogleFonts.inter(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.brand,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.maskedNumber,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandIconMini(String brand) {
    switch (brand) {
      case 'VISA':
        return SvgPicture.asset(
          'assets/images/VISA.svg',
          width: 32,
          height: 18,
          fit: BoxFit.contain,
        );
      case 'MASTERCARD':
        return Image.asset(
          'assets/images/MASTERCARD.png',
          width: 28,
          height: 18,
          fit: BoxFit.contain,
        );
      case 'ELO':
        return Image.asset(
          'assets/images/ELO.png',
          width: 28,
          height: 18,
          fit: BoxFit.contain,
        );
      case 'AMERICANEXPRESS':
        return Image.asset(
          'assets/images/AMERICANEXPRESS.png',
          width: 32,
          height: 18,
          fit: BoxFit.contain,
        );
      case 'HIPERCARD':
        return SvgPicture.asset(
          'assets/images/HIPERCARD.svg',
          width: 32,
          height: 18,
          fit: BoxFit.contain,
        );
      default:
        return const Icon(
          Icons.credit_card_rounded,
          color: Colors.white70,
          size: 16,
        );
    }
  }

  Widget _buildOtherServicesGrid(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        'title': 'Resgatar Ivalid Card',
        'icon': Icons.card_giftcard_rounded,
        'onTap': () {
          _showMockDialog(context, 'Resgatar Ivalid Card', 'Insira o código do seu cartão presente para resgatar o saldo correspondente na sua carteira virtual.');
        }
      },
      {
        'title': 'Habilitar Biometria',
        'icon': Icons.fingerprint_rounded,
        'onTap': () {
          _showMockDialog(context, 'Habilitar Biometria', 'Garante muito mais rapidez e segurança nos seus pagamentos digitais utilizando o sensor de impressão digital do seu celular.');
        }
      },
      {
        'title': 'Meus cupons',
        'icon': Icons.confirmation_number_outlined,
        'onTap': () {
          _showMockDialog(context, 'Meus Cupons', 'Gerencie seus cupons promocionais obtidos através de doações de alimentos e compras com cashback na rede Ivalid.');
        }
      },
      {
        'title': 'Reembolso em Saldo',
        'icon': Icons.monetization_on_outlined,
        'onTap': () {
          _showMockDialog(context, 'Reembolso em Saldo', 'Acompanhe e resgate valores de reembolsos de compras canceladas diretamente para a sua conta Ivalid Pago.');
        }
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: services.length,
      itemBuilder: (ctx, idx) {
        final service = services[idx];
        return Column(
          children: [
            InkWell(
              onTap: service['onTap'],
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  service['icon'],
                  color: AppColors.onBackgroundLight.withValues(alpha: 0.7),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service['title'],
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackgroundLight.withValues(alpha: 0.6),
                height: 1.1,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionsList(BuildContext context, PaymentProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.transactions.length,
      itemBuilder: (ctx, idx) {
        final tx = provider.transactions[idx];
        final isPositive = tx['isPositive'] as bool;
        final value = tx['value'] as double;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isPositive ? AppColors.greenAccent.withValues(alpha: 0.1) : AppColors.redPrimary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tx['icon'] as IconData,
                  color: isPositive ? AppColors.greenAccent : AppColors.redPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onBackgroundLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tx['subtitle'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onBackgroundLight.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isPositive ? '+' : ''} R\$ ${value.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isPositive ? AppColors.greenAccent : AppColors.onBackgroundLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx['date'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.onBackgroundLight.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Escolha uma opção de pagamento',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onBackgroundLight,
                ),
              ),
              const SizedBox(height: 20),
              _paymentOptionSheetTile(
                icon: Icons.credit_card_rounded,
                title: 'Crédito',
                subtitle: 'Visa, Mastercard, Elo, Amex e Hipercard',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddCardPage(cardType: 'Crédito'),
                    ),
                  );
                },
              ),
              _paymentOptionSheetTile(
                icon: Icons.payment_rounded,
                title: 'Débito',
                subtitle: 'Use para transações imediatas na sua conta',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddCardPage(cardType: 'Débito'),
                    ),
                  );
                },
              ),
              _paymentOptionSheetTile(
                icon: Icons.card_giftcard_rounded,
                title: 'Voucher',
                subtitle: 'Caju, Flash, Swile e Outras bandeiras',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddCardPage(cardType: 'Voucher'),
                    ),
                  );
                },
              ),
              _paymentOptionSheetTile(
                icon: Icons.restaurant_rounded,
                title: 'Vale Refeição',
                subtitle: 'Sodexo, Alelo, Ticket e Outras',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Integração de Vale Refeição em breve.')),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _paymentOptionSheetTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.redPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.redPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onBackgroundLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.onBackgroundLight.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onBackgroundLight.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardsManagementSheet(BuildContext context, PaymentProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Meus Cartões Salvos',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onBackgroundLight,
                ),
              ),
              const SizedBox(height: 10),
              if (provider.cards.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'Nenhum cartão cadastrado.',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.cards.length,
                    itemBuilder: (c, idx) {
                      final card = provider.cards[idx];
                      return ListTile(
                        leading: _buildBrandIconMini(card.brand),
                        title: Text(
                          '${card.brand} (•••• ${card.number.substring(card.number.length - 4)})',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text('${card.type} • Expira em ${card.expiryDate}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.redPrimary),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showDeleteCardConfirmation(context, card, provider);
                          },
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteCardConfirmation(BuildContext context, CreditCardModel card, PaymentProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Excluir Cartão',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Tem certeza que deseja remover o cartão ${card.brand} final ${card.number.substring(card.number.length - 4)}?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancelar',
                style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.deleteCard(card.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cartão excluído com sucesso.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: AppColors.redPrimary, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddBalanceDialog(BuildContext context) {
    double valueToAdd = 10.00;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Adicionar Saldo',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Selecione ou insira um valor para recarregar sua carteira digital Ivalid Pago:',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [20, 50, 100].map((val) {
                  return ChoiceChip(
                    label: Text('R\$ $val'),
                    selected: valueToAdd == val.toDouble(),
                    selectedColor: AppColors.redPrimary.withValues(alpha: 0.15),
                    labelStyle: GoogleFonts.inter(
                      color: AppColors.redPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    checkmarkColor: AppColors.redPrimary,
                    onSelected: (selected) {
                      if (selected) {
                        valueToAdd = val.toDouble();
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Voltar',
                style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
                paymentProvider.updateBalance(paymentProvider.balance + valueToAdd);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('R\$ ${valueToAdd.toStringAsFixed(2)} adicionados com sucesso!'),
                    backgroundColor: AppColors.greenAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'Confirmar Recarga',
                style: TextStyle(color: AppColors.greenAccent, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMockDialog(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.redPrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.layers_outlined,
                    color: AppColors.redPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onBackgroundLight,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onBackgroundLight.withValues(alpha: 0.55),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Fechar',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
