import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show jsonDecode, jsonEncode;
import '../models/transaction_model.dart';

enum TransactionLoadingState { loading, loaded, error }

class TransactionProvider with ChangeNotifier {
  TransactionLoadingState _loadingState = TransactionLoadingState.loading;
  String? _errorMessage;

  TransactionLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  List<TransactionModel> _transactions = [];
  final SharedPreferences _prefs;

  TransactionProvider(this._prefs) {
    loadTransactions();
  }

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  List<TransactionModel> get incomeTransactions => _transactions
      .where((t) => t.type == TransactionType.income)
      .toList();

  List<TransactionModel> get expenseTransactions => _transactions
      .where((t) => t.type == TransactionType.expense)
      .toList();

  double get totalIncome => incomeTransactions.fold(
        0,
        (sum, transaction) => sum + transaction.amount,
      );

  double get totalExpenses => expenseTransactions.fold(
        0,
        (sum, transaction) => sum + transaction.amount,
      );

  double get balance => totalIncome - totalExpenses;

  List<TransactionModel> get recurringTransactions => _transactions
      .where((t) => t.recurrence != RecurrenceType.none)
      .toList();

  Future<void> loadTransactions() async {
    try {
      _loadingState = TransactionLoadingState.loading;
      _errorMessage = null;
      notifyListeners();

      final transactionsJson = _prefs.getString('transactions');
      if (transactionsJson != null) {
        final List<dynamic> decoded = jsonDecode(transactionsJson);
        _transactions = decoded
            .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      
      _loadingState = TransactionLoadingState.loaded;
      notifyListeners();
    } catch (e) {
      _loadingState = TransactionLoadingState.error;
      _errorMessage = 'Failed to load transactions: $e';
      notifyListeners();
    }
  }

  Future<void> _saveTransactions() async {
    final transactionsJson = jsonEncode(
      _transactions.map((t) => t.toJson()).toList(),
    );
    await _prefs.setString('transactions', transactionsJson);
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> removeTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _saveTransactions();
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getSpendingByCategory() {
    final categoryTotals = <String, double>{};
    
    for (var transaction in expenseTransactions) {
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }

    return categoryTotals.entries
        .map((e) => {'category': e.key, 'amount': e.value})
        .toList();
  }

  List<TransactionModel> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _transactions
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }
}
