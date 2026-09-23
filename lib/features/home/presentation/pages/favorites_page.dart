import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:ivalid/core/theme/app_colors.dart';

import '../../domain/models/product.dart';
import '../providers/home_provider.dart';
import 'product_details_page.dart';

/// Lista os produtos marcados como favoritos na Home.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<HomeProvider>().favoriteProducts;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.onBg),
        title: Text(
          'Favoritos',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: context.onBg,
          ),
        ),
      ),
      body: favorites.isEmpty
          ? _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              itemCount: favorites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) =>
                  _FavoriteCard(product: favorites[index]),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: context.softBg(AppColors.redPrimary),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 40,
                color: AppColors.redPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhum favorito ainda',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: context.onBg,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no coração dos produtos na tela inicial para salvá-los aqui.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: context.onBgAlpha(0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Product product;

  const _FavoriteCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.outline.withValues(alpha: 0.4)),
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
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsPage(product: product),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 68,
                    height: 68,
                    child: product.urlImagem.isEmpty
                        ? Container(
                            color: context.chipBg,
                            child: Icon(
                              Icons.image_outlined,
                              color: context.onBgAlpha(0.3),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: product.urlImagem,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                Container(color: context.chipBg),
                            errorWidget: (_, _, _) => Container(
                              color: context.chipBg,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: context.onBgAlpha(0.3),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: context.onBg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.storeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: context.onBgAlpha(0.5),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'R\$ ${product.priceNow.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remover dos favoritos',
                  onPressed: () =>
                      context.read<HomeProvider>().toggleFavorite(product.id),
                  icon: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.redPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
