import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ivalid/core/theme/app_colors.dart';
import '../../domain/models/product.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

/// Tela de detalhes do produto — migrada fielmente do Kotlin
/// ProductDetailsScreen.kt
class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;

  String _calcPickupDeadline(int expiresInDays) {
    if (expiresInDays <= 0) return 'hoje';
    if (expiresInDays == 1) return 'amanhã';
    return 'em até $expiresInDays dias';
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartProvider = context.read<CartProvider>();

    // Cores de urgência
    final Color urgencyBg;
    final Color urgencyFg;
    final String urgencyLabel;

    if (product.expiresInDays <= 10) {
      urgencyBg = AppColors.redPrimary.withOpacity(0.12);
      urgencyFg = AppColors.redPrimary;
      urgencyLabel = '⚡ Vence em ${product.expiresInDays}d';
    } else if (product.expiresInDays <= 30) {
      urgencyBg = const Color(0xFFFFF3E0);
      urgencyFg = const Color(0xFFF57C00);
      urgencyLabel = 'Vence em ${product.expiresInDays}d';
    } else {
      urgencyBg = AppColors.greenAccent.withOpacity(0.12);
      urgencyFg = AppColors.greenAccent;
      urgencyLabel = 'Vence em ${product.expiresInDays}d';
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Imagem com back button ────────────────────────────
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 320,
                        color: Colors.white,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Hero(
                              tag: 'product_${product.id}',
                              child: CachedNetworkImage(
                                imageUrl: product.urlImagem,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.redPrimary,
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Back button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: AppColors.onBackgroundLight,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      // Badges bottom
                      Positioned(
                        bottom: 16,
                        left: 24,
                        right: 24,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: urgencyBg,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                urgencyLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: urgencyFg,
                                ),
                              ),
                            ),
                            if (product.discountPercent > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.redPrimary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '-${product.discountPercent}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ─── Informações ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Marca
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.redPrimary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.brand.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.redPrimary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Nome do produto
                        Text(
                          product.name,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.onBackgroundLight,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Loja e Distância
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.storefront_rounded, size: 18, color: AppColors.onBackgroundLight),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.storeName,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onBackgroundLight,
                                      ),
                                    ),
                                    Text(
                                      '${product.distanceKm.toStringAsFixed(1)} km de distância',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.onBackgroundLight.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.near_me_rounded, size: 18, color: AppColors.onBackgroundLight.withOpacity(0.3)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ─── Preço ──────────────────────────────────────
                        Text(
                          'Preço Especial',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onBackgroundLight.withOpacity(0.45),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'R\$ ${product.priceNow.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: GoogleFonts.inter(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: AppColors.redPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (product.discountPercent > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text(
                                  'R\$ ${product.priceOriginal.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: AppColors.onBackgroundLight.withOpacity(0.4),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ─── Seletor de Quantidade ──────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Quantidade',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onBackgroundLight,
                                ),
                              ),
                              const Spacer(),
                              _QuantityStepper(
                                value: _quantity,
                                onDecrement: () {
                                  if (_quantity > 1) setState(() => _quantity--);
                                },
                                onIncrement: () => setState(() => _quantity++),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── Info de retirada ───────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.greenAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.greenAccent.withOpacity(0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.greenAccent.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.schedule_rounded, color: AppColors.greenAccent, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Retirada ${_calcPickupDeadline(product.expiresInDays)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.greenAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Bottom Bar fixo ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Total
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onBackgroundLight.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        'R\$ ${(product.priceNow * _quantity).toStringAsFixed(2).replaceAll('.', ',')}',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onBackgroundLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Add to cart button
                GestureDetector(
                  onTap: () {
                    cartProvider.add(product, _quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$_quantity ${_quantity == 1 ? 'item adicionado' : 'itens adicionados'} ao carrinho!',
                                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.greenAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 3),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.redPrimary, AppColors.redPrimaryDark],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.redPrimary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Adicionar',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Componente QuantityStepper ───────────────────────────────────────────────
class _QuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onTap: value > 1 ? onDecrement : null,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 44),
            alignment: Alignment.center,
            child: Text(
              value.toString(),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onBackgroundLight,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return Material(
      color: enabled
          ? AppColors.redPrimary.withOpacity(0.1)
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? AppColors.redPrimary : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
