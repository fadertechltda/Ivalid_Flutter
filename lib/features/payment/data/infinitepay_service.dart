import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/payment_models.dart';
import '../domain/payment_config.dart';

/// Cliente do Checkout Integrado do InfinitePay.
///
/// Fluxo:
/// 1. [createCheckoutLink] cria o link de pagamento (`POST /links`).
/// 2. O cliente paga na página do InfinitePay e é redirecionado para
///    [PaymentConfig.redirectUrl] com `transaction_nsu` e `slug`.
/// 3. [checkPayment] confirma o pagamento (`POST /payment_check`).
///
/// A API não usa chave secreta, só o handle público. Por isso a confirmação
/// feita no próprio app serve para o TCC; em produção, confirme também por
/// webhook em um servidor.
class InfinitePayService {
  final http.Client _client;
  final String _handle;
  final String _baseUrl;
  final Duration _timeout;

  InfinitePayService({
    http.Client? client,
    String? handle,
    String? baseUrl,
    Duration timeout = const Duration(seconds: 20),
  })  : _client = client ?? http.Client(),
        _handle = handle ?? PaymentConfig.infinitePayHandle,
        _baseUrl = baseUrl ?? PaymentConfig.apiBaseUrl,
        _timeout = timeout;

  /// Cria o link de pagamento e devolve a URL do checkout.
  ///
  /// [amountCents] é o total a cobrar, em centavos. O pedido vai como um único
  /// item para que o valor cobrado seja exatamente o total (já com descontos de
  /// cashback), sem diferenças de arredondamento.
  Future<String> createCheckoutLink({
    required String orderNsu,
    required int amountCents,
    required String description,
    String? customerName,
    String? customerEmail,
  }) async {
    if (amountCents <= 0) {
      throw const PaymentException('Valor do pedido inválido para pagamento.');
    }

    final body = <String, dynamic>{
      'handle': _handle,
      'order_nsu': orderNsu,
      'redirect_url': PaymentConfig.redirectUrl,
      'items': [
        {
          'quantity': 1,
          'price': amountCents,
          'description': description,
        },
      ],
      if ((customerName != null && customerName.isNotEmpty) ||
          (customerEmail != null && customerEmail.isNotEmpty))
        'customer': {
          if (customerName != null && customerName.isNotEmpty)
            'name': customerName,
          if (customerEmail != null && customerEmail.isNotEmpty)
            'email': customerEmail,
        },
    };

    final json = await _post('/links', body);
    final url = json['url'];
    if (url is! String || url.isEmpty) {
      throw PaymentException(
        _messageFrom(json) ?? 'O InfinitePay não devolveu o link de pagamento.',
      );
    }
    return url;
  }

  /// Consulta se o pagamento foi concluído. Devolve `null` enquanto o
  /// InfinitePay não confirmar (ainda processando, não pago ou inexistente).
  Future<PaymentConfirmation?> checkPayment(CheckoutRedirect redirect) async {
    final json = await _post('/payment_check', {
      'handle': _handle,
      'order_nsu': redirect.orderNsu,
      'transaction_nsu': redirect.transactionNsu,
      'slug': redirect.slug,
    });

    if (json['success'] != true || json['paid'] != true) return null;

    final amount = (json['amount'] as num?)?.toInt() ?? 0;
    return PaymentConfirmation(
      amountCents: amount,
      paidAmountCents: (json['paid_amount'] as num?)?.toInt() ?? amount,
      installments: (json['installments'] as num?)?.toInt() ?? 1,
      captureMethod:
          (json['capture_method'] as String?) ?? redirect.captureMethod,
      transactionNsu: redirect.transactionNsu,
      receiptUrl: redirect.receiptUrl,
    );
  }

  /// Confirma o pagamento tentando algumas vezes, já que a aprovação pode levar
  /// alguns segundos para aparecer logo após o redirecionamento.
  Future<PaymentConfirmation?> confirmWithRetry(
    CheckoutRedirect redirect, {
    int attempts = 4,
    Duration wait = const Duration(seconds: 2),
  }) async {
    for (var i = 0; i < attempts; i++) {
      final result = await checkPayment(redirect);
      if (result != null) return result;
      if (i < attempts - 1) await Future<void>.delayed(wait);
    }
    return null;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw const PaymentException(
        'O InfinitePay demorou para responder. Tente novamente.',
      );
    } catch (_) {
      throw const PaymentException(
        'Sem conexão com o InfinitePay. Verifique sua internet.',
      );
    }

    Map<String, dynamic> json = const {};
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) json = decoded;
    } catch (_) {
      // Corpo que não é JSON: tratado abaixo pelo código de status.
    }

    // `/payment_check` responde 200 com `success: false` quando não há
    // pagamento; só os demais códigos de erro viram exceção.
    if (response.statusCode >= 400) {
      throw PaymentException(
        _messageFrom(json) ??
            'Não foi possível falar com o InfinitePay (código ${response.statusCode}).',
      );
    }
    return json;
  }

  static String? _messageFrom(Map<String, dynamic> json) {
    final message = json['message'];
    if (message is String && message.isNotEmpty) return message;
    final error = json['error'];
    if (error is String && error.isNotEmpty) return error;
    return null;
  }

  void dispose() => _client.close();
}
