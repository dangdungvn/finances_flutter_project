import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';

class SummaryCard extends StatelessWidget {
  final TransactionProvider provider;

  const SummaryCard({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Current Balance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(provider.balance),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: provider.balance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFinanceInfoColumn(
                  context,
                  'Income',
                  currencyFormat.format(provider.totalIncome),
                  Colors.green,
                ),
                _buildFinanceInfoColumn(
                  context,
                  'Expense',
                  currencyFormat.format(provider.totalExpense),
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceInfoColumn(
      BuildContext context, String title, String amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
