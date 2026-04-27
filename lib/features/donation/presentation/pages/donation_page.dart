import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../home/domain/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstTimeAndShowDialog();
    });
  }

  Future<void> _checkFirstTimeAndShowDialog() async {
    if (_dialogShown) return;
    _dialogShown = true;
    
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_donation_explainer') ?? false;
    
    if (!hasSeen) {
      await prefs.setBool('has_seen_donation_explainer', true);
      if (mounted) {
        _showExplainerDialog();
      }
    }
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
      body: CustomScrollView(
        slivers: [
          // ─── Header ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.redPrimary.withOpacity(0.12),
                    AppColors.backgroundLight,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title row
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.redPrimary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.volunteer_activism_rounded,
                              color: AppColors.redPrimary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Doações',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.onBackgroundLight,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Alimento para quem precisa',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.onBackgroundLight.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _showExplainerDialog,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.onBackgroundLight,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Impact Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            _ImpactStat(
                              icon: Icons.card_giftcard_rounded,
                              value: '${products.length}',
                              label: 'Itens disponíveis',
                              color: AppColors.redPrimary,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.outlineLight.withOpacity(0.5),
                            ),
                            _ImpactStat(
                              icon: Icons.groups_rounded,
                              value: '12',
                              label: 'ONGs parceiras',
                              color: AppColors.greenAccent,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.outlineLight.withOpacity(0.5),
                            ),
                            _ImpactStat(
                              icon: Icons.emoji_events_rounded,
                              value: '5%',
                              label: 'Cashback',
                              color: AppColors.yellowAccent,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section title
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.redPrimary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Escolha itens para doar',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onBackgroundLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Grid de Produtos ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.62,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = products[index];
                  return _DonationCard(
                    item: item,
                    onAdd: () {
                      cartProvider.add(item, 1, isDonationContext: true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${item.name} adicionado ao carrinho de doação!',
                                  style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.greenAccent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Impact Stats Widget ──────────────────────────────────────────────────────
class _ImpactStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _ImpactStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.onBackgroundLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.onBackgroundLight.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Donation Card ────────────────────────────────────────────────────────────
class _DonationCard extends StatelessWidget {
  final Product item;
  final VoidCallback onAdd;

  const _DonationCard({required this.item, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          SizedBox(
            height: 100,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFFFAFAFA)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: CachedNetworkImage(
                    imageUrl: item.urlImagem,
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) =>
                        Icon(Icons.image_not_supported_outlined, color: Colors.grey.shade300, size: 32),
                  ),
                ),
                // Donation tag
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.greenAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_rounded, color: Colors.white, size: 10),
                        const SizedBox(width: 3),
                        Text(
                          'DOAÇÃO',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.onBackgroundLight,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.volunteer_activism_rounded, size: 12, color: AppColors.onBackgroundLight.withOpacity(0.4)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Para ONGs parceiras',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.onBackgroundLight.withOpacity(0.4),
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'R\$ ${item.priceNow.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.inter(
                      color: AppColors.redPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: ElevatedButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.favorite_rounded, size: 16),
                      label: Text(
                        'DOAR ITEM',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Explainer Dialog ─────────────────────────────────────────────────────────
class _ExplanationDialog extends StatelessWidget {
  const _ExplanationDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.redPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.volunteer_activism_rounded, size: 36, color: AppColors.redPrimary),
            ),
            const SizedBox(height: 20),
            Text(
              'Apoie quem precisa',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppColors.onBackgroundLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'A entrega é feita diretamente para as ONGs parceiras que combatem a fome.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onBackgroundLight.withOpacity(0.6),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greenAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greenAccent.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.greenAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: AppColors.greenAccent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Doe alimentos e ganhe cashback de até 5% para suas próximas compras!',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.greenAccent,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Entendi, quero doar!',
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
}
