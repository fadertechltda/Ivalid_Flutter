import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ivalid/core/theme/app_colors.dart';
import '../../../home/domain/models/product.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

/// Tela de detalhes do produto para doação
class DonationProductDetailsPage extends StatefulWidget {
  final Product product;

  const DonationProductDetailsPage({super.key, required this.product});

  @override
  State<DonationProductDetailsPage> createState() => _DonationProductDetailsPageState();
}

class _DonationProductDetailsPageState extends State<DonationProductDetailsPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final cartProvider = context.read<CartProvider>();

    // Cores de urgência/validade
    final Color urgencyBg;
    final Color urgencyFg;
    final String urgencyLabel;

    if (product.expiresInDays <= 10) {
      urgencyBg = AppColors.redPrimary.withValues(alpha: 0.12);
      urgencyFg = AppColors.redPrimary;
      urgencyLabel = '⚡ Vence em ${product.expiresInDays}d';
    } else if (product.expiresInDays <= 30) {
      urgencyFg = context.accent(const Color(0xFFF57C00));
      urgencyBg = context.softBg(urgencyFg);
      urgencyLabel = 'Vence em ${product.expiresInDays}d';
    } else {
      urgencyBg = AppColors.greenAccent.withValues(alpha: 0.12);
      urgencyFg = AppColors.greenAccent;
      urgencyLabel = 'Vence em ${product.expiresInDays}d';
    }

    return Scaffold(
      backgroundColor: context.bg,
      body: Column(
        children: [
          // Conteúdo rolável
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Imagem com Botão de Voltar e Badges ────────────────────────────
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 320,
                        color: context.surface,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Hero(
                              tag: 'donation_product_${product.id}',
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
                                  color: context.onBgAlpha(0.25),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Botão Voltar
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: context.surface,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: context.cardShadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: context.onBg,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      // Badges inferiores da imagem
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

                  // ─── Informações do Produto ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Marca do Produto
                        if (product.brand.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.redPrimary.withValues(alpha: 0.08),
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
                        ],

                        // Nome do Produto
                        Text(
                          product.name.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: context.onBg,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card da Loja e Distância
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: context.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: context.cardShadow,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: context.chipBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.storefront_rounded, size: 20, color: context.onBg),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${product.distanceKm.toStringAsFixed(1)} km de distância',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: context.onBgAlpha(0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── Card de Categoria Funcional / Info de Doação ──────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.greenAccent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.greenAccent.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.greenAccent.withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_rounded,
                                  color: AppColors.greenAccent,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Item para Doação',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.greenAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Este produto será entregue diretamente a ONGs parceiras, gerando cashback.',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.greenAccent.withValues(alpha: 0.85),
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── Preço Especial ──────────────────────────────────────
                        Text(
                          'Preço Especial',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.onBgAlpha(0.45),
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
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.redPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (product.discountPercent > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  'R\$ ${product.priceOriginal.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: context.onBgAlpha(0.4),
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ─── Seletor de Quantidade ──────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: context.surface,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: context.cardShadow,
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
                                  fontWeight: FontWeight.w800,
                                  color: context.onBg,
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
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Bottom Bar Fixo ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: context.surface,
              boxShadow: [
                BoxShadow(
                  color: context.cardShadow,
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Total consolidado
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: context.onBgAlpha(0.5),
                        ),
                      ),
                      Text(
                        'R\$ ${(product.priceNow * _quantity).toStringAsFixed(2).replaceAll('.', ',')}',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: context.onBg,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Botão principal - Doar Item
                GestureDetector(
                  onTap: () {
                    cartProvider.add(product, _quantity, isDonationContext: true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$_quantity ${_quantity == 1 ? 'item adicionado' : 'itens adicionados'} ao carrinho de doação!',
                                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.greenAccent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.greenAccent,
                          Color(0xFF1B8756),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greenAccent.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Doar Item',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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
        color: context.chipBg,
        borderRadius: BorderRadius.circular(14),
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
                color: context.onBg,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            isAdd: true,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool isAdd;
  final VoidCallback? onTap;

  const _StepperButton({
    required this.icon,
    this.isAdd = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    return Material(
      color: isAdd
          ? AppColors.redPrimary.withValues(alpha: 0.12)
          : (enabled ? context.onBgAlpha(0.08) : context.chipBg),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: isAdd ? AppColors.redPrimary : (enabled ? context.onBg : context.onBgAlpha(0.3)),
          ),
        ),
      ),
    );
  }
}
