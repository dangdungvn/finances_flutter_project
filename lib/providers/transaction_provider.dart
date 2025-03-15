import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/transaction.dart';

enum DateFilterType { all, today, week, month }

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  DateFilterType _currentFilter = DateFilterType.all;

  List<Transaction> get transactions => _filteredTransactions;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  double get balance => _totalIncome - _totalExpense;
  DateFilterType get currentFilter => _currentFilter;

  TransactionProvider() {
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    _transactions = await DatabaseHelper().getTransactions();
    _applyFilter(_currentFilter);
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseHelper().insertTransaction(transaction);
    await fetchTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await DatabaseHelper().updateTransaction(transaction);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper().deleteTransaction(id);
    await fetchTransactions();
  }

  void setFilter(DateFilterType filter) {
    if (_currentFilter != filter) {
      _currentFilter = filter;
      _applyFilter(filter);
      notifyListeners();
    }
  }

  void _applyFilter(DateFilterType filter) {
    final now = DateTime.now();

    switch (filter) {
      case DateFilterType.today:
        final today = DateTime(now.year, now.month, now.day);
        _filteredTransactions = _transactions
            .where((t) =>
                t.date.isAfter(today.subtract(const Duration(seconds: 1))))
            .toList();
        break;

      case DateFilterType.week:
        final startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        _filteredTransactions = _transactions
            .where((t) => t.date
                .isAfter(startOfWeek.subtract(const Duration(seconds: 1))))
            .toList();
        break;

      case DateFilterType.month:
        final startOfMonth = DateTime(now.year, now.month, 1);
        _filteredTransactions = _transactions
            .where((t) => t.date
                .isAfter(startOfMonth.subtract(const Duration(seconds: 1))))
            .toList();
        break;

      case DateFilterType.all:
        _filteredTransactions = List.from(_transactions);
        break;
    }

    _calculateTotals();
  }

  void _calculateTotals() {
    _totalIncome = _filteredTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    _totalExpense = _filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> getCategoryTotals(TransactionType type) {
    final categoryMap = <String, double>{};

    for (var transaction in _filteredTransactions) {
      if (transaction.type == type) {
        final category = transaction.category;
        categoryMap[category] =
            (categoryMap[category] ?? 0) + transaction.amount;
      }
    }

    return categoryMap;
  }

  Map<String, double> getDailyTotals(TransactionType type) {
    final dailyMap = <String, double>{};
    final dateFormat = DateFormat('yyyy-MM-dd');

    for (var transaction in _filteredTransactions) {
      if (transaction.type == type) {
        final dateStr = dateFormat.format(transaction.date);
        dailyMap[dateStr] = (dailyMap[dateStr] ?? 0) + transaction.amount;
      }
    }

    return dailyMap;
  }
}
