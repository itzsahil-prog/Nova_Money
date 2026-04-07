import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String type; // 'income' or 'expense'

  @HiveField(4)
  String category;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note = '',
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? note,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
