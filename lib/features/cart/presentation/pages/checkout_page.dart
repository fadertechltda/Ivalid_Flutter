import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onBackgroundLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Finalizar Pedido',
          style: GoogleFonts.inter(
            color: AppColors.onBackgroundLight,
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
                        _buildSectionTitle('Resumo dos Itens'),
                        const SizedBox(height: 12),
                        _buildItemsList(cartProvider),
                        const SizedBox(height: 30),
                        _buildSectionTitle('Método de Pagamento'),
                        const SizedBox(height: 12),
                        _buildPaymentMethods(),
                      ],
                    ),
                  ),
                ),
                _buildBottomSummary(cartProvider),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.onBackgroundLight,
      ),
    );
  }

  Widget _buildItemsList(CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
            Divider(color: Colors.grey.shade100, height: 1),
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
                      color: AppColors.onBackgroundLight,
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
                    color: AppColors.onBackgroundLight,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentMethods() {
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
                    ? AppColors.redPrimary.withValues(alpha: 0.05)
                    : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.redPrimary
                      : AppColors.outlineLight,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    method['icon'],
                    color: isEnabled
                        ? (isSelected ? AppColors.redPrimary : Colors.grey)
                        : Colors.grey.shade300,
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
                                ? AppColors.onBackgroundLight
                                : Colors.grey.shade400,
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
                              : Colors.grey.shade400,
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

  Widget _buildBottomSummary(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total a pagar',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackgroundLight,
                  ),
                ),
                Text(
                  'R\$ ${cartProvider.total.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.redPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _processOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
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

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Usuário não autenticado!");
      }

      final itemsData = cartProvider.items.map((item) {
        return {
          'name': item.product.name,
          'quantity': item.quantity,
          'subtotal': item.subtotal,
        };
      }).toList();

      final orderData = {
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'total': cartProvider.total,
        'status': _selectedPaymentMethod == 'Pix'
            ? 'Pagamento Pix Pendente'
            : 'Em preparação',
        'itens': itemsData,
      };

      await FirebaseFirestore.instance.collection('pedidos').add(orderData);

      // Limpar carrinho
      cartProvider.clear();

      if (!context.mounted) return;

      // Mostrar dialog de sucesso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
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
                  color: AppColors.onBackgroundLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Seu pedido foi confirmado e já está sendo preparado.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.grey.shade600,
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
