/// Tokens de forma e espaçamento do design system Ivalid.
///
/// Consolidam os valores que já se repetem nas telas (cards de raio 18,
/// controles de raio 16, chips de raio 12...). Componentes novos devem usar
/// estes tokens em vez de números soltos.
class AppRadius {
  AppRadius._();

  /// Chips, seletores e itens de lista.
  static const double chip = 12;

  /// Campos, botões e controles.
  static const double control = 16;

  /// Cards e superfícies principais.
  static const double card = 18;

  /// Cards de destaque e modais.
  static const double sheet = 24;
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;

  /// Margem horizontal padrão das telas.
  static const double screen = 20;
}
