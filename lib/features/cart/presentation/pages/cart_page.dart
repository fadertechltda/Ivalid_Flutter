import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/cart_provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackgroundLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Carrinho (${cartProvider.count})',
          style: GoogleFonts.inter(
            color: AppColors.onBackgroundLight,
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
                  color: AppColors.onBackgroundLight.withOpacity(0.6),
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
                        final cashbackCalc = cartProvider.gamificationService
                            .calculateCashback(
                                item.subtotal, cartProvider.userTotalDonationsMock);
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
                  donationTotal: cartProvider.donationSubtotal,
                  estimatedCashback: cartProvider.gamificationService.calculateCashback(
                      cartProvider.donationSubtotal,
                      cartProvider.userTotalDonationsMock),
                  onCheckout: () {
                    // TODO: Implement Checkout logic
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
        color: isDonation ? const Color(0xFFFFF0F0) : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: isDonation
            ? Border.all(color: AppColors.redPrimary.withOpacity(0.5))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 68,
              height: 68,
              color: const Color(0xFFF2F2F2),
              child: CachedNetworkImage(
                imageUrl: item.product.urlImagem,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.onBackgroundLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item.product.storeName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onBackgroundLight.withOpacity(0.6),
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
                          color: AppColors.onBackgroundLight.withOpacity(0.5),
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

          // Controls
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
                            ? AppColors.surfaceLight
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(Icons.remove,
                          size: 16,
                          color: item.quantity > 1
                              ? AppColors.onBackgroundLight
                              : Colors.grey),
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
                        color: AppColors.surfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(Icons.add,
                          size: 16, color: AppColors.onBackgroundLight),
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
  final double donationTotal;
  final double estimatedCashback;
  final VoidCallback onCheckout;

  const _SummaryBox({
    required this.total,
    required this.donationTotal,
    required this.estimatedCashback,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total da Compra',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackgroundLight,
                  ),
                ),
                Text(
                  'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                    'Total em Doações',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onBackgroundLight.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    'R\$ ${donationTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onBackgroundLight.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cashback estimado',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenAccent,
                    ),
                  ),
                  Text(
                    '+ R\$ ${estimatedCashback.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.greenAccent,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: total > 0 ? onCheckout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redPrimary,
                  disabledBackgroundColor: AppColors.redPrimary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Finalizar compra',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
