import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/api/api_client.dart';
import '../../../orders/data/order_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/cart_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../impact/domain/models/impact_metrics.dart';
import '../../../impact/domain/services/impact_calculator.dart';
import '../../../impact/presentation/widgets/order_impact_card.dart';
import '../../../payment/domain/models/payment_models.dart';
import '../../../payment/presentation/pages/infinitepay_checkout_page.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/donation_badge.dart';
import 'package:ivalid/core/theme/app_tokens.dart';

class CheckoutPage extends StatefulWidget {
  final double appliedCashback;

  const CheckoutPage({super.key, this.appliedCashback = 0.0});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPaymentMethod = 'Dinheiro';
  bool _isProcessing = false;

  /// `true` depois que o pedido foi gravado: esconde o conteúdo do checkout
  /// (já com o carrinho vazio) enquanto o diálogo de sucesso está aberto.
  bool _orderPlaced = false;

  final ImpactCalculator _impactCalculator = ImpactCalculator();
  final OrderService _orderService = OrderService();

  /// Pix e cartão são cobrados na hora, pelo checkout do InfinitePay. Dinheiro
  /// e voucher continuam sendo pagos na retirada.
  static const String _onlineMethodId = 'Online';

  @override
  void dispose() {
    super.dispose();
  }

  /// Impacto social dos itens que estão hoje no carrinho.
  ImpactMetrics _impactOf(CartProvider cart) {
    return _impactCalculator.forLines(
      cart.items.map(
        (item) => ImpactLine.fromProduct(
          item.product,
          item.quantity,
          isDonation: item.origin == OriginType.doacao,
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'Dinheiro',
      'label': 'Dinheiro',
      'subtitle': 'Pague na retirada',
      'icon': Icons.payments_outlined,
      'enabled': true,
    },
    {
      'id': _onlineMethodId,
      'label': 'Pix ou Cartão de Crédito',
      'subtitle': 'Pagamento online seguro pelo InfinitePay',
      'icon': Icons.qr_code_rounded,
      'enabled': true,
    },
    {
      'id': 'Voucher',
      'label': 'Voucher / Vale Alimento',
      'subtitle': 'Pague na retirada',
      'icon': Icons.confirmation_number_outlined,
      'enabled': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Voltar',
          icon: Icon(Icons.arrow_back, color: context.onBg),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Finalizar Pedido',
          style: GoogleFonts.inter(
            color: context.onBg,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _orderPlaced
          ? const SizedBox.shrink()
          : _isProcessing
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.redPrimary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'Resumo dos Itens'),
                        const SizedBox(height: 12),
                        _buildItemsList(context, cartProvider),
                        if (cartProvider.items.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          OrderImpactCard(metrics: _impactOf(cartProvider)),
                        ],
                        const SizedBox(height: 30),
                        _buildSectionTitle(context, 'Método de Pagamento'),
                        const SizedBox(height: 12),
                        _buildPaymentMethods(context),
                      ],
                    ),
                  ),
                ),
                _buildBottomSummary(context, cartProvider),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: context.onBg,
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppRadius.control),
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cartProvider.items.length,
        separatorBuilder: (context, index) =>
            Divider(color: context.outline.withValues(alpha: 0.5), height: 1),
        itemBuilder: (context, index) {
          final item = cartProvider.items[index];
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  '${item.quantity}x',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: context.redText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.product.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: context.onBg,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.origin == OriginType.doacao) ...[
                        const SizedBox(width: 8),
                        const DonationBadge(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatReais(item.subtotal),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.onBg,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return Column(
      children: _paymentMethods.map((method) {
        final isSelected = _selectedPaymentMethod == method['id'];
        final isEnabled = method['enabled'] as bool;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: isEnabled
                ? () {
                    setState(() => _selectedPaymentMethod = method['id']);
                  }
                : null,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.softBg(AppColors.redPrimary)
                    : context.surface,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                border: Border.all(
                  color: isSelected
                      ? AppColors.redPrimary
                      : context.outline,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    method['icon'],
                    color: isEnabled
                        ? (isSelected
                            ? AppColors.redPrimary
                            : context.onBgAlpha(0.45))
                        : context.onBgAlpha(0.25),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method['label'],
                          style: GoogleFonts.inter(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isEnabled
                                ? context.onBg
                                : context.onBgAlpha(0.35),
                            fontSize: 14,
                          ),
                        ),
                        if (!isEnabled)
                          Text(
                            'Em desenvolvimento',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.redPrimary.withValues(alpha: 0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else if (method['subtitle'] != null)
                          Text(
                            method['subtitle'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: context.onBgMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isEnabled)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.redPrimary
                              : context.onBgAlpha(0.35),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.redPrimary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomSummary(BuildContext context, CartProvider cartProvider) {
    final double finalTotal = (cartProvider.total - widget.appliedCashback).clamp(0.0, double.infinity);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom > 0 ? 12 : 20,
      ),
      decoration: BoxDecoration(
        color: context.surface,
        boxShadow: [
          BoxShadow(
            color: context.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.appliedCashback > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: context.onBgMuted,
                    ),
                  ),
                  Text(
                    formatReais(cartProvider.total),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: context.onBgMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Desconto Cashback',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.textOn(AppColors.greenAccent),
                    ),
                  ),
                  Text(
                    '- ${formatReais(widget.appliedCashback)}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: context.textOn(AppColors.greenAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total a pagar',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.onBg,
                  ),
                ),
                Text(
                  formatReais(finalTotal),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: context.redText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _processOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.control),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Center(
                  child: Text(
                    _selectedPaymentMethod == _onlineMethodId
                        ? 'Confirmar e Pagar'
                        : 'Confirmar pedido',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Abre o checkout do InfinitePay para um pedido `Online` já criado pela API
  /// e pede à API que confirme o pagamento. Devolve `false` se o usuário
  /// desistir antes de pagar. Lança [PaymentException]/[ApiException] em falha.
  Future<bool> _payOnline({
    required NavigatorState navigator,
    required String orderId,
  }) async {
    if (!InfinitePayCheckoutPage.isSupported) {
      throw const PaymentException(
        'O pagamento online está disponível apenas no Android e iOS.',
      );
    }

    final checkoutUrl = await _orderService.paymentLink(orderId);

    final redirect = await navigator.push<CheckoutRedirect>(
      MaterialPageRoute(
        builder: (_) => InfinitePayCheckoutPage(checkoutUrl: checkoutUrl),
      ),
    );
    if (redirect == null) return false; // fechou sem concluir

    await _orderService.confirmPayment(orderId, redirect);
    return true;
  }

  /// Agrupa o carrinho por loja: a API aceita uma loja por pedido.
  Map<String, List<CartItem>> _groupByStore(CartProvider cart) {
    final groups = <String, List<CartItem>>{};
    for (final item in cart.items) {
      groups.putIfAbsent(item.product.supermercadoId, () => []).add(item);
    }
    return groups;
  }

  /// Divide o cashback entre os pedidos, proporcional ao subtotal de cada um.
  /// A API ainda limita o valor aplicado (até 15% do subtotal e ao saldo).
  double _cashbackShare(double groupSubtotal, double cartSubtotal) {
    if (cartSubtotal <= 0 || widget.appliedCashback <= 0) return 0;
    final share = widget.appliedCashback * (groupSubtotal / cartSubtotal);
    return (share * 100).floorToDouble() / 100;
  }

  /// Mensagem para o usuário a partir de qualquer falha do fluxo.
  String _messageFor(Object error) {
    if (error is ApiException) {
      final problems = OrderSummary.problemMessages(error.resumo?['problemas']);
      if (problems.isNotEmpty) return problems.join('\n');
      return error.message;
    }
    if (error is PaymentException) return error.message;
    return 'Não foi possível finalizar o pedido. Tente novamente.';
  }

  Future<void> _processOrder(BuildContext context) async {
    setState(() => _isProcessing = true);

    // Captura referências antes do gap assíncrono
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final neutralColor = context.onBg;
    // Calculado antes de limpar o carrinho.
    final orderImpact = _impactOf(cartProvider);

    var paidOnline = false;
    var ordersCreated = 0;

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        throw const PaymentException('Usuário não autenticado!');
      }

      final groups = _groupByStore(cartProvider);
      if (groups.containsKey('')) {
        throw const PaymentException(
          'Há um produto sem loja no carrinho. Atualize o catálogo e tente de novo.',
        );
      }

      final payOnline = _selectedPaymentMethod == _onlineMethodId;
      final cartSubtotal = cartProvider.total;

      // Monta um pedido por loja e valida TODOS antes de criar qualquer um,
      // para não deixar pedidos pela metade quando falta estoque.
      final plans = <_StoreOrderPlan>[];
      for (final entry in groups.entries) {
        final lines = entry.value
            .map((i) => OrderLineRequest(
                  productId: i.product.id,
                  quantity: i.quantity,
                  isDonation: i.origin == OriginType.doacao,
                ))
            .toList();
        final groupSubtotal =
            entry.value.fold<double>(0, (sum, i) => sum + i.subtotal);
        final cashback = _cashbackShare(groupSubtotal, cartSubtotal);

        final summary = await _orderService.validate(
          paymentMethod: _selectedPaymentMethod,
          cashback: cashback,
          lines: lines,
        );
        if (!summary.isValid) {
          throw PaymentException(summary.problems.join('\n'));
        }

        // Se o cashback cobre o pedido inteiro, não há o que cobrar online.
        final method = payOnline && summary.total <= 0
            ? 'Cashback'
            : _selectedPaymentMethod;
        plans.add(_StoreOrderPlan(
          items: entry.value,
          lines: lines,
          cashback: cashback,
          method: method,
          needsPayment: payOnline && summary.total > 0,
        ));
      }

      for (final plan in plans) {
        final order = await _orderService.create(
          paymentMethod: plan.method,
          cashback: plan.cashback,
          lines: plan.lines,
        );
        ordersCreated++;

        if (plan.needsPayment) {
          bool paid;
          try {
            paid = await _payOnline(navigator: navigator, orderId: order.id);
          } catch (_) {
            // Pagamento falhou: libera o estoque reservado antes de avisar.
            await _cancelQuietly(order.id);
            rethrow;
          }
          if (!paid) {
            await _cancelQuietly(order.id);
            messenger.showSnackBar(
              SnackBar(
                content: Text(ordersCreated > 1
                    ? 'Pagamento não concluído. Os itens das demais lojas foram mantidos no carrinho.'
                    : 'Pagamento não concluído. Seu carrinho foi mantido.'),
                backgroundColor: neutralColor,
              ),
            );
            return;
          }
          paidOnline = true;
        }

        // Pedido desta loja concluído: tira os itens dele do carrinho.
        for (final item in plan.items) {
          cartProvider.remove(item.product.id, originType: item.origin);
        }
      }

      // O saldo de cashback mudou na API; atualiza o perfil.
      await profileProvider.loadUserProfile();

      // Esconde o checkout antes de esvaziar o carrinho, para não aparecer
      // "R$ 0,00" atrás do diálogo de sucesso.
      if (mounted) setState(() => _orderPlaced = true);
      cartProvider.clear();

      if (!context.mounted) return;

      // Mostrar dialog de sucesso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: AlertDialog(
          backgroundColor: dialogContext.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.banner)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.greenAccent, size: 80),
              const SizedBox(height: 16),
              Text(
                'Pedido Realizado!',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: dialogContext.onBg,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                paidOnline
                    ? 'Pagamento aprovado! Seu pedido já está sendo preparado.'
                    : 'Seu pedido foi confirmado e já está sendo preparado.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: dialogContext.onBgMuted,
                  fontSize: 14,
                ),
              ),
              if (orderImpact.totalItems > 0) ...[
                const SizedBox(height: 12),
                Text(
                  'Você ajudou a salvar ${pluralize(orderImpact.totalItems, 'item', 'itens')} do desperdício.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: context.textOn(AppColors.greenAccent),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Fecha o diálogo e volta para o app (fecha checkout e carrinho).
                    navigator.popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                  ),
                  child: const Text('Entendido',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(_messageFor(e)),
          backgroundColor: AppColors.redPrimary,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _cancelQuietly(String orderId) async {
    try {
      await _orderService.cancel(orderId);
    } catch (_) {
      // Se não der para cancelar agora, a API expira o pedido pendente sozinha.
    }
  }
}

/// Um pedido a criar: os itens de uma loja e como cobrá-los.
class _StoreOrderPlan {
  final List<CartItem> items;
  final List<OrderLineRequest> lines;
  final double cashback;
  final String method;
  final bool needsPayment;

  const _StoreOrderPlan({
    required this.items,
    required this.lines,
    required this.cashback,
    required this.method,
    required this.needsPayment,
  });
}
