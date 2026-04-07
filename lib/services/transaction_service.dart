import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../models/transaction_model.dart';

class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  final _uuid = const Uuid();

  Box<TransactionModel> get _box =>
      Hive.box<TransactionModel>(AppConstants.transactionBoxName);

  // Simulate async API call
  Future<List<TransactionModel>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final items = _box.values.toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  Future<TransactionModel> create({
    required String title,
    required double amount,
    required String type,
    required String category,
    required DateTime date,
    String note = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final tx = TransactionModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: note,
    );
    await _box.put(tx.id, tx);
    return tx;
  }

  Future<TransactionModel> update(TransactionModel tx) async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _box.put(tx.id, tx);
    return tx;
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _box.delete(id);
  }

  Future<void> seedMockData() async {
    if (_box.isNotEmpty) return;
    final now = DateTime.now();
    final mockData = [
      // Income
      _mock('Salary', 3500, 'income', 'Salary', now.subtract(const Duration(days: 2))),
      _mock('Freelance Project', 800, 'income', 'Freelance', now.subtract(const Duration(days: 5))),
      _mock('Investment Return', 150, 'income', 'Investment', now.subtract(const Duration(days: 10))),
      // Expenses
      _mock('Grocery Store', 85.5, 'expense', 'Food', now.subtract(const Duration(days: 1))),
      _mock('Netflix', 15.99, 'expense', 'Entertainment', now.subtract(const Duration(days: 3))),
      _mock('Uber Ride', 22.0, 'expense', 'Transport', now.subtract(const Duration(days: 3))),
      _mock('Electric Bill', 110.0, 'expense', 'Bills', now.subtract(const Duration(days: 6))),
      _mock('Gym Membership', 45.0, 'expense', 'Health', now.subtract(const Duration(days: 7))),
      _mock('Online Course', 29.99, 'expense', 'Education', now.subtract(const Duration(days: 8))),
      _mock('Restaurant', 62.0, 'expense', 'Food', now.subtract(const Duration(days: 9))),
      _mock('Amazon Shopping', 134.0, 'expense', 'Shopping', now.subtract(const Duration(days: 11))),
      _mock('Coffee Shop', 18.5, 'expense', 'Food', now.subtract(const Duration(days: 12))),
      _mock('Bus Pass', 30.0, 'expense', 'Transport', now.subtract(const Duration(days: 14))),
      _mock('Movie Tickets', 28.0, 'expense', 'Entertainment', now.subtract(const Duration(days: 15))),
    ];
    for (final tx in mockData) {
      await _box.put(tx.id, tx);
    }
  }

  TransactionModel _mock(String title, double amount, String type, String category, DateTime date) {
    return TransactionModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      note: '',
    );
  }
}
