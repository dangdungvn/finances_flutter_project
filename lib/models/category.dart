import 'package:flutter/material.dart';
import 'transaction.dart';

class Category {
  final String name;
  final IconData icon;
  final TransactionType type;

  Category({
    required this.name,
    required this.icon,
    required this.type,
  });
}

// Predefined categories
class Categories {
  static List<Category> getCategories() {
    return [
      // Income categories
      Category(name: 'Salary', icon: Icons.work, type: TransactionType.income),
      Category(
          name: 'Bonus',
          icon: Icons.card_giftcard,
          type: TransactionType.income),
      Category(name: 'Gift', icon: Icons.redeem, type: TransactionType.income),
      Category(
          name: 'Other Income',
          icon: Icons.attach_money,
          type: TransactionType.income),

      // Expense categories
      Category(
          name: 'Food', icon: Icons.restaurant, type: TransactionType.expense),
      Category(
          name: 'Shopping',
          icon: Icons.shopping_cart,
          type: TransactionType.expense),
      Category(
          name: 'Bills', icon: Icons.receipt, type: TransactionType.expense),
      Category(
          name: 'Transportation',
          icon: Icons.directions_car,
          type: TransactionType.expense),
      Category(
          name: 'Entertainment',
          icon: Icons.movie,
          type: TransactionType.expense),
      Category(
          name: 'Health',
          icon: Icons.medical_services,
          type: TransactionType.expense),
      Category(
          name: 'Other Expense',
          icon: Icons.money_off,
          type: TransactionType.expense),
    ];
  }

  static Category getCategoryByName(String name) {
    return getCategories().firstWhere(
      (cat) => cat.name == name,
      orElse: () => Category(
        name: name,
        icon: Icons.category,
        type: TransactionType.expense,
      ),
    );
  }
}
