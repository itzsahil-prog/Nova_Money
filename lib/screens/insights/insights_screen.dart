import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int _touchedIndex = -1;

  static const List<Color> _pieColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43E97B),
    Color(0xFFFA8231),
    Color(0xFF4FC3F7),
    Color(0xFFFFD93D),
    Color(0xFFFF6B6B),
    Color(0xFF6BCB77),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final breakdown = provider.categoryBreakdown;

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: provider.transactions.isEmpty
          ? const EmptyState(
              emoji: '📊',
              title: 'No data yet',
              subtitle: 'Add transactions to see your spending insights',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SmartInsights(provider: provider),
                  const SizedBox(height: 16),
                  if (breakdown.isNotEmpty) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Spending by Category',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, response) {
                                    setState(() {
                                      _touchedIndex = response?.touchedSection
                                              ?.touchedSectionIndex ??
                                          -1;
                                    });
                                  },
                                ),
                                sections: _buildPieSections(breakdown),
                                centerSpaceRadius: 50,
                                sectionsSpace: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildLegend(context, breakdown),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _WeeklyComparison(provider: provider),
                  const SizedBox(height: 16),
                  _MonthlyTrend(provider: provider),
                  const SizedBox(height: 16),
                  _CategoryList(provider: provider),
                ],
              ),
            ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> breakdown) {
    final total = breakdown.values.fold(0.0, (a, b) => a + b);
    final entries = breakdown.entries.toList();
    return List.generate(entries.length, (i) {
      final isTouched = i == _touchedIndex;
      final pct = (entries[i].value / total * 100);
      return PieChartSectionData(
        color: _pieColors[i % _pieColors.length],
        value: entries[i].value,
        title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 70 : 58,
        titleStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
      );
    });
  }

  Widget _buildLegend(BuildContext context, Map<String, double> breakdown) {
    final entries = breakdown.entries.toList();
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(entries.length, (i) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _pieColors[i % _pieColors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${AppConstants.categoryIcons[entries[i].key] ?? ''} ${entries[i].key}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
      }),
    );
  }
}

class _SmartInsights extends StatelessWidget {
  final TransactionProvider provider;
  const _SmartInsights({required this.provider});

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Smart Insights', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...insights.map((insight) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: insight.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: insight.color.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Text(insight.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(insight.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: insight.color)),
                        Text(insight.body,
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  List<_Insight> _generateInsights(TransactionProvider p) {
    final insights = <_Insight>[];
    if (p.topCategory != 'N/A') {
      insights.add(_Insight(
        emoji: AppConstants.categoryIcons[p.topCategory] ?? '💰',
        title: 'Top Spending: ${p.topCategory}',
        body: 'You spend the most on ${p.topCategory}. Consider reviewing this category.',
        color: AppTheme.expenseColor,
      ));
    }
    if (p.savingsRate >= 0.2) {
      insights.add(_Insight(
        emoji: '🎉',
        title: 'Great Savings Rate!',
        body: 'You\'re saving ${(p.savingsRate * 100).toStringAsFixed(1)}% of your income.',
        color: AppTheme.incomeColor,
      ));
    } else if (p.savingsRate > 0) {
      insights.add(_Insight(
        emoji: '💡',
        title: 'Improve Your Savings',
        body: 'You\'re saving ${(p.savingsRate * 100).toStringAsFixed(1)}%. Aim for 20%+.',
        color: AppTheme.accentColor,
      ));
    }
    if (p.thisWeekSpend > p.lastWeekSpend && p.lastWeekSpend > 0) {
      insights.add(_Insight(
        emoji: '📈',
        title: 'Spending Increased',
        body: 'This week\'s spending is ${Formatters.currency(p.thisWeekSpend - p.lastWeekSpend)} more than last week.',
        color: AppTheme.expenseColor,
      ));
    }
    return insights;
  }
}

class _Insight {
  final String emoji, title, body;
  final Color color;
  _Insight({required this.emoji, required this.title, required this.body, required this.color});
}

class _WeeklyComparison extends StatelessWidget {
  final TransactionProvider provider;
  const _WeeklyComparison({required this.provider});

  @override
  Widget build(BuildContext context) {
    final thisWeek = provider.thisWeekSpend;
    final lastWeek = provider.lastWeekSpend;
    final maxVal = [thisWeek, lastWeek, 1.0].reduce((a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Comparison', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          _ComparisonBar(
            label: 'This Week',
            value: thisWeek,
            maxValue: maxVal,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 10),
          _ComparisonBar(
            label: 'Last Week',
            value: lastWeek,
            maxValue: maxVal,
            color: AppTheme.primaryColor.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  final String label;
  final double value, maxValue;
  final Color color;
  const _ComparisonBar(
      {required this.label, required this.value, required this.maxValue, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: maxValue == 0 ? 0 : (value / maxValue).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(Formatters.currency(value),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CategoryList extends StatelessWidget {
  final TransactionProvider provider;
  const _CategoryList({required this.provider});

  @override
  Widget build(BuildContext context) {
    final breakdown = provider.categoryBreakdown;
    if (breakdown.isEmpty) return const SizedBox();
    final total = breakdown.values.fold(0.0, (a, b) => a + b);
    final sorted = breakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category Breakdown', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...sorted.map((e) {
            final pct = total == 0 ? 0.0 : e.value / total;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text(AppConstants.categoryIcons[e.key] ?? '💰',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key, style: Theme.of(context).textTheme.bodyLarge),
                            Text(Formatters.currency(e.value),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MonthlyTrend extends StatelessWidget {
  final TransactionProvider provider;
  const _MonthlyTrend({required this.provider});

  @override
  Widget build(BuildContext context) {
    final data = provider.monthlySpending;
    final now = DateTime.now();
    // months[0] = 5 months ago, months[5] = current month
    final months = List.generate(6, (i) {
      final d = DateTime(now.year, now.month - (5 - i));
      return d;
    });
    final maxY = data.values.isEmpty
        ? 100.0
        : (data.values.reduce((a, b) => a > b ? a : b) * 1.3).clamp(10.0, double.infinity);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Trend', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= months.length) return const SizedBox();
                        return Text(
                          Formatters.shortMonthName(months[idx]),
                          style: Theme.of(context).textTheme.labelSmall,
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(6, (i) {
                  // data key: 0 = current month, 5 = 5 months ago
                  // bar index 0 = oldest, 5 = current
                  final monthOffset = 5 - i;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[monthOffset] ?? 0,
                        color: i == 5
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withValues(alpha: 0.45),
                        width: 28,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: AppTheme.primaryColor.withValues(alpha: 0.07),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
