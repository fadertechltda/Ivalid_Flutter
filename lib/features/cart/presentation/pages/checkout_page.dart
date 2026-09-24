import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/cart_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class CheckoutPage extends StatefulWidget {
  final double appliedCashback;

  const CheckoutPage({super.key, this.appliedCashback = 0.0});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPaymentMethod = 'Dinheiro';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'Dinheiro',
      'label': 'Dinheiro',
      'icon': Icons.payments_outlined,
      'enabled': true,
    },
    {
      'id': 'Pix',
      'label': 'PIX',
      'icon': Icons.qr_code_rounded,
      'enabled': true,
    },
    {
      'id': 'Cartão',
      'label': 'Cartão de Crédito/Débito',
      'icon': Icons.credit_card_rounded,
      'enabled': true,
    },
    {
      'id': 'Voucher',
      'label': 'Voucher / Vale Alimento',
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
      body: _isProcessing
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
        borderRadius: BorderRadius.circular(16),
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
                    color: AppColors.redPrimary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
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
                Text(
                  'R\$ ${item.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
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
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.softBg(AppColors.redPrimary)
                    : context.surface,
                borderRadius: BorderRadius.circular(12),
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
                      color: context.onBgAlpha(0.6),
                    ),
                  ),
                  Text(
                    'R\$ ${cartProvider.total.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: context.onBgAlpha(0.6),
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
                      color: AppColors.greenAccent,
                    ),
                  ),
                  Text(
                    '- R\$ ${widget.appliedCashback.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.greenAccent,
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
                  'R\$ ${finalTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.redPrimary,
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Center(
                  child: Text(
                    'Confirmar e Pagar',
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

  Future<void> _processOrder(BuildContext context) async {
    setState(() => _isProcessing = true);

    // Captura referências antes do gap assíncrono
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado!");
      }

      // Verificação de itens de doação no pedido
      final donationItems = cartProvider.items
          .where((item) => item.origin == OriginType.doacao)
          .toList();
      final int donationItemsCount =
          donationItems.fold(0, (acc, item) => acc + item.quantity);
      final double donationSubtotal =
          donationItems.fold(0.0, (acc, item) => acc + item.subtotal);
      final bool hasDonations = donationItemsCount > 0;
      final double finalTotal = (cartProvider.total - widget.appliedCashback).clamp(0.0, double.infinity);

      final itemsData = cartProvider.items.map((item) {
        return {
          'name': item.product.name,
          'quantity': item.quantity,
          'subtotal': item.subtotal,
          'origin': item.origin.name,
          'isDonation': item.origin == OriginType.doacao,
        };
      }).toList();

      final orderData = {
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'subtotal': cartProvider.total,
        'cashbackUsed': widget.appliedCashback,
        'total': finalTotal,
        'hasDonations': hasDonations,
        'donationItemsCount': donationItemsCount,
        'donationSubtotal': donationSubtotal,
        'status': _selectedPaymentMethod == 'Pix'
            ? 'Pagamento Pix Pendente'
            : 'Em preparação',
        'itens': itemsData,
      };

      await FirebaseFirestore.instance.collection('pedidos').add(orderData);

      // Se utilizou cashback no pedido, deduz do saldo do cliente
      if (widget.appliedCashback > 0) {
        await profileProvider.deductCashback(widget.appliedCashback);
      }

      // Se houver doação, atualiza o cadastro do cliente (total de doações e cashback do nível)
      if (hasDonations) {
        await profileProvider.processDonationFromOrder(
          donationCount: donationItemsCount,
          donationSubtotal: donationSubtotal,
        );
      }

      // Limpar carrinho
      cartProvider.clear();

      if (!context.mounted) return;

      // Mostrar dialog de sucesso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: dialogContext.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                'Seu pedido foi confirmado e já está sendo preparado.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: dialogContext.onBgAlpha(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    navigator.pop(); // Fecha dialog
                    navigator.pop(); // Volta do checkout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Entendido',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao finalizar pedido: $e'),
          backgroundColor: AppColors.redPrimary,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
