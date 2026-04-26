import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ivalid/core/theme/app_colors.dart';
import '../providers/orders_provider.dart';
import '../../domain/models/order_model.dart';

/// Tela de Pedidos — design premium alinhado com Home e Doação
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrdersProvider(),
      child: const _OrdersPageContent(),
    );
  }
}

class _OrdersPageContent extends StatelessWidget {
  const _OrdersPageContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();

    // Resumo de stats para o summary card
    final totalPedidos = provider.orders.length;
    final totalGasto = provider.orders.fold<double>(
      0.0,
      (sum, o) => sum + o.total,
    );
    final entregues = provider.orders
        .where((o) => o.status.toLowerCase() == 'entregue')
        .length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // ─── HEADER com gradiente ─────────────────────────────────────
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
                      // ─── Title row ──────────────────────────────────
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
                              Icons.receipt_long_rounded,
                              color: AppColors.redPrimary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meus Pedidos',
                                style: GoogleFonts.inter(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.onBackgroundLight,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Acompanhe suas compras',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.onBackgroundLight
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: provider.fetchOrders,
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
                                Icons.refresh_rounded,
                                color: AppColors.onBackgroundLight,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ─── Summary Stats Card ────────────────────────
                      if (!provider.isLoading && provider.orders.isNotEmpty)
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
                              _SummaryStat(
                                icon: Icons.shopping_bag_rounded,
                                value: '$totalPedidos',
                                label: 'Pedidos',
                                color: AppColors.redPrimary,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: AppColors.outlineLight.withOpacity(0.5),
                              ),
                              _SummaryStat(
                                icon: Icons.check_circle_rounded,
                                value: '$entregues',
                                label: 'Entregues',
                                color: AppColors.greenAccent,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: AppColors.outlineLight.withOpacity(0.5),
                              ),
                              _SummaryStat(
                                icon: Icons.payments_rounded,
                                value:
                                    'R\$ ${totalGasto.toStringAsFixed(0).replaceAll('.', ',')}',
                                label: 'Total gasto',
                                color: AppColors.yellowAccent,
                              ),
                            ],
                          ),
                        ),

                      if (!provider.isLoading && provider.orders.isNotEmpty)
                        const SizedBox(height: 20),

                      // ─── Section Title ─────────────────────────────
                      if (!provider.isLoading && provider.orders.isNotEmpty)
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
                              'Histórico de pedidos',
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

          // ─── CONTEÚDO ─────────────────────────────────────────────────
          if (provider.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.redPrimary),
              ),
            )
          else if (provider.error != null)
            SliverFillRemaining(
              child: _ErrorMessage(
                message: provider.error!,
                onRetry: provider.fetchOrders,
              ),
            )
          else if (provider.orders.isEmpty)
            const SliverFillRemaining(child: _EmptyOrdersMessage())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _OrderCard(order: provider.orders[index]),
                    );
                  },
                  childCount: provider.orders.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Summary Stat (mesmo padrão do ImpactStat da Donation) ───────────────────
class _SummaryStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryStat({
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
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.onBackgroundLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

// ─── Order Card ──────────────────────────────────────────────────────────────
class _OrderCard extends StatefulWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final statusInfo = _getStatusInfo(order.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Status Bar (topo do card, full-width) ───────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusInfo.color.withOpacity(0.08),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: statusInfo.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    statusInfo.icon,
                    size: 14,
                    color: statusInfo.color,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusInfo.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: statusInfo.color,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Text(
                  order.date,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusInfo.color.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // ─── Corpo ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Itens resumo (primeiros 2 itens ou menos)
                ...order.items.take(2).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${item.quantity}x',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.redPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onBackgroundLight,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'R\$ ${item.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.onBackgroundLight
                                        .withOpacity(0.45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),

                // "e mais X itens" se houver mais
                if (order.items.length > 2 && !_isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '+ ${order.items.length - 2} ${order.items.length - 2 == 1 ? 'item' : 'itens'}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackgroundLight.withOpacity(0.4),
                      ),
                    ),
                  ),

                // Itens expandidos (restantes)
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: order.items.skip(2).map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    '${item.quantity}x',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.redPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onBackgroundLight,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'R\$ ${item.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onBackgroundLight
                                            .withOpacity(0.45),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),

                // ─── Total bar ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 16,
                            color:
                                AppColors.onBackgroundLight.withOpacity(0.4),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${order.items.length} ${order.items.length == 1 ? 'item' : 'itens'}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onBackgroundLight
                                  .withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'R\$ ${order.total.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.redPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // ─── Botão de expandir ─────────────────────────────────────
          if (order.items.length > 2)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.outlineLight.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpanded
                            ? 'Ocultar detalhes'
                            : 'Ver todos os itens',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.redPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: AppColors.redPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pagamento pix pendente':
        return _StatusInfo(
          color: const Color(0xFFE65100),
          icon: Icons.pix_rounded,
          label: 'Pagamento Pendente',
        );
      case 'em preparação':
        return _StatusInfo(
          color: const Color(0xFFF59E0B),
          icon: Icons.inventory_2_rounded,
          label: 'Em Preparação',
        );
      case 'entregue':
        return _StatusInfo(
          color: AppColors.greenAccent,
          icon: Icons.check_circle_rounded,
          label: 'Entregue',
        );
      default:
        return _StatusInfo(
          color: const Color(0xFF6B7280),
          icon: Icons.info_outline_rounded,
          label: status,
        );
    }
  }
}

// ─── StatusInfo helper ───────────────────────────────────────────────────────
class _StatusInfo {
  final Color color;
  final IconData icon;
  final String label;

  _StatusInfo({
    required this.color,
    required this.icon,
    required this.label,
  });
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class _EmptyOrdersMessage extends StatelessWidget {
  const _EmptyOrdersMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 40,
                color: AppColors.redPrimary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Nenhum pedido ainda',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.onBackgroundLight,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Quando você fizer sua primeira compra,\nela aparecerá aqui.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onBackgroundLight.withOpacity(0.45),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error State ─────────────────────────────────────────────────────────────
class _ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.redPrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 36,
                color: AppColors.redPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Algo deu errado',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onBackgroundLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onBackgroundLight.withOpacity(0.5),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  'Tentar novamente',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
