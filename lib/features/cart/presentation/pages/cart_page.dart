import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/cart_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _useCashback = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    final double availableCashback = profileProvider.availableCashback;
    final int userTotalDonations = profileProvider.totalDonations;

    final gamification = cartProvider.gamificationService;
    final double appliedCashback = _useCashback
        ? gamification.calculateMaxDiscountAllowed(cartProvider.total, availableCashback)
        : 0.0;
    final double finalTotal = (cartProvider.total - appliedCashback).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.onBg),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Carrinho (${cartProvider.count})',
          style: GoogleFonts.inter(
            color: context.onBg,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (cartProvider.items.isNotEmpty)
            TextButton(
              onPressed: () => cartProvider.clear(),
              child: Text(
                'Limpar',
                style: GoogleFonts.inter(
                  color: AppColors.redPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: cartProvider.items.isEmpty
          ? Center(
              child: Text(
                'Seu carrinho está vazio',
                style: GoogleFonts.inter(
                  color: context.onBgAlpha(0.6),
                  fontSize: 16,
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProvider.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      final isDonation = item.origin == OriginType.doacao;
                      String? estimatedCashbackText;

                      if (isDonation) {
                        final cashbackCalc = gamification
                            .calculateCashback(item.subtotal, userTotalDonations);
                        estimatedCashbackText =
                            "Ganha R\$ ${cashbackCalc.toStringAsFixed(2).replaceAll('.', ',')} de desconto futuro";
                      }

                      return _CartItemRow(
                        item: item,
                        estimatedCashbackText: estimatedCashbackText,
                        onIncrement: () => cartProvider.add(
                            item.product, 1,
                            isDonationContext: isDonation),
                        onDecrement: () => cartProvider.setQuantity(
                            item.product.id, item.quantity - 1,
                            originType: item.origin),
                        onRemove: () => cartProvider.remove(item.product.id,
                            originType: item.origin),
                      );
                    },
                  ),
                ),
                _SummaryBox(
                  total: cartProvider.total,
                  finalTotal: finalTotal,
                  donationTotal: cartProvider.donationSubtotal,
                  estimatedCashback: gamification.calculateCashback(
                      cartProvider.donationSubtotal,
                      userTotalDonations),
                  availableCashback: availableCashback,
                  useCashback: _useCashback,
                  appliedCashback: appliedCashback,
                  onToggleCashback: (value) {
                    setState(() => _useCashback = value);
                  },
                  onCheckout: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CheckoutPage(
                          appliedCashback: appliedCashback,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;
  final String? estimatedCashbackText;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemRow({
    required this.item,
    this.estimatedCashbackText,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDonation = item.origin == OriginType.doacao;

    return Container(
      decoration: BoxDecoration(
        color: isDonation
            ? context.softBg(AppColors.redPrimary)
            : context.surface,
        borderRadius: BorderRadius.circular(12),
        border: isDonation
            ? Border.all(color: AppColors.redPrimary.withValues(alpha: 0.5))
            : null,
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagem do Produto
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 68,
              height: 68,
              color: context.chipBg,
              child: CachedNetworkImage(
                imageUrl: item.product.urlImagem,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported, color: context.onBgAlpha(0.45)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Detalhes do Produto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.onBg,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.product.storeName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: context.onBgAlpha(0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${item.product.priceNow.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: GoogleFonts.inter(
                        color: AppColors.redPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    if (item.product.discountPercent > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        'R\$ ${item.product.priceOriginal.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: GoogleFonts.inter(
                          color: context.onBgAlpha(0.5),
                          decoration: TextDecoration.lineThrough,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
                if (isDonation && estimatedCashbackText != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.volunteer_activism,
                          color: AppColors.redPrimary, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          estimatedCashbackText!,
                          style: GoogleFonts.inter(
                            color: AppColors.redPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Controles de quantidade
          const SizedBox(width: 8),
          Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: item.quantity > 1 ? onDecrement : null,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: item.quantity > 1
                            ? context.surface
                            : context.chipBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.outline),
                      ),
                      child: Icon(Icons.remove,
                          size: 16,
                          color: item.quantity > 1
                              ? context.onBg
                              : context.onBgAlpha(0.45)),
                    ),
                  ),
                  Container(
                    width: 32,
                    alignment: Alignment.center,
                    child: Text(
                      '${item.quantity}',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onIncrement,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: context.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.outline),
                      ),
                      child: Icon(Icons.add, size: 16, color: context.onBg),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(Icons.delete_outline,
                    color: Colors.red, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final double total;
  final double finalTotal;
  final double donationTotal;
  final double estimatedCashback;
  final double availableCashback;
  final bool useCashback;
  final double appliedCashback;
  final ValueChanged<bool> onToggleCashback;
  final VoidCallback onCheckout;

  const _SummaryBox({
    required this.total,
    required this.finalTotal,
    required this.donationTotal,
    required this.estimatedCashback,
    required this.availableCashback,
    required this.useCashback,
    required this.appliedCashback,
    required this.onToggleCashback,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            bottomInset > 0 ? 12 : 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Opção USAR CASHBACK ───────────────────────────────
              if (availableCashback > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: useCashback
                        ? AppColors.greenAccent.withValues(alpha: 0.1)
                        : context.chipBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: useCashback
                          ? AppColors.greenAccent.withValues(alpha: 0.4)
                          : context.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.greenAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.monetization_on_rounded,
                          color: AppColors.greenAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'USAR CASHBACK',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: context.onBg,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Saldo disponível: R\$ ${availableCashback.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: useCashback,
                        activeThumbColor: AppColors.greenAccent,
                        onChanged: onToggleCashback,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ─── Resumo de Valores ──────────────────────────────────
              if (useCashback && appliedCashback > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: context.onBgAlpha(0.6),
                      ),
                    ),
                    Text(
                      'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: context.onBgAlpha(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Desconto Cashback',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greenAccent,
                      ),
                    ),
                    Text(
                      '- R\$ ${appliedCashback.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.greenAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total da Compra',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.onBg,
                    ),
                  ),
                  Text(
                    'R\$ ${finalTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.redPrimary,
                    ),
                  ),
                ],
              ),

              if (donationTotal > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cashback estimado (Doação)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greenAccent,
                      ),
                    ),
                    Text(
                      '+ R\$ ${estimatedCashback.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // ─── Botão FINALIZAR COMPRA ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: total > 0 ? onCheckout : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redPrimary,
                    disabledBackgroundColor: AppColors.redPrimary.withValues(alpha: 0.5),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Finalizar compra',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
