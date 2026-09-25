/// Métricas de impacto social acumuladas — de um pedido, de um usuário ou de
/// uma simulação.
///
/// Nesta versão (metodologia v1) o impacto é medido **sem peso**: usa apenas
/// quantidades de itens e valores em reais, que já existem no app. Quando a API
/// passar a fornecer o peso dos produtos, basta acrescentar novos campos aqui
/// (ex.: `kgSaved`) e um novo `methodologyVersion` no [ImpactCalculator]; os
/// campos atuais continuam válidos.
class ImpactMetrics {
  /// Itens comprados para consumo próprio (a preço reduzido) que, sem a
  /// plataforma, provavelmente seriam descartados.
  final int itemsRescued;

  /// Itens comprados para doação a ONGs parceiras.
  final int itemsDonated;

  /// Economia do usuário: soma de (preço original − preço pago) nos itens
  /// comprados para consumo próprio.
  final double savedReais;

  /// Valor pago em itens destinados a doação.
  final double donatedReais;

  const ImpactMetrics({
    this.itemsRescued = 0,
    this.itemsDonated = 0,
    this.savedReais = 0.0,
    this.donatedReais = 0.0,
  });

  static const ImpactMetrics empty = ImpactMetrics();

  /// Total de itens que deixaram de ser desperdiçados (consumo + doação).
  int get totalItems => itemsRescued + itemsDonated;

  bool get isEmpty => totalItems == 0 && savedReais == 0 && donatedReais == 0;

  ImpactMetrics operator +(ImpactMetrics other) => ImpactMetrics(
        itemsRescued: itemsRescued + other.itemsRescued,
        itemsDonated: itemsDonated + other.itemsDonated,
        savedReais: _round2(savedReais + other.savedReais),
        donatedReais: _round2(donatedReais + other.donatedReais),
      );

  Map<String, dynamic> toMap() => {
        'itemsRescued': itemsRescued,
        'itemsDonated': itemsDonated,
        'savedReais': savedReais,
        'donatedReais': donatedReais,
      };

  /// Aceita `null` e campos ausentes/`num` de qualquer tipo, para tolerar
  /// documentos antigos ou parcialmente preenchidos no Firestore.
  factory ImpactMetrics.fromMap(Map<String, dynamic>? map) {
    if (map == null) return ImpactMetrics.empty;
    return ImpactMetrics(
      itemsRescued: (map['itemsRescued'] as num?)?.toInt() ?? 0,
      itemsDonated: (map['itemsDonated'] as num?)?.toInt() ?? 0,
      savedReais: (map['savedReais'] as num?)?.toDouble() ?? 0.0,
      donatedReais: (map['donatedReais'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static double _round2(double v) => (v * 100).roundToDouble() / 100;
}
