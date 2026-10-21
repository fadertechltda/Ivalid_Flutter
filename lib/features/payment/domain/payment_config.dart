/// Configuração do pagamento online (InfinitePay).
///
/// A cobrança é feita pela API: o app só abre a página de pagamento numa
/// WebView e devolve à API os identificadores do pagamento. Aqui fica apenas a
/// URL de retorno, que precisa ser igual a `Pagamento:RedirectUrl` da API.
class PaymentConfig {
  PaymentConfig._();

  /// URL para a qual o InfinitePay redireciona após o pagamento.
  ///
  /// O app intercepta a navegação para esta URL dentro da WebView, então ela
  /// nunca é carregada de fato. O domínio `.invalid` é reservado e jamais
  /// resolve.
  static const String redirectUrl = 'https://ivalid.invalid/pagamento-concluido';
}
