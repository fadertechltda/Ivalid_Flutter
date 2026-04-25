import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ivalid/core/theme/app_colors.dart';
import '../providers/home_provider.dart';
import '../../domain/models/product.dart';
import '../../domain/models/category.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../donation/presentation/pages/donation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortMenu(BuildContext context, HomeProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ordenar por',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      _buildSortOption(provider, 'Padrão (Vencimento)', ProductSortOption.defaultSort),
                      const Divider(height: 1),
                      _buildSortOption(provider, 'Menor Preço', ProductSortOption.priceAsc),
                      _buildSortOption(provider, 'Maior Preço', ProductSortOption.priceDesc),
                      const Divider(height: 1),
                      _buildSortOption(provider, 'Maior Desconto', ProductSortOption.discountDesc),
                      _buildSortOption(provider, 'Menor Desconto', ProductSortOption.discountAsc),
                      const Divider(height: 1),
                      _buildSortOption(provider, 'Mais Próximo (km)', ProductSortOption.distanceAsc),
                      _buildSortOption(provider, 'Mais Distante (km)', ProductSortOption.distanceDesc),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(HomeProvider provider, String label, ProductSortOption option) {
    final isSelected = provider.currentSort == option;
    return ListTile(
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.redPrimary : AppColors.onBackgroundLight,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.redPrimary) : null,
      onTap: () {
        provider.sortProducts(option);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.currentUser?.displayName ?? 'Cliente';
    final firstName = userName.split(' ').first;

    final homeProvider = context.watch<HomeProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: 0,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: AppColors.redPrimary,
                unselectedItemColor: Colors.grey,
                selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
                onTap: (index) {
                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DonationPage()),
                    );
                  }
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.redPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.home),
                    ),
                    label: 'Início',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_border),
                    label: 'Doação',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.local_offer_outlined),
                    label: 'Descontão',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.list_alt),
                    label: 'Pedidos',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Perfil',
                  ),
                ],
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                onPressed: () => _showSortMenu(context, homeProvider),
                backgroundColor: AppColors.redPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.sort, color: Colors.white),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () => homeProvider.loadFromFirestore(),
              color: AppColors.redPrimary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/logo_ivalid.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  firstName,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onBackgroundLight,
                                  ),
                                ),
                                Text(
                                  'Ofertas perto de você',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.onBackgroundLight.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.shopping_cart_outlined, color: AppColors.onBackgroundLight),
                                if (cartProvider.count > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.redPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${cartProvider.count}',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CartPage()),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: AppColors.onBackgroundLight),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.outlineLight),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: homeProvider.onQueryChange,
                              decoration: InputDecoration(
                                hintText: 'Buscar produto, marca ou loja',
                                hintStyle: GoogleFonts.inter(color: Colors.grey.shade600),
                                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 28),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Categories
                          SizedBox(
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: homeProvider.categories.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final cat = homeProvider.categories[index];
                                final isSelected = homeProvider.selectedCategoryId == cat.id || 
                                    (homeProvider.selectedCategoryId == null && cat.id == 'all');
                                
                                return ChoiceChip(
                                  label: Text(cat.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    homeProvider.onSelectCategory(cat.id == 'all' ? null : cat.id);
                                  },
                                  selectedColor: AppColors.redPrimary.withOpacity(0.2),
                                  backgroundColor: const Color(0xFFF2F2F2),
                                  labelStyle: GoogleFonts.inter(
                                    color: isSelected ? AppColors.redPrimary : AppColors.onBackgroundLight,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  side: BorderSide.none,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Banner
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppColors.redPrimary,
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aproveite descontos de até 70%',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Container(
                                      height: 6,
                                      width: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.greenAccent,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Itens próximos da validade • Estoque limitado',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          Text(
                            'Ofertas perto do vencimento',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onBackgroundLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Products Grid
                  if (homeProvider.isLoading)
                    const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator(color: AppColors.redPrimary)),
                    )
                  else if (homeProvider.filteredProducts.isEmpty)
                    SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'Nenhum produto encontrado.',
                            style: GoogleFonts.inter(color: AppColors.onBackgroundLight.withOpacity(0.6)),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _ProductCard(
                              product: homeProvider.filteredProducts[index],
                              onToggleFavorite: () => homeProvider.toggleFavorite(homeProvider.filteredProducts[index].id),
                              onAddToCart: () {
                                cartProvider.add(homeProvider.filteredProducts[index], 1);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Produto adicionado ao carrinho!', style: GoogleFonts.inter()),
                                    backgroundColor: AppColors.greenAccent,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: homeProvider.filteredProducts.length,
                        ),
                      ),
                    ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 80)), // Padding for FAB
                ],
              ),
            ),
          );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;

  const _ProductCard({
    required this.product,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    Color urgencyBgColor;
    Color urgencyTextColor;

    if (product.expiresInDays <= 10) {
      urgencyBgColor = const Color(0xFFFFEBEE);
      urgencyTextColor = const Color(0xFFD32F2F);
    } else if (product.expiresInDays <= 30) {
      urgencyBgColor = const Color(0xFFFFF3E0);
      urgencyTextColor = const Color(0xFFF57C00);
    } else {
      urgencyBgColor = const Color(0xFFE8F5E9);
      urgencyTextColor = const Color(0xFF388E3C);
    }

    return GestureDetector(
      onTap: onAddToCart,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            SizedBox(
              height: 140,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFFF9F9F9)),
                  CachedNetworkImage(
                    imageUrl: product.urlImagem,
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                  if (product.discountPercent > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.redPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onToggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          product.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: product.isFavorite ? AppColors.redPrimary : Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Urgency Banner
            Container(
              width: double.infinity,
              color: urgencyBgColor,
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(
                'Vence em ${product.expiresInDays} dias',
                style: GoogleFonts.inter(
                  color: urgencyTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppColors.onBackgroundLight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• ${product.distanceKm.toStringAsFixed(1)} km',
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'R\$ ${product.priceNow.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: GoogleFonts.inter(
                            color: AppColors.redPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        if (product.discountPercent > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            'R\$ ${product.priceOriginal.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: GoogleFonts.inter(
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
