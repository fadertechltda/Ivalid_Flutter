enum FidelityLevel {
  bronze(minDonations: 0, maxDonations: 10, cashbackMultiplier: 0.01, label: "Bronze (1%)"),
  prata(minDonations: 11, maxDonations: 30, cashbackMultiplier: 0.03, label: "Prata (3%)"),
  ouro(minDonations: 31, maxDonations: null, cashbackMultiplier: 0.05, label: "Ouro (5%)");

  final int minDonations;
  final int? maxDonations;
  final double cashbackMultiplier;
  final String label;

  const FidelityLevel({
    required this.minDonations,
    required this.maxDonations,
    required this.cashbackMultiplier,
    required this.label,
  });
}

class UserDonationStats {
  final int totalDonations;
  final double pendingCashback;
  final double availableCashback;

  UserDonationStats({
    required this.totalDonations,
    required this.pendingCashback,
    required this.availableCashback,
  });
}

class DonationGamificationService {
  /// Define o nível do usuário baseado na quantidade de doações.
  FidelityLevel getLevelForDonationCount(int count) {
    if (count >= FidelityLevel.bronze.minDonations &&
        (FidelityLevel.bronze.maxDonations == null || count <= FidelityLevel.bronze.maxDonations!)) {
      return FidelityLevel.bronze;
    } else if (count >= FidelityLevel.prata.minDonations &&
        (FidelityLevel.prata.maxDonations == null || count <= FidelityLevel.prata.maxDonations!)) {
      return FidelityLevel.prata;
    } else {
      return FidelityLevel.ouro;
    }
  }

  /// Calcula o cashback ganho para uma determinada doação
  /// baseado no nível atual do usuário.
  double calculateCashback(double donationValue, int currentDonationCount) {
    final level = getLevelForDonationCount(currentDonationCount);
    return donationValue * level.cashbackMultiplier;
  }

  /// Retorna quantas doações faltam para atingir o próximo nível,
  /// ou null se o usuário já estiver no nível máximo.
  int? getDonationsNeededForNextLevel(int count) {
    final level = getLevelForDonationCount(count);
    if (level.maxDonations != null) {
      return (level.maxDonations! + 1) - count;
    }
    return null;
  }

  /// Retorna o máximo desconto possível em uma compra (Trava de segurança de 15%).
  double calculateMaxDiscountAllowed(double cartTotal, double availableCashback) {
    final maxAllowedByRule = cartTotal * 0.15;
    return availableCashback > maxAllowedByRule ? maxAllowedByRule : availableCashback;
  }

  /// Validação simples para ver se um crédito está expirado (Validade de 45 dias)
  bool isCashbackCreditValid(int createdAtTimestampMs, int currentTimestampMs) {
    const fortyFiveDaysInMillis = 45 * 24 * 60 * 60 * 1000;
    return (currentTimestampMs - createdAtTimestampMs) <= fortyFiveDaysInMillis;
  }
}
