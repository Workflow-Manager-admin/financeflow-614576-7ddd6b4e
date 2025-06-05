import 'package:intl/intl.dart';

enum TransactionType { income, expense }
enum RecurrenceType { none, monthly, weekly }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;
  final RecurrenceType recurrence;
  final DateTime? recurrenceEndDate;
  final String? notes;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.recurrence = RecurrenceType.none,
    this.recurrenceEndDate,
    this.notes,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: json['amount'] as double,
      date: DateTime.parse(json['date'] as String),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
      ),
      category: json['category'] as String,
      recurrence: RecurrenceType.values.firstWhere(
        (e) => e.toString() == 'RecurrenceType.${json['recurrence']}',
        orElse: () => RecurrenceType.none,
      ),
      recurrenceEndDate: json['recurrenceEndDate'] != null
          ? DateTime.parse(json['recurrenceEndDate'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'category': category,
      'recurrence': recurrence.toString().split('.').last,
      'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
      'notes': notes,
    };
  }

  String get formattedAmount {
    final formatter = NumberFormat.currency(symbol: '\$');
    return formatter.format(amount);
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
