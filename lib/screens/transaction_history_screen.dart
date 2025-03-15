// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final currencyFormat = NumberFormat.currency(symbol: '\$');
  late TextEditingController _searchController;
  final bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Transaction History'),
        centerTitle: true,
        actions: [
          PopupMenuButton<DateFilterType>(
            onSelected: (filter) {
              Provider.of<TransactionProvider>(context, listen: false)
                  .setFilter(filter);
            },
            icon: const Icon(Icons.filter_list),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context) => [
              _buildFilterMenuItem('All Time', Icons.calendar_today_outlined,
                  DateFilterType.all),
              _buildFilterMenuItem(
                  'Today', Icons.today_outlined, DateFilterType.today),
              _buildFilterMenuItem(
                  'This Week', Icons.view_week_outlined, DateFilterType.week),
              _buildFilterMenuItem('This Month', Icons.calendar_month_outlined,
                  DateFilterType.month),
            ],
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.transactions.isEmpty) {
            return _buildEmptyState();
          }

          return _buildTransactionList(provider);
        },
      ),
    );
  }

  PopupMenuItem<DateFilterType> _buildFilterMenuItem(
      String title, IconData icon, DateFilterType filter) {
    return PopupMenuItem(
      value: filter,
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showSearch
                ? 'Try a different search term'
                : 'Add your first transaction with the + button',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!_showSearch)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(TransactionProvider provider) {
    // Group transactions by date
    final groupedTransactions = <String, List<Transaction>>{};

    for (final transaction in provider.transactions) {
      final dateStr = DateFormat('yyyy-MM-dd').format(transaction.date);
      groupedTransactions.putIfAbsent(dateStr, () => []);
      groupedTransactions[dateStr]!.add(transaction);
    }

    // Sort dates in descending order
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final dateStr = sortedDates[index];
        final date = DateFormat('yyyy-MM-dd').parse(dateStr);
        final transactions = groupedTransactions[dateStr]!;

        // Calculate daily total
        double dailyTotal = 0;
        for (final transaction in transactions) {
          if (transaction.type == TransactionType.income) {
            dailyTotal += transaction.amount;
          } else {
            dailyTotal -= transaction.amount;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(date, dailyTotal),
            ...transactions
                .map((transaction) => _buildTransactionTile(transaction)),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date, double dailyTotal) {
    String dateText;
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      dateText = 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      dateText = 'Yesterday';
    } else {
      dateText = DateFormat('MMM d, yyyy').format(date);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                dateText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: dailyTotal >= 0
                  ? const Color(0xFFB5EAD7).withOpacity(0.2)
                  : const Color(0xFFF8AFA6).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              currencyFormat.format(dailyTotal),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: dailyTotal >= 0
                    ? const Color(0xFF5a9e8f)
                    : const Color(0xFFcf7a71),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final iconBackgroundColor = isIncome
        ? const Color(0xFFB5EAD7) // Mint (pastel)
        : const Color(0xFFF8AFA6); // Soft coral (pastel)
    final amountColor = isIncome
        ? const Color(0xFF5a9e8f) // Darker mint
        : const Color(0xFFcf7a71); // Darker coral

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTransactionScreen(
                  transaction: transaction,
                ),
              ),
            ).then((_) =>
                Provider.of<TransactionProvider>(context, listen: false)
                    .fetchTransactions());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isIncome
                        ? Icons.arrow_downward_rounded
                        : Icons.arrow_upward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              transaction.category,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isIncome
                                ? '+${currencyFormat.format(transaction.amount)}'
                                : '-${currencyFormat.format(transaction.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: amountColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (transaction.note != null &&
                              transaction.note!.isNotEmpty)
                            Expanded(
                              child: Text(
                                transaction.note!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (transaction.note != null &&
                              transaction.note!.isNotEmpty)
                            const SizedBox(width: 8),
                          Text(
                            DateFormat('HH:mm').format(transaction.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
