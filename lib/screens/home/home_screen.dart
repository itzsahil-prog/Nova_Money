import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_tile.dart';
import '../transactions/add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Companion'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: themeProvider.toggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: provider.state == LoadingState.loading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: provider.loadTransactions,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BalanceCard(provider: provider),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SummaryCard(
                          label: 'Income',
                          value: Formatters.currency(provider.totalIncome),
                          color: AppTheme.incomeColor,
                          icon: '📥',
                        ),
                        const SizedBox(width: 12),
                        SummaryCard(
                          label: 'Expenses',
                          value: Formatters.currency(provider.totalExpense),
                          color: AppTheme.expenseColor,
                          icon: '📤',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SavingsProgress(provider: provider),
                    const SizedBox(height: 16),
                    _WeeklyChart(provider: provider),
                    const SizedBox(height: 16),
                    _InsightBanner(provider: provider),
                    const SizedBox(height: 16),
                    Text('Recent Transactions',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    if (provider.transactions.isEmpty)
                      const EmptyState(
                        emoji: '💸',
                        title: 'No transactions yet',
                        subtitle: 'Add your first transaction to get started',
                      )
                    else
                      ...provider.transactions.take(5).map((tx) => TransactionTile(
                            transaction: tx,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddTransactionScreen(transaction: tx),
                              ),
                            ),
                            onDelete: () => provider.deleteTransaction(tx.id),
                          )),
                  ],
                ),
              ),
            ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final TransactionProvider provider;
  const _BalanceCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF9C8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Balance',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            Formatters.currency(provider.balance),
            style: const TextStyle(
                color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.monthYear(DateTime.now()),
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SavingsProgress extends StatelessWidget {
  final TransactionProvider provider;
  const _SavingsProgress({required this.provider});

  @override
  Widget build(BuildContext context) {
    final rate = provider.savingsRate;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Savings Rate', style: Theme.of(context).textTheme.titleMedium),
              Text('${(rate * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                      color: AppTheme.primaryColor, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 10,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rate >= 0.2
                ? '🎉 Great savings rate!'
                : rate > 0
                    ? '💡 Try to save at least 20% of income'
                    : '⚠️ Expenses exceed income',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final TransactionProvider provider;
  const _WeeklyChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final data = provider.weeklySpending;
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final maxY = data.values.isEmpty ? 100.0 : (data.values.reduce((a, b) => a > b ? a : b) * 1.3).clamp(10.0, double.infinity);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Spending', style: Theme.of(context).textTheme.titleMedium),
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
                        if (idx < 0 || idx >= days.length) return const SizedBox();
                        return Text(Formatters.weekDay(days[idx]),
                            style: Theme.of(context).textTheme.labelSmall);
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i] ?? 0,
                        color: AppTheme.primaryColor,
                        width: 20,
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

class _InsightBanner extends StatelessWidget {
  final TransactionProvider provider;
  const _InsightBanner({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(provider.weeklyInsight,
                style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
