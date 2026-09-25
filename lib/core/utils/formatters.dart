import 'package:intl/intl.dart';

final NumberFormat _reais =
    NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
final NumberFormat _integer = NumberFormat.decimalPattern('pt_BR');

/// Formata um valor em reais no padrão brasileiro: `R$ 1.234,50`.
String formatReais(double value) => _reais.format(value);

/// Formata um inteiro com separador de milhar: `1.234`.
String formatCount(num value) => _integer.format(value);

/// Escolhe singular/plural: `pluralize(1, 'item', 'itens')` → `1 item`.
String pluralize(int count, String singular, String plural) =>
    '${formatCount(count)} ${count == 1 ? singular : plural}';
