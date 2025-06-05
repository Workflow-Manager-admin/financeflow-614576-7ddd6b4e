import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/savings_suggestion_model.dart';
import '../models/transaction_model.dart';
import 'transaction_provider.dart';

class SavingsProvider with ChangeNotifier {
  List<SavingsSuggestionModel> _suggestions = [];
  final SharedPreferences _prefs;
  final TransactionProvider _transactionProvider;

  SavingsProvider(this._prefs, this._transactionProvider) {
    _loadSuggestions();
    _generateSuggestions();
  }

  List<SavingsSuggestionModel> get suggestions => List.unmodifiable(_suggestions);

  Future<void> _loadSuggestions() async {
    final suggestionsJson = _prefs.getString('savings_suggestions');
    if (suggestionsJson != null) {
      final List<dynamic> decoded = jsonDecode(suggestionsJson);
      _suggestions = decoded
          .map((item) => SavingsSuggestionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveSuggestions() async {
    final suggestionsJson = jsonEncode(
      _suggestions.map((s) => s.toJson()).toList(),
    );
    await _prefs.setString('savings_suggestions', suggestionsJson);
  }

  void _generateSuggestions() {
    final expenses = _transactionProvider.expenseTransactions;
    final categories = _getCategorySpending(expenses);
    
    _suggestions.clear();

    // Generate suggestions based on spending patterns
    for (var category in categories.entries) {
      if (category.value > 500) {
        _suggestions.add(
          SavingsSuggestionModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'High ${category.key} Spending',
            description: 'Your ${category.key.toLowerCase()} expenses are higher than average. '
                'Consider setting a budget for this category.',
            potentialSavings: category.value * 0.2,
            category: category.key,
          ),
        );
      }
    }

    // Check for frequent small transactions
    final smallTransactions = expenses.where((t) => t.amount < 10).length;
    if (smallTransactions > 5) {
      _suggestions.add(
        SavingsSuggestionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Frequent Small Purchases',
          description: 'You have many small transactions. Consider bundling these '
              'purchases to save money.',
          potentialSavings: smallTransactions * 2.0,
          category: 'General',
        ),
      );
    }

    // Check for recurring subscriptions
    final recurringExpenses = expenses.where(
      (t) => t.recurrence != RecurrenceType.none,
    ).toList();
    
    if (recurringExpenses.isNotEmpty) {
      final totalRecurring = recurringExpenses.fold(
        0.0,
        (sum, t) => sum + t.amount,
      );
      
      _suggestions.add(
        SavingsSuggestionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Review Subscriptions',
          description: 'You have ${recurringExpenses.length} active subscriptions. '
              'Review them to identify unused services.',
          potentialSavings: totalRecurring * 0.15,
          category: 'Subscriptions',
        ),
      );
    }

    notifyListeners();
    _saveSuggestions();
  }

  Map<String, double> _getCategorySpending(List<TransactionModel> expenses) {
    final categories = <String, double>{};
    for (var expense in expenses) {
      categories[expense.category] = (categories[expense.category] ?? 0) + expense.amount;
    }
    return categories;
  }

  Future<void> markSuggestionImplemented(String id) async {
    final index = _suggestions.indexWhere((s) => s.id == id);
    if (index != -1) {
      _suggestions[index] = _suggestions[index].copyWith(isImplemented: true);
      await _saveSuggestions();
      notifyListeners();
    }
  }

  Future<void> refreshSuggestions() async {
    _generateSuggestions();
  }
}
