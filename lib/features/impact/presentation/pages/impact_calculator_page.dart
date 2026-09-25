import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/count_up_text.dart';
import '../../../../core/widgets/ivalid_card.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../donation/domain/services/donation_gamification_service.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/services/impact_calculator.dart';
import '../providers/impact_provider.dart';
import '../widgets/impact_totals_row.dart';

/// Calculadora de impacto social: mostra o impacto real acumulado do usuário e
/// permite simular o impacto de um ritmo de compras e doações.
///
/// Metodologia v1 — sem peso (ver [ImpactCalculator]).
class ImpactCalculatorPage extends StatefulWidget {
  const ImpactCalculatorPage({super.key});

  @override
  State<ImpactCalculatorPage> createState() => _ImpactCalculatorPageState();
}

class _ImpactCalculatorPageState extends State<ImpactCalculatorPage> {
  static const _monthOptions = [1, 3, 6, 12];

  final ImpactCalculator _calculator = ImpactCalculator();

  int _itemsPerWeek = 3;
  int _donationPercent = 50;
  int _months = 6;

  @override
  Widget build(BuildContext context) {
    final totals = context.watch<ImpactProvider>().totals;
    final products = context
        .watch<HomeProvider>()
        .allProducts
        .where((p) => p.oldPrice > 0)
        .toList();
    final totalDonations = context.watch<ProfileProvider>().totalDonations;

    final hasPrices = products.isNotEmpty;
    final avgOriginal = hasPrices
        ? products.fold<double>(0, (s, p) => s + p.oldPrice) / products.length
        : 0.0;
    final avgPaid = hasPrices
        ? products.fold<double>(0, (s, p) => s + p.priceNow) / products.length
        : 0.0;

    final projection = _calculator.project(
      itemsPerWeek: _itemsPerWeek,
      months: _months,
      donationShare: _donationPercent / 100,
      avgOriginalUnitPrice: avgOriginal,
      avgPaidUnitPrice: avgPaid,
      currentDonationCount: totalDonations,
    );

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.onBg),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Calculadora de impacto',
          style: GoogleFonts.inter(
            color: context.onBg,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Impacto real ──────────────────────────────────────────
            const SectionTitle('Seu impacto até agora',
                barColor: AppColors.greenAccent),
            const SizedBox(height: AppSpacing.md),
            IvalidCard(child: ImpactTotalsRow(metrics: totals)),
            if (totals.isEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ainda não há compras registradas. Use o simulador abaixo para ver o que você pode gerar.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: context.onBgAlpha(0.55),
                ),
              ),
            ],
            const SizedBox(height: 28),

            // ─── Simulador ─────────────────────────────────────────────
            const SectionTitle('Simule seu impacto'),
            const SizedBox(height: AppSpacing.md),
            IvalidCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ControlHeader(
                    title: 'Itens por semana',
                    subtitle: 'Quantos itens você compraria',
                    trailing: _Stepper(
                      value: _itemsPerWeek,
                      min: 1,
                      max: 30,
                      onChanged: (v) => setState(() => _itemsPerWeek = v),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _ControlHeader(
                    title: 'Parte destinada à doação',
                    subtitle:
                        '$_donationPercent% doação · ${100 - _donationPercent}% consumo próprio',
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.redPrimary,
                      inactiveTrackColor:
                          AppColors.redPrimary.withValues(alpha: 0.15),
                      thumbColor: AppColors.redPrimary,
                      overlayColor:
                          AppColors.redPrimary.withValues(alpha: 0.12),
                      valueIndicatorColor: AppColors.redPrimary,
                    ),
                    child: Slider(
                      value: _donationPercent.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: '$_donationPercent%',
                      semanticFormatterCallback: (v) =>
                          '${v.round()}% para doação',
                      onChanged: (v) =>
                          setState(() => _donationPercent = v.round()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _ControlHeader(title: 'Período'),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      for (var i = 0; i < _monthOptions.length; i++) ...[
                        if (i > 0) const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _MonthChip(
                            months: _monthOptions[i],
                            selected: _months == _monthOptions[i],
                            onTap: () =>
                                setState(() => _months = _monthOptions[i]),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ─── Resultado ─────────────────────────────────────────────
            const SectionTitle('Resultado estimado',
                barColor: AppColors.greenAccent),
            const SizedBox(height: AppSpacing.md),
            _ResultCard(projection: projection, months: _months),
            const SizedBox(height: AppSpacing.lg),

            // ─── Aviso + metodologia ───────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: context.onBgAlpha(0.45)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasPrices
                        ? 'Estimativa baseada na média de preços dos produtos disponíveis hoje. Não considera o peso dos alimentos.'
                        : 'Preços médios indisponíveis no momento; a economia e os valores doados aparecem zerados. Não considera o peso dos alimentos.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.4,
                      color: context.onBgAlpha(0.55),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _showMethodology(context),
                child: const Text('Como calculamos?'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _showMethodology(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      builder: (sheetContext) => const _MethodologySheet(),
    );
  }
}

// ─── Componentes locais ───────────────────────────────────────────────────────

class _ControlHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _ControlHeader({required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.onBg,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: context.onBgAlpha(0.5),
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepButton(
          icon: Icons.remove_rounded,
          tooltip: 'Diminuir',
          onTap: value > min ? () => onChanged(value - 1) : null,
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: context.onBg,
            ),
          ),
        ),
        _StepButton(
          icon: Icons.add_rounded,
          tooltip: 'Aumentar',
          onTap: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _StepButton({required this.icon, required this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: context.chipBg,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 20,
              color: enabled ? context.onBg : context.onBgAlpha(0.25),
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthChip extends StatelessWidget {
  final int months;
  final bool selected;
  final VoidCallback onTap;

  const _MonthChip({
    required this.months,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: months == 1 ? '1 mês' : '$months meses',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? context.softBg(AppColors.redPrimary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(
              color: selected ? AppColors.redPrimary : context.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            months == 1 ? '1 mês' : '$months meses',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: selected ? AppColors.redPrimary : context.onBgAlpha(0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final ImpactProjection projection;
  final int months;

  const _ResultCard({required this.projection, required this.months});

  static String _levelName(FidelityLevel level) => level.label.split(' ').first;

  @override
  Widget build(BuildContext context) {
    final metrics = projection.metrics;
    final green = context.accent(AppColors.greenAccent);

    return IvalidCard(
      borderColor: AppColors.greenAccent.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Você pode salvar',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: context.onBgAlpha(0.55),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              CountUpText(
                value: metrics.totalItems.toDouble(),
                format: (v) => formatCount(v.round()),
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: green,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  metrics.totalItems == 1
                      ? 'item do desperdício'
                      : 'itens do desperdício',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.onBg,
                  ),
                ),
              ),
            ],
          ),
          Text(
            months == 1 ? 'em 1 mês' : 'em $months meses',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: context.onBgAlpha(0.5),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.shopping_basket_rounded,
                  value: formatCount(metrics.itemsRescued),
                  label: 'Consumo próprio',
                  color: AppColors.greenAccent,
                ),
              ),
              Expanded(
                child: StatTile(
                  icon: Icons.volunteer_activism_rounded,
                  value: formatCount(metrics.itemsDonated),
                  label: 'Itens doados',
                  color: AppColors.redPrimary,
                ),
              ),
              Expanded(
                child: StatTile(
                  icon: Icons.savings_rounded,
                  value: formatReais(metrics.savedReais),
                  label: 'Economia',
                  color: AppColors.yellowAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: context.outline.withValues(alpha: 0.5), height: 1),
          const SizedBox(height: 16),
          if (metrics.itemsDonated > 0) ...[
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: AppColors.yellowAccent, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cashback estimado',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: context.onBgAlpha(0.55),
                        ),
                      ),
                      Text(
                        projection.levelsUp
                            ? 'Nível ${_levelName(projection.startLevel)} → ${_levelName(projection.endLevel)}'
                            : 'Você segue no nível ${_levelName(projection.startLevel)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.onBgAlpha(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatReais(projection.cashbackEarned),
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'O cashback pode abater até 15% de cada pedido e vale por 45 dias.',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: context.onBgAlpha(0.45),
              ),
            ),
          ] else
            Text(
              'Destine parte dos itens à doação para ganhar cashback e subir de nível.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: context.onBgAlpha(0.55),
              ),
            ),
        ],
      ),
    );
  }
}

class _MethodologySheet extends StatelessWidget {
  const _MethodologySheet();

  static const _items = <(String, String)>[
    (
      'Itens salvos',
      'Cada item comprado no Ivalid, para consumo próprio ou para doação, é um alimento que deixou de ser descartado.'
    ),
    (
      'Economia',
      'Diferença entre o preço original e o preço pago nos itens para consumo próprio.'
    ),
    (
      'Doações',
      'Valor pago nos itens doados a ONGs parceiras. Elas geram cashback conforme seu nível: Bronze 1%, Prata 3% e Ouro 5%.'
    ),
    (
      'Simulação',
      'Usa a média de preços dos produtos disponíveis hoje e o seu nível atual. É uma estimativa, não uma garantia.'
    ),
    (
      'Quando conta',
      'O impacto é somado quando o pedido é confirmado.'
    ),
    (
      'O que ainda não entra',
      'O peso dos alimentos (kg e refeições) ainda não é considerado.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Como calculamos',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: context.onBg,
              ),
            ),
            const SizedBox(height: 16),
            for (final (title, text) in _items) ...[
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: context.onBg,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.45,
                  color: context.onBgAlpha(0.65),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              'Metodologia v${ImpactCalculator.methodologyVersion}',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: context.onBgAlpha(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
