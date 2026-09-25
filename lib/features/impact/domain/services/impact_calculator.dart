import '../../../donation/domain/services/donation_gamification_service.dart';
import '../../../home/domain/models/product.dart';
import '../models/impact_metrics.dart';

/// Uma linha de compra vista pela calculadora: independe de carrinho, pedido
/// ou Firestore, o que a mantém simples de testar.
class ImpactLine {
  final int quantity;

  /// Preço unitário original (sem desconto de validade).
  final double originalUnitPrice;

  /// Preço unitário efetivamente pago.
  final double paidUnitPrice;

  final bool isDonation;

  const ImpactLine({
    required this.quantity,
    required this.originalUnitPrice,
    required this.paidUnitPrice,
    required this.isDonation,
  });

  factory ImpactLine.fromProduct(
    Product product,
    int quantity, {
    required bool isDonation,
  }) {
    return ImpactLine(
      quantity: quantity,
      originalUnitPrice: product.oldPrice,
      paidUnitPrice: product.priceNow,
      isDonation: isDonation,
    );
  }
}

/// Resultado de uma simulação de impacto.
class ImpactProjection {
  final ImpactMetrics metrics;

  /// Cashback estimado gerado pelas doações simuladas.
  final double cashbackEarned;

  final FidelityLevel startLevel;
  final FidelityLevel endLevel;

  const ImpactProjection({
    required this.metrics,
    required this.cashbackEarned,
    required this.startLevel,
    required this.endLevel,
  });

  bool get levelsUp => endLevel != startLevel;
}

/// Calculadora de impacto social — metodologia v1 (sem peso).
///
/// Regras:
/// * Todo item comprado pela plataforma conta como "item resgatado" (consumo
///   próprio) ou "item doado" (doação a ONG).
/// * A economia do usuário só existe em compras para consumo próprio: é a
///   diferença entre preço original e preço pago, nunca negativa.
/// * Nas doações registra-se o valor pago, mas não há "economia".
///
/// Serviço puro (sem UI nem Firebase), no mesmo padrão do
/// [DonationGamificationService].
class ImpactCalculator {
  /// Versão gravada junto ao impacto de cada pedido. Mudar a fórmula exige
  /// incrementar este número para que o histórico continue interpretável.
  static const int methodologyVersion = 1;

  static const double _weeksPerMonth = 52 / 12;

  final DonationGamificationService _gamification;

  ImpactCalculator({DonationGamificationService? gamification})
      : _gamification = gamification ?? DonationGamificationService();

  /// Impacto real de um conjunto de linhas (ex.: os itens de um pedido).
  ImpactMetrics forLines(Iterable<ImpactLine> lines) {
    var rescued = 0;
    var donated = 0;
    var saved = 0.0;
    var donatedValue = 0.0;

    for (final line in lines) {
      if (line.quantity <= 0) continue;

      if (line.isDonation) {
        donated += line.quantity;
        donatedValue += line.paidUnitPrice * line.quantity;
      } else {
        rescued += line.quantity;
        final discount = line.originalUnitPrice - line.paidUnitPrice;
        if (discount > 0) saved += discount * line.quantity;
      }
    }

    return ImpactMetrics(
      itemsRescued: rescued,
      itemsDonated: donated,
      savedReais: _round2(saved),
      donatedReais: _round2(donatedValue),
    );
  }

  /// Simula o impacto de um ritmo de compras ao longo de [months] meses.
  ///
  /// * [itemsPerWeek]: itens comprados por semana.
  /// * [donationShare]: fração (0 a 1) desses itens destinada à doação.
  /// * [avgOriginalUnitPrice] / [avgPaidUnitPrice]: preços médios de referência
  ///   (ex.: média do catálogo atual).
  /// * [currentDonationCount]: doações já feitas (define o nível de partida).
  ///
  /// O cashback é calculado mês a mês, pois o nível — e portanto o percentual —
  /// pode subir durante o período.
  ImpactProjection project({
    required int itemsPerWeek,
    required int months,
    required double donationShare,
    required double avgOriginalUnitPrice,
    required double avgPaidUnitPrice,
    required int currentDonationCount,
  }) {
    final safeItemsPerWeek = itemsPerWeek < 0 ? 0 : itemsPerWeek;
    final safeMonths = months < 0 ? 0 : months;
    final share = donationShare.clamp(0.0, 1.0).toDouble();

    final totalItems =
        (safeItemsPerWeek * safeMonths * _weeksPerMonth).round();
    final donated = (totalItems * share).round();
    final rescued = totalItems - donated;

    final unitDiscount = avgOriginalUnitPrice - avgPaidUnitPrice;
    final saved = unitDiscount > 0 ? rescued * unitDiscount : 0.0;
    final donatedValue = donated * avgPaidUnitPrice;

    var cashback = 0.0;
    if (safeMonths > 0 && donated > 0) {
      final donatedPerMonth = donated / safeMonths;
      var runningCount = currentDonationCount;
      for (var m = 0; m < safeMonths; m++) {
        cashback += _gamification.calculateCashback(
          donatedPerMonth * avgPaidUnitPrice,
          runningCount,
        );
        runningCount = currentDonationCount +
            (donatedPerMonth * (m + 1)).floor();
      }
    }

    return ImpactProjection(
      metrics: ImpactMetrics(
        itemsRescued: rescued,
        itemsDonated: donated,
        savedReais: _round2(saved),
        donatedReais: _round2(donatedValue),
      ),
      cashbackEarned: _round2(cashback),
      startLevel: _gamification.getLevelForDonationCount(currentDonationCount),
      endLevel: _gamification
          .getLevelForDonationCount(currentDonationCount + donated),
    );
  }

  static double _round2(double v) => (v * 100).roundToDouble() / 100;
}
