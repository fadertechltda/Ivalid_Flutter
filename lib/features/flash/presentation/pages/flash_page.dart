import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ivalid/core/theme/app_colors.dart';
import 'package:ivalid/features/home/presentation/providers/home_provider.dart';
import 'package:ivalid/features/home/domain/models/product.dart';
import 'package:ivalid/features/home/presentation/pages/product_details_page.dart';

/// Tela FLASH — exibe apenas produtos com menos de 10 dias para vencer.
/// Foco em urgência: design agressivo com contagem regressiva e badges de alerta.
class FlashPage extends StatelessWidget {
  const FlashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    // Filtra apenas produtos com < 10 dias de validade
    final flashProducts = homeProvider.filteredProducts
        .where((p) => p.expiresInDays < 10)
        .toList()
      ..sort((a, b) => a.expiresInDays.compareTo(b.expiresInDays));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ─── Header ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.redPrimaryDark,
                    AppColors.redPrimary,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.flash_on,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.flash_on,
                                color: AppColors.yellowAccent,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'FLASH',
                                style: GoogleFonts.inter(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${flashProducts.length} ofertas',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Banner informativo
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.yellowAccent.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.yellowAccent.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.timer,
                                color: AppColors.yellowAccent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Últimas unidades!',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.yellowAccent,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Produtos com menos de 10 dias para o vencimento. Aproveite os maiores descontos!',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.8),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Conteúdo ─────────────────────────────────────────────────
          if (homeProvider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.redPrimary),
              ),
            )
          else if (flashProducts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.outlineLight.withOpacity(0.3),
                        ),
                        child: Icon(
                          Icons.flash_off,
                          size: 50,
                          color: AppColors.onBackgroundLight.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Nenhuma oferta Flash no momento',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackgroundLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Produtos com menos de 10 dias de validade aparecerão aqui com descontos especiais.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.onBackgroundLight.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = flashProducts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _FlashProductCard(product: product),
                    );
                  },
                  childCount: flashProducts.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Card de produto Flash (horizontal, estilo urgência) ─────────────────────
class _FlashProductCard extends StatelessWidget {
  final Product product;
  const _FlashProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    // Cor de urgência baseada nos dias
    final Color urgencyColor;
    final String urgencyLabel;
    if (product.expiresInDays <= 3) {
      urgencyColor = const Color(0xFFD32F2F);
      urgencyLabel = 'URGENTE';
    } else if (product.expiresInDays <= 5) {
      urgencyColor = const Color(0xFFE65100);
      urgencyLabel = 'CORRE!';
    } else {
      urgencyColor = const Color(0xFFF57C00);
      urgencyLabel = 'APROVEITE';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Barra de urgência no topo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [urgencyColor, urgencyColor.withOpacity(0.8)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$urgencyLabel • Vence em ${product.expiresInDays} dia${product.expiresInDays == 1 ? '' : 's'}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // Conteúdo do card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Imagem
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: product.urlImagem,
                            fit: BoxFit.contain,
                            width: 90,
                            height: 90,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        // Badge de desconto
                        if (product.discountPercent > 0)
                          Positioned(
                            top: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.redPrimary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${product.discountPercent}%',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info do produto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onBackgroundLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.brand} • ${product.storeName}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onBackgroundLight.withOpacity(0.5),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.distanceKm.toStringAsFixed(1)} km',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onBackgroundLight.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'R\$ ${product.priceNow.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.redPrimary,
                              ),
                            ),
                            if (product.discountPercent > 0) ...[
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  'R\$ ${product.priceOriginal.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Seta
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.redPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: AppColors.redPrimary,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
