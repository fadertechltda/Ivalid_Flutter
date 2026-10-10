import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/content_grid.dart';
import '../../../../core/widgets/ivalid_card.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../home/domain/models/product.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../impact/presentation/pages/impact_calculator_page.dart';
import '../../../impact/presentation/providers/impact_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'donation_product_details_page.dart';

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
    final itemsDonated = context.watch<ImpactProvider>().totals.itemsDonated;
    final cashbackPercent =
        (context.watch<ProfileProvider>().fidelityLevel.cashbackMultiplier *
                100)
            .round();

    return Scaffold(
      backgroundColor: context.bg,
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
                    AppColors.redPrimary.withValues(alpha: 0.12),
                    context.bg,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageHeader(
                      leading: PageHeader.iconSlot(
                        backgroundColor: AppColors.redPrimary.withValues(
                          alpha: 0.15,
                        ),
                        child: const Icon(
                          Icons.volunteer_activism_rounded,
                          color: AppColors.redPrimary,
                          size: 22,
                        ),
                      ),
                      title: 'Doações',
                      subtitle: 'Alimento para quem precisa',
                      actions: [
                        PageHeader.iconSlot(
                          backgroundColor: context.surface,
                          boxShadow: [
                            BoxShadow(
                              color: context.cardShadow,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          onTap: _showExplainerDialog,
                          child: Icon(
                            Icons.info_outline_rounded,
                            color: context.onBg,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screen,
                        0,
                        AppSpacing.screen,
                        8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Impact Card
                          IvalidCard(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ImpactCalculatorPage(),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: StatTile(
                                        icon: Icons.card_giftcard_rounded,
                                        value: formatCount(products.length),
                                        label: 'Itens disponíveis',
                                        color: AppColors.redPrimary,
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: context.outline.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    Expanded(
                                      child: StatTile(
                                        icon: Icons.volunteer_activism_rounded,
                                        value: formatCount(itemsDonated),
                                        label: 'Doados por você',
                                        color: AppColors.greenAccent,
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: context.outline.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    Expanded(
                                      child: StatTile(
                                        icon: Icons.emoji_events_rounded,
                                        value: '$cashbackPercent%',
                                        label: 'Seu cashback',
                                        color: AppColors.yellowAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Simular meu impacto',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: context.accent(
                                          AppColors.greenAccent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: context.accent(
                                        AppColors.greenAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          const SectionTitle('Escolha itens para doar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Grid de Produtos ────────────────────────────────────────
          SliverContentGrid(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              100,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              return _DonationCard(
                item: item,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DonationProductDetailsPage(product: item),
                    ),
                  );
                },
                onAdd: () {
                  cartProvider.add(item, 1, isDonationContext: true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${item.name} adicionado ao carrinho de doação!',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.greenAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Donation Card ────────────────────────────────────────────────────────────
class _DonationCard extends StatelessWidget {
  final Product item;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _DonationCard({
    required this.item,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(button: true, child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: context.cardShadow,
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
              height: 120,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: context.chipBg),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Hero(
                      tag: 'donation_product_${item.id}',
                      child: CachedNetworkImage(
                        imageUrl: item.urlImagem,
                        fit: BoxFit.contain,
                        errorWidget: (context, url, error) => Icon(
                          Icons.image_not_supported_outlined,
                          color: context.onBgMuted,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: context.onBg,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatReais(item.priceNow),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: AppColors.redPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: Material(
                      color: AppColors.redPrimary,
                      borderRadius: BorderRadius.circular(AppRadius.tag),
                      child: InkWell(
                        onTap: onAdd,
                        borderRadius: BorderRadius.circular(AppRadius.tag),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'DOAR ITEM',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    height: 1,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

// ─── Explainer Dialog ─────────────────────────────────────────────────────────
class _ExplanationDialog extends StatelessWidget {
  const _ExplanationDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: context.surface,
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
                color: context.softBg(AppColors.redPrimary),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                size: 36,
                color: AppColors.redPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Apoie quem precisa',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: context.onBg,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'A entrega é feita diretamente para as ONGs parceiras que combatem a fome.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: context.onBgMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.softBg(AppColors.greenAccent),
                borderRadius: BorderRadius.circular(AppRadius.control),
                border: Border.all(
                  color: AppColors.greenAccent.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.greenAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.tag),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.greenAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Doe alimentos e ganhe cashback de até 5% para suas próximas compras!',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: context.textOn(AppColors.greenAccent),
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
                    borderRadius: BorderRadius.circular(AppRadius.tile),
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
