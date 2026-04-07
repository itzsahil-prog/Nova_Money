import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/app_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final streak = provider.noSpendStreak;

    return Scaffold(
      appBar: AppBar(title: const Text('Goals & Streaks')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StreakCard(streak: streak),
            const SizedBox(height: 16),
            _StreakCalendar(provider: provider),
            const SizedBox(height: 16),
            _FinancialSummary(provider: provider),
            const SizedBox(height: 16),
            _Badges(streak: streak),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  String get _streakEmoji {
    if (streak >= 30) return '🏆';
    if (streak >= 14) return '🔥';
    if (streak >= 7) return '⚡';
    if (streak >= 3) return '✨';
    if (streak >= 1) return '🌱';
    return '💤';
  }

  String get _streakMessage {
    if (streak >= 30) return 'Legendary! 30+ days no-spend streak!';
    if (streak >= 14) return 'On fire! Two weeks strong!';
    if (streak >= 7) return 'Amazing! A full week streak!';
    if (streak >= 3) return 'Great start! Keep it going!';
    if (streak >= 1) return 'You\'re on a streak! Don\'t break it!';
    return 'Start your no-spend streak today!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: streak > 0
              ? [const Color(0xFFFF6B6B), const Color(0xFFFFD93D)]
              : [const Color(0xFF8E8E93), const Color(0xFFAEAEB2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(_streakEmoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            '$streak',
            style: const TextStyle(
                color: Colors.white, fontSize: 64, fontWeight: FontWeight.w900),
          ),
          Text(
            streak == 1 ? 'Day Streak' : 'Days Streak',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _streakMessage,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCalendar extends StatelessWidget {
  final TransactionProvider provider;
  const _StreakCalendar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(21, (i) => now.subtract(Duration(days: 20 - i)));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last 21 Days', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final hasExpense = provider.transactions.any((t) =>
                  t.isExpense &&
                  t.date.year == day.year &&
                  t.date.month == day.month &&
                  t.date.day == day.day);
              final isToday = Formatters.isSameDay(day, now);
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 28,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: hasExpense
                            ? AppTheme.expenseColor.withValues(alpha: 0.7)
                            : AppTheme.incomeColor.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                        border: isToday
                            ? Border.all(color: AppTheme.primaryColor, width: 2)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 9,
                        color: isToday ? AppTheme.primaryColor : null,
                        fontWeight: isToday ? FontWeight.w700 : null,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendDot(color: AppTheme.incomeColor.withValues(alpha: 0.7), label: 'No spend'),
              const SizedBox(width: 16),
              _LegendDot(color: AppTheme.expenseColor.withValues(alpha: 0.7), label: 'Had expenses'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _FinancialSummary extends StatelessWidget {
  final TransactionProvider provider;
  const _FinancialSummary({required this.provider});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financial Health', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          _HealthRow(
            label: 'Savings Rate',
            value: '${(provider.savingsRate * 100).toStringAsFixed(1)}%',
            progress: provider.savingsRate,
            color: provider.savingsRate >= 0.2 ? AppTheme.incomeColor : AppTheme.expenseColor,
          ),
          const SizedBox(height: 12),
          _HealthRow(
            label: 'Budget Used',
            value: provider.totalIncome == 0
                ? 'N/A'
                : '${((provider.totalExpense / provider.totalIncome) * 100).clamp(0, 100).toStringAsFixed(1)}%',
            progress: provider.totalIncome == 0
                ? 0
                : (provider.totalExpense / provider.totalIncome).clamp(0.0, 1.0),
            color: provider.totalExpense > provider.totalIncome
                ? AppTheme.expenseColor
                : AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  final String label, value;
  final double progress;
  final Color color;
  const _HealthRow(
      {required this.label, required this.value, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            Text(value,
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _Badges extends StatelessWidget {
  final int streak;
  const _Badges({required this.streak});

  @override
  Widget build(BuildContext context) {
    final badges = [
      _Badge('🌱', 'First Step', 'Start a streak', streak >= 1),
      _Badge('⚡', 'Momentum', '3-day streak', streak >= 3),
      _Badge('🔥', 'On Fire', '7-day streak', streak >= 7),
      _Badge('💎', 'Disciplined', '14-day streak', streak >= 14),
      _Badge('🏆', 'Legend', '30-day streak', streak >= 30),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Badges', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: badges.map((b) => _BadgeTile(badge: b)).toList(),
          ),
        ],
      ),
    );
  }
}

class _Badge {
  final String emoji, name, description;
  final bool unlocked;
  _Badge(this.emoji, this.name, this.description, this.unlocked);
}

class _BadgeTile extends StatelessWidget {
  final _Badge badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: badge.unlocked
                ? AppTheme.primaryColor.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: badge.unlocked
                ? Border.all(color: AppTheme.primaryColor, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              badge.emoji,
              style: TextStyle(
                fontSize: 24,
                color: badge.unlocked ? null : const Color(0xFFCCCCCC),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          badge.name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: badge.unlocked ? null : Colors.grey,
          ),
        ),
      ],
    );
  }
}
