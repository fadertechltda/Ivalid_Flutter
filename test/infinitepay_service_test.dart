import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ivalid/features/payment/data/infinitepay_service.dart';
import 'package:ivalid/features/payment/domain/models/payment_models.dart';
import 'package:ivalid/features/payment/domain/payment_config.dart';

http.Response _json(Object body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

InfinitePayService _service(MockClient client) => InfinitePayService(
      client: client,
      handle: 'minha-tag',
      baseUrl: 'https://api.test',
    );

const _redirect = CheckoutRedirect(
  orderNsu: 'pedido-1',
  transactionNsu: 'tx-1',
  slug: 'abc',
  captureMethod: 'pix',
  receiptUrl: 'https://comprovante/1',
);

void main() {
  group('createCheckoutLink', () {
    test('envia handle, valor em centavos, order_nsu e redirect_url', () async {
      late http.Request sent;
      final service = _service(MockClient((req) async {
        sent = req;
        return _json({'url': 'https://checkout.infinitepay.io/minha-tag?x=1'});
      }));

      final url = await service.createCheckoutLink(
        orderNsu: 'pedido-1',
        amountCents: 1990,
        description: 'Pedido Ivalid (2 itens)',
        customerName: 'Ana',
        customerEmail: 'ana@email.com',
      );

      expect(url, 'https://checkout.infinitepay.io/minha-tag?x=1');
      expect(sent.url.toString(), 'https://api.test/links');
      final body = jsonDecode(sent.body) as Map<String, dynamic>;
      expect(body['handle'], 'minha-tag');
      expect(body['order_nsu'], 'pedido-1');
      expect(body['redirect_url'], PaymentConfig.redirectUrl);
      expect(body['items'], [
        {'quantity': 1, 'price': 1990, 'description': 'Pedido Ivalid (2 itens)'},
      ]);
      expect(body['customer'], {'name': 'Ana', 'email': 'ana@email.com'});
    });

    test('não envia customer quando não há dados', () async {
      late Map<String, dynamic> body;
      final service = _service(MockClient((req) async {
        body = jsonDecode(req.body) as Map<String, dynamic>;
        return _json({'url': 'https://x'});
      }));

      await service.createCheckoutLink(
        orderNsu: 'p',
        amountCents: 100,
        description: 'd',
      );
      expect(body.containsKey('customer'), isFalse);
    });

    test('recusa valor zerado ou negativo sem chamar a API', () async {
      var calls = 0;
      final service = _service(MockClient((req) async {
        calls++;
        return _json({'url': 'https://x'});
      }));

      expect(
        () => service.createCheckoutLink(
            orderNsu: 'p', amountCents: 0, description: 'd'),
        throwsA(isA<PaymentException>()),
      );
      expect(calls, 0);
    });

    test('mostra a mensagem de erro devolvida pela API', () async {
      final service = _service(MockClient((req) async => _json({
            'success': false,
            'error': 'external_checkout_not_enabled',
            'message': 'External checkout is not enabled for this merchant.',
          }, 404)));

      expect(
        () => service.createCheckoutLink(
            orderNsu: 'p', amountCents: 100, description: 'd'),
        throwsA(isA<PaymentException>().having(
          (e) => e.message,
          'message',
          contains('not enabled'),
        )),
      );
    });

    test('falha quando a resposta não traz a url', () async {
      final service = _service(MockClient((req) async => _json({'ok': true})));
      expect(
        () => service.createCheckoutLink(
            orderNsu: 'p', amountCents: 100, description: 'd'),
        throwsA(isA<PaymentException>()),
      );
    });

    test('erro de rede vira mensagem amigável', () async {
      final service =
          _service(MockClient((req) async => throw http.ClientException('x')));
      expect(
        () => service.createCheckoutLink(
            orderNsu: 'p', amountCents: 100, description: 'd'),
        throwsA(isA<PaymentException>().having(
          (e) => e.message,
          'message',
          contains('conexão'),
        )),
      );
    });
  });

  group('checkPayment', () {
    test('devolve confirmação quando paid = true', () async {
      late Map<String, dynamic> body;
      final service = _service(MockClient((req) async {
        body = jsonDecode(req.body) as Map<String, dynamic>;
        return _json({
          'success': true,
          'paid': true,
          'amount': 1500,
          'paid_amount': 1510,
          'installments': 1,
          'capture_method': 'pix',
        });
      }));

      final result = await service.checkPayment(_redirect);

      expect(result, isNotNull);
      expect(result!.amountCents, 1500);
      expect(result.paidAmountCents, 1510);
      expect(result.captureMethod, 'pix');
      expect(result.transactionNsu, 'tx-1');
      expect(result.receiptUrl, 'https://comprovante/1');
      expect(body, {
        'handle': 'minha-tag',
        'order_nsu': 'pedido-1',
        'transaction_nsu': 'tx-1',
        'slug': 'abc',
      });
    });

    test('devolve null quando a API responde success: false', () async {
      final service =
          _service(MockClient((req) async => _json({'success': false})));
      expect(await service.checkPayment(_redirect), isNull);
    });

    test('devolve null quando paid = false', () async {
      final service = _service(
          MockClient((req) async => _json({'success': true, 'paid': false})));
      expect(await service.checkPayment(_redirect), isNull);
    });
  });

  group('confirmWithRetry', () {
    test('tenta de novo até o pagamento aparecer', () async {
      var calls = 0;
      final service = _service(MockClient((req) async {
        calls++;
        return calls < 3
            ? _json({'success': false})
            : _json({
                'success': true,
                'paid': true,
                'amount': 500,
                'capture_method': 'credit_card',
              });
      }));

      final result = await service.confirmWithRetry(
        _redirect,
        wait: Duration.zero,
      );

      expect(calls, 3);
      expect(result?.captureMethod, 'credit_card');
    });

    test('desiste depois do limite de tentativas', () async {
      var calls = 0;
      final service = _service(MockClient((req) async {
        calls++;
        return _json({'success': false});
      }));

      final result = await service.confirmWithRetry(
        _redirect,
        attempts: 3,
        wait: Duration.zero,
      );

      expect(result, isNull);
      expect(calls, 3);
    });
  });

  group('CheckoutRedirect.tryParse', () {
    test('lê os parâmetros do redirecionamento', () {
      final r = CheckoutRedirect.tryParse(Uri.parse(
        '${PaymentConfig.redirectUrl}?order_nsu=p1&transaction_nsu=t1&slug=s1'
        '&capture_method=pix&receipt_url=https%3A%2F%2Fcomprovante%2F9',
      ));

      expect(r, isNotNull);
      expect(r!.orderNsu, 'p1');
      expect(r.transactionNsu, 't1');
      expect(r.slug, 's1');
      expect(r.captureMethod, 'pix');
      expect(r.receiptUrl, 'https://comprovante/9');
    });

    test('devolve null quando falta identificador', () {
      expect(
        CheckoutRedirect.tryParse(
            Uri.parse('${PaymentConfig.redirectUrl}?order_nsu=p1')),
        isNull,
      );
    });
  });
}
