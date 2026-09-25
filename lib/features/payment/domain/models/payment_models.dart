/// Dados devolvidos pelo InfinitePay na URL de redirecionamento, depois que o
/// cliente conclui o pagamento no checkout.
class CheckoutRedirect {
  final String orderNsu;
  final String transactionNsu;
  final String slug;
  final String captureMethod;
  final String? receiptUrl;

  const CheckoutRedirect({
    required this.orderNsu,
    required this.transactionNsu,
    required this.slug,
    required this.captureMethod,
    this.receiptUrl,
  });

  /// Lê os parâmetros da `redirect_url`. Devolve `null` se faltar algum dos
  /// identificadores necessários para consultar o pagamento.
  static CheckoutRedirect? tryParse(Uri uri) {
    final q = uri.queryParameters;
    final orderNsu = q['order_nsu'];
    final transactionNsu = q['transaction_nsu'];
    final slug = q['slug'];
    if (orderNsu == null ||
        transactionNsu == null ||
        slug == null ||
        orderNsu.isEmpty ||
        transactionNsu.isEmpty ||
        slug.isEmpty) {
      return null;
    }
    return CheckoutRedirect(
      orderNsu: orderNsu,
      transactionNsu: transactionNsu,
      slug: slug,
      captureMethod: q['capture_method'] ?? '',
      receiptUrl: q['receipt_url'],
    );
  }
}

/// Resultado de um pagamento confirmado.
class PaymentConfirmation {
  final int amountCents;
  final int paidAmountCents;
  final int installments;

  /// `pix`, `credit_card` ou `demo`.
  final String captureMethod;
  final String transactionNsu;
  final String? receiptUrl;

  const PaymentConfirmation({
    required this.amountCents,
    required this.paidAmountCents,
    required this.installments,
    required this.captureMethod,
    required this.transactionNsu,
    this.receiptUrl,
  });

  Map<String, dynamic> toMap() => {
        'provider': captureMethod == 'demo' ? 'demo' : 'infinitepay',
        'method': captureMethod,
        'amountCents': amountCents,
        'paidAmountCents': paidAmountCents,
        'installments': installments,
        'transactionNsu': transactionNsu,
        if (receiptUrl != null) 'receiptUrl': receiptUrl,
      };
}

/// Falha ao falar com o gateway. A [message] já é apropriada para o usuário.
class PaymentException implements Exception {
  final String message;
  const PaymentException(this.message);

  @override
  String toString() => message;
}
