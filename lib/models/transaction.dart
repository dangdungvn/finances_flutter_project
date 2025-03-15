enum TransactionType { income, expense }

class Transaction {
  final int? id;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String? note;

  Transaction({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'note': note,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: map['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      note: map['note'],
    );
  }
}
