/// Configuração do pagamento online (InfinitePay).
///
/// Nada aqui é segredo: o checkout integrado identifica o recebedor apenas
/// pela InfiniteTag (handle) pública. Ainda assim, dá para trocar sem editar o
/// código:
///
///   flutter run --dart-define=INFINITEPAY_HANDLE=outra-tag
///   flutter run --dart-define=PAYMENT_DEMO=true
class PaymentConfig {
  PaymentConfig._();

  /// InfiniteTag do recebedor, SEM o "$".
  static const String infinitePayHandle = String.fromEnvironment(
    'INFINITEPAY_HANDLE',
    defaultValue: 'lucas-freitas-fe',
  );

  /// Modo demonstração: simula o pagamento aprovado, sem chamar o InfinitePay.
  /// Útil para apresentar sem rede ou sem movimentar dinheiro.
  static const bool demoMode = bool.fromEnvironment('PAYMENT_DEMO');

  /// URL para a qual o InfinitePay redireciona após o pagamento.
  ///
  /// O app intercepta a navegação para esta URL dentro da WebView, então ela
  /// nunca é carregada de fato. Precisa ser `https` (esquemas próprios como
  /// `ivalid://` são recusados pela API) e o domínio `.invalid` é reservado e
  /// jamais resolve.
  static const String redirectUrl = 'https://ivalid.invalid/pagamento-concluido';

  static const String apiBaseUrl = 'https://api.checkout.infinitepay.io';
}
