/// Configuração do acesso à API do Ivalid (IValid_Web / WEB_API).
///
/// Nada aqui é segredo. O app usa apenas o token do Firebase do usuário; a
/// chave interna (`X-Internal-Api-Key`) é do painel e NUNCA deve entrar no app.
///
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/
///
/// No emulador Android, `10.0.2.2` é o computador onde o emulador roda.
class ApiConfig {
  ApiConfig._();

  /// URL pública da API, com `/` no final.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://ivalid-api.onrender.com/',
  );

  /// O Render pode "acordar" a API devagar no primeiro acesso.
  static const Duration timeout = Duration(seconds: 30);
}
