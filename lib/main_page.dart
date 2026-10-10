import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ivalid/core/theme/app_colors.dart';

import 'features/home/presentation/pages/home_page.dart';
import 'features/donation/presentation/pages/donation_page.dart';
import 'features/flash/presentation/pages/flash_page.dart';
import 'features/orders/presentation/pages/orders_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'package:ivalid/core/theme/app_tokens.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    const HomePage(),
    const DonationPage(),
    const FlashPage(),
    // Reconstrói a tela de pedidos toda vez que a aba for acessada
    _currentIndex == 3 ? const OrdersPage() : const SizedBox.shrink(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // StatusBar acompanha o tema ativo
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: context.isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: context.isDarkMode
            ? Brightness.dark
            : Brightness.light,
      ),
    );

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDarkMode ? 0.4 : 0.06,
            ),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
          child: Row(
            children: [
              _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Início'),
              _navItem(
                1,
                Icons.favorite_border_rounded,
                Icons.favorite_rounded,
                'Doação',
              ),
              _navItem(
                2,
                Icons.flash_on_outlined,
                Icons.flash_on_rounded,
                'Flash',
              ),
              _navItem(
                3,
                Icons.receipt_long_outlined,
                Icons.receipt_long_rounded,
                'Pedidos',
              ),
              _navItem(
                4,
                Icons.person_outline_rounded,
                Icons.person_rounded,
                'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    final color = isActive ? context.redText : context.onBgAlpha(0.55);

    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => setState(() => _currentIndex = index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isActive ? activeIcon : icon, size: 22, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: color,
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
