import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../home/domain/models/product.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  @override
  void initState() {
    super.initState();
    // Simulate showing explainer dialog on first open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showExplainerDialog();
    });
  }

  void _showExplainerDialog() {
    showDialog(
      context: context,
      builder: (context) => const _ExplanationDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final cartProvider = context.read<CartProvider>();
    final products = homeProvider.filteredProducts;

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
          'Doações',
          style: GoogleFonts.inter(
            color: AppColors.redPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.onBackgroundLight),
            onPressed: _showExplainerDialog,
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final item = products[index];
          return _DonationCard(
            item: item,
            onAdd: () {
              cartProvider.add(item, 1, isDonationContext: true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Produto doado enviado ao carrinho!', style: GoogleFonts.inter()),
                  backgroundColor: AppColors.greenAccent,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final Product item;
  final VoidCallback onAdd;

  const _DonationCard({required this.item, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 100,
                color: Colors.grey.shade200,
                child: CachedNetworkImage(
                  imageUrl: item.urlImagem,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: Text(
                item.name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.volunteer_activism, size: 14, color: AppColors.redPrimary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Para ONGs parceiras",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.onBackgroundLight.withOpacity(0.6),
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              "R\$ ${item.priceNow.toStringAsFixed(2).replaceAll('.', ',')}",
              style: GoogleFonts.inter(
                color: AppColors.redPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Doar Item",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12,
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

class _ExplanationDialog extends StatelessWidget {
  const _ExplanationDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard, size: 48, color: AppColors.redPrimary),
            const SizedBox(height: 12),
            Text(
              "Apoie quem precisa",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.onBackgroundLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "A entrega é feita diretamente para as ONGs parceiras que combatem a fome.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onBackgroundLight.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.redPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.redPrimary.withOpacity(0.2)),
              ),
              child: Text(
                "Sua solidariedade vale descontos! Doe alimentos e ganhe cashback de até 5% sobre o valor doado para usar em suas próximas compras no Ivalid.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.redPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Entendi, quero doar!",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
