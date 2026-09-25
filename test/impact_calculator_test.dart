import 'package:flutter_test/flutter_test.dart';
import 'package:ivalid/features/donation/domain/services/donation_gamification_service.dart';
import 'package:ivalid/features/impact/domain/models/impact_metrics.dart';
import 'package:ivalid/features/impact/domain/services/impact_calculator.dart';

void main() {
  final calculator = ImpactCalculator();

  group('ImpactCalculator.forLines', () {
    test('conta itens e economia de compras para consumo próprio', () {
      final result = calculator.forLines(const [
        ImpactLine(
          quantity: 3,
          originalUnitPrice: 10.0,
          paidUnitPrice: 6.0,
          isDonation: false,
        ),
      ]);

      expect(result.itemsRescued, 3);
      expect(result.itemsDonated, 0);
      expect(result.savedReais, 12.0);
      expect(result.donatedReais, 0.0);
    });

    test('doação conta itens e valor pago, mas não gera economia', () {
      final result = calculator.forLines(const [
        ImpactLine(
          quantity: 2,
          originalUnitPrice: 10.0,
          paidUnitPrice: 6.0,
          isDonation: true,
        ),
      ]);

      expect(result.itemsRescued, 0);
      expect(result.itemsDonated, 2);
      expect(result.savedReais, 0.0);
      expect(result.donatedReais, 12.0);
    });

    test('pedido misto soma consumo e doação separadamente', () {
      final result = calculator.forLines(const [
        ImpactLine(
          quantity: 1,
          originalUnitPrice: 8.0,
          paidUnitPrice: 5.0,
          isDonation: false,
        ),
        ImpactLine(
          quantity: 4,
          originalUnitPrice: 5.0,
          paidUnitPrice: 2.5,
          isDonation: true,
        ),
      ]);

      expect(result.totalItems, 5);
      expect(result.savedReais, 3.0);
      expect(result.donatedReais, 10.0);
    });

    test('preço original zerado ou menor que o pago nunca gera economia negativa',
        () {
      final result = calculator.forLines(const [
        ImpactLine(
          quantity: 2,
          originalUnitPrice: 0.0,
          paidUnitPrice: 4.0,
          isDonation: false,
        ),
      ]);

      expect(result.itemsRescued, 2);
      expect(result.savedReais, 0.0);
    });

    test('ignora quantidades zeradas ou negativas e lista vazia', () {
      expect(calculator.forLines(const []).isEmpty, isTrue);
      expect(
        calculator.forLines(const [
          ImpactLine(
            quantity: 0,
            originalUnitPrice: 10,
            paidUnitPrice: 5,
            isDonation: false,
          ),
          ImpactLine(
            quantity: -3,
            originalUnitPrice: 10,
            paidUnitPrice: 5,
            isDonation: true,
          ),
        ]).isEmpty,
        isTrue,
      );
    });

    test('arredonda valores em reais para centavos', () {
      final result = calculator.forLines(const [
        ImpactLine(
          quantity: 3,
          originalUnitPrice: 1.0,
          paidUnitPrice: 0.6666,
          isDonation: false,
        ),
      ]);

      expect(result.savedReais, 1.0); // 3 * 0.3334 = 1.0002 -> 1.00
    });
  });

  group('ImpactCalculator.project', () {
    test('divide os itens entre consumo e doação conforme a fração', () {
      final p = calculator.project(
        itemsPerWeek: 4,
        months: 3,
        donationShare: 0.5,
        avgOriginalUnitPrice: 10,
        avgPaidUnitPrice: 6,
        currentDonationCount: 0,
      );

      // 4 * 3 * (52/12) = 52 itens
      expect(p.metrics.totalItems, 52);
      expect(p.metrics.itemsDonated, 26);
      expect(p.metrics.itemsRescued, 26);
      expect(p.metrics.savedReais, 104.0); // 26 * 4
      expect(p.metrics.donatedReais, 156.0); // 26 * 6
    });

    test('sem doação não há cashback nem mudança de nível', () {
      final p = calculator.project(
        itemsPerWeek: 5,
        months: 6,
        donationShare: 0,
        avgOriginalUnitPrice: 10,
        avgPaidUnitPrice: 6,
        currentDonationCount: 5,
      );

      expect(p.metrics.itemsDonated, 0);
      expect(p.cashbackEarned, 0.0);
      expect(p.levelsUp, isFalse);
      expect(p.startLevel, FidelityLevel.bronze);
    });

    test('doar bastante faz o usuário subir de nível', () {
      final p = calculator.project(
        itemsPerWeek: 10,
        months: 12,
        donationShare: 1,
        avgOriginalUnitPrice: 10,
        avgPaidUnitPrice: 5,
        currentDonationCount: 0,
      );

      expect(p.startLevel, FidelityLevel.bronze);
      expect(p.endLevel, FidelityLevel.ouro);
      expect(p.levelsUp, isTrue);
      expect(p.cashbackEarned, greaterThan(0));
    });

    test('cashback usa o nível do momento (mês a mês)', () {
      // Começa em Ouro (5%): 1 mês, 10 itens doados a R$ 10 = R$ 100 -> R$ 5.
      final p = calculator.project(
        itemsPerWeek: 3,
        months: 1,
        donationShare: 1,
        avgOriginalUnitPrice: 10,
        avgPaidUnitPrice: 10,
        currentDonationCount: 40,
      );

      // 3 * 1 * 4.333 = 13 itens * R$ 10 = R$ 130 * 5%
      expect(p.metrics.itemsDonated, 13);
      expect(p.cashbackEarned, 6.5);
    });

    test('entradas inválidas não geram valores negativos', () {
      final p = calculator.project(
        itemsPerWeek: -2,
        months: -1,
        donationShare: 3, // fora do intervalo -> limitado a 1
        avgOriginalUnitPrice: 5,
        avgPaidUnitPrice: 10, // pago maior que original -> sem economia
        currentDonationCount: 0,
      );

      expect(p.metrics.isEmpty, isTrue);
      expect(p.cashbackEarned, 0.0);
    });
  });

  group('ImpactMetrics', () {
    test('soma, serializa e desserializa', () {
      const a = ImpactMetrics(
        itemsRescued: 2,
        itemsDonated: 1,
        savedReais: 3.10,
        donatedReais: 4.20,
      );
      const b = ImpactMetrics(itemsRescued: 1, savedReais: 0.20);

      final sum = a + b;
      expect(sum.itemsRescued, 3);
      expect(sum.savedReais, 3.3);

      final restored = ImpactMetrics.fromMap(sum.toMap());
      expect(restored.itemsRescued, sum.itemsRescued);
      expect(restored.savedReais, sum.savedReais);
    });

    test('fromMap tolera nulo, campos ausentes e ints no lugar de doubles', () {
      expect(ImpactMetrics.fromMap(null).isEmpty, isTrue);

      final m = ImpactMetrics.fromMap({'itemsRescued': 2.0, 'savedReais': 5});
      expect(m.itemsRescued, 2);
      expect(m.savedReais, 5.0);
      expect(m.itemsDonated, 0);
    });
  });
}
