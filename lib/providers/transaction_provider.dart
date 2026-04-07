import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

enum LoadingState { idle, loading, loaded, error }

class TransactionProvider extends ChangeNotifier {
  final TransactionService _service = TransactionService();

  List<TransactionModel> _transactions = [];
  LoadingState _state = LoadingState.idle;
  String _searchQuery = '';
  String _filterType = 'all'; // all, income, expense
  String _filterCategory = 'all';

  List<TransactionModel> get transactions => _transactions;
  LoadingState get state => _state;
  String get searchQuery => _searchQuery;
  String get filterType => _filterType;
  String get filterCategory => _filterCategory;

  List<TransactionModel> get filtered {
    return _transactions.where((tx) {
      final matchesSearch = _searchQuery.isEmpty ||
          tx.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == 'all' || tx.type == _filterType;
      final matchesCategory = _filterCategory == 'all' || tx.category == _filterCategory;
      return matchesSearch && matchesType && matchesCategory;
    }).toList();
  }

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.isExpense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  double get savingsRate => totalIncome == 0 ? 0 : (balance / totalIncome).clamp(0.0, 1.0);

  // Weekly spending: last 7 days grouped by day
  Map<int, double> get weeklySpending {
    final now = DateTime.now();
    final Map<int, double> result = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    for (final tx in _transactions) {
      if (!tx.isExpense) continue;
      final diff = now.difference(tx.date).inDays;
      if (diff >= 0 && diff < 7) {
        result[6 - diff] = (result[6 - diff] ?? 0) + tx.amount;
      }
    }
    return result;
  }

  double get thisWeekSpend {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.isExpense && now.difference(t.date).inDays < 7)
        .fold(0, (s, t) => s + t.amount);
  }

  double get lastWeekSpend {
    final now = DateTime.now();
    return _transactions
        .where((t) => t.isExpense && now.difference(t.date).inDays >= 7 && now.difference(t.date).inDays < 14)
        .fold(0, (s, t) => s + t.amount);
  }

  // Category breakdown for expenses
  Map<String, double> get categoryBreakdown {
    final Map<String, double> result = {};
    for (final tx in _transactions.where((t) => t.isExpense)) {
      result[tx.category] = (result[tx.category] ?? 0) + tx.amount;
    }
    return result;
  }

  String get topCategory {
    if (categoryBreakdown.isEmpty) return 'N/A';
    return categoryBreakdown.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // No-spend streak: consecutive days from today with no expenses
  int get noSpendStreak {
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      final hasExpense = _transactions.any((t) =>
          t.isExpense &&
          t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day);
      if (hasExpense) break;
      streak++;
    }
    return streak;
  }

  String get weeklyInsight {
    if (thisWeekSpend > lastWeekSpend && lastWeekSpend > 0) {
      final diff = thisWeekSpend - lastWeekSpend;
      return 'You spent \$${diff.toStringAsFixed(0)} more this week than last week.';
    } else if (thisWeekSpend < lastWeekSpend && lastWeekSpend > 0) {
      final diff = lastWeekSpend - thisWeekSpend;
      return 'Great job! You saved \$${diff.toStringAsFixed(0)} compared to last week.';
    }
    return 'Keep tracking your spending to see insights.';
  }

  Future<void> loadTransactions() async {
    _state = LoadingState.loading;
    notifyListeners();
    try {
      _transactions = await _service.fetchAll();
      _state = LoadingState.loaded;
    } catch (_) {
      _state = LoadingState.error;
    }
    notifyListeners();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    String note = '',
  }) async {
    await _service.create(
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );
    await loadTransactions();
  }

  Future<void> updateTransaction(TransactionModel tx) async {
    await _service.update(tx);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _service.delete(id);
    await loadTransactions();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterCategory(String category) {
    _filterCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterType = 'all';
    _filterCategory = 'all';
    notifyListeners();
  }
}
