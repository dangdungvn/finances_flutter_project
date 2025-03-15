import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$');

  // Colors for chart elements
  final List<Color> _chartColors = [
    const Color(0xFF94B9AF), // Sage green (pastel)
    const Color(0xFFF2C0A2), // Peach (pastel)
    const Color(0xFFBFD0E0), // Baby blue (pastel)
    const Color(0xFFF8AFA6), // Soft coral (pastel)
    const Color(0xFFE6E6FA), // Lavender (pastel)
    const Color(0xFFB5EAD7), // Mint (pastel)
    const Color(0xFFF7D7DA), // Pink (pastel)
    const Color(0xFFFFDFD3), // Light orange (pastel)
    const Color(0xFFD4F0F0), // Aqua (pastel)
    const Color(0xFFFFF1C9), // Vanilla (pastel)
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Statistics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Categories'),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerHeight: 0,
        ),
        actions: [
          _buildFilterButton(),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildOverviewTab(),
          _buildCategoriesTab(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: PopupMenuButton<DateFilterType>(
        onSelected: (filter) {
          Provider.of<TransactionProvider>(context, listen: false)
              .setFilter(filter);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.filter_list_rounded),
        itemBuilder: (context) => [
          _buildFilterMenuItem(
            'All Time',
            Icons.calendar_today_outlined,
            DateFilterType.all,
          ),
          _buildFilterMenuItem(
            'Today',
            Icons.today_outlined,
            DateFilterType.today,
          ),
          _buildFilterMenuItem(
            'This Week',
            Icons.view_week_outlined,
            DateFilterType.week,
          ),
          _buildFilterMenuItem(
            'This Month',
            Icons.calendar_month_outlined,
            DateFilterType.month,
          ),
        ],
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

  Widget _buildOverviewTab() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final income = provider.totalIncome;
        final expense = provider.totalExpense;
        final balance = provider.balance;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(income, expense, balance),
              const SizedBox(height: 24),
              _buildSectionTitle('Income vs Expense'),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildBarChart(income, expense),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Balance Trend'),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: _buildLineChart(provider),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TabBar(
              tabs: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Tab(text: 'Income'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Tab(text: 'Expense'),
                ),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).colorScheme.primary,
              ),
              dividerHeight: 0,
              padding: const EdgeInsets.all(4),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCategoryPieChart(TransactionType.income),
                _buildCategoryPieChart(TransactionType.expense),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double income, double expense, double balance) {
    return Card(
      shadowColor: Colors.black.withOpacity(0.1),
      elevation: 10,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(builder: (context, constraints) {
          // Responsive layout based on available width
          if (constraints.maxWidth > 500) {
            // Wider layout for tablets/web
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  'Income',
                  income,
                  Theme.of(context).colorScheme.primary,
                  Icons.arrow_downward,
                ),
                _buildDivider(isVertical: true),
                _buildSummaryItem(
                  'Expense',
                  expense,
                  Theme.of(context).colorScheme.error,
                  Icons.arrow_upward,
                ),
                _buildDivider(isVertical: true),
                _buildSummaryItem(
                    'Balance',
                    balance,
                    balance >= 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                    Icons.account_balance_wallet),
              ],
            );
          } else {
            // Stack items for phones
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: _buildSummaryItem(
                            'Income',
                            income,
                            Theme.of(context).colorScheme.primary,
                            Icons.arrow_downward)),
                    _buildDivider(isVertical: true),
                    Expanded(
                      child: _buildSummaryItem(
                        'Expense',
                        expense,
                        Theme.of(context).colorScheme.error,
                        Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
                _buildDivider(isVertical: false),
                _buildSummaryItem(
                    'Balance',
                    balance,
                    balance >= 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                    Icons.account_balance_wallet),
              ],
            );
          }
        }),
      ),
    );
  }

  Widget _buildDivider({required bool isVertical}) {
    return isVertical
        ? Container(
            width: 1,
            height: 60,
            color: Colors.grey.withOpacity(0.2),
          )
        : Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 1,
            color: Colors.grey.withOpacity(0.2),
          );
  }

  Widget _buildSummaryItem(
      String title, double amount, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(double income, double expense) {
    return Card(
      shadowColor: Colors.black.withOpacity(0.1),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment
                .spaceEvenly, // Changed from center to spaceEvenly
            maxY: (income > expense ? income : expense) * 1.2,
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String label = '';
                  double value = 0;
                  if (groupIndex == 0) {
                    label = 'Income';
                    value = income;
                  } else {
                    label = 'Expense';
                    value = expense;
                  }
                  return BarTooltipItem(
                    '$label\n${_currencyFormat.format(value)}',
                    const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    String text = '';
                    switch (value.toInt()) {
                      case 0:
                        text = 'Income';
                        break;
                      case 1:
                        text = 'Expense';
                        break;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 12), // Increased from 8 to 12
                      child: Text(
                        text,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    );
                  },
                  reservedSize: 40, // Increased from 30 to 40
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '\$${value.toInt()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    );
                  },
                ),
              ),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: income,
                    color: _chartColors[0],
                    width: 16, // Reduced from 20 to 16
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ],
              ),
              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: expense,
                    color: _chartColors[3],
                    width: 16, // Reduced from 20 to 16
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(TransactionProvider provider) {
    // Get daily balances
    final incomes = provider.getDailyTotals(TransactionType.income);
    final expenses = provider.getDailyTotals(TransactionType.expense);

    // Combine and sort dates
    final allDates = {...incomes.keys, ...expenses.keys}.toList();
    allDates.sort();

    if (allDates.isEmpty) {
      return _buildEmptyState('No data available for the selected period');
    }

    double cumulativeBalance = 0;
    final spots = <FlSpot>[];

    for (int i = 0; i < allDates.length; i++) {
      final date = allDates[i];
      final income = incomes[date] ?? 0;
      final expense = expenses[date] ?? 0;
      cumulativeBalance += (income - expense);
      spots.add(FlSpot(i.toDouble(), cumulativeBalance));
    }

    final minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.2;

    return Card(
      shadowColor: Colors.black.withOpacity(0.1),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: 8,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((LineBarSpot spot) {
                    final index = spot.x.toInt();
                    final date = index < allDates.length ? allDates[index] : '';
                    return LineTooltipItem(
                      '${date.split('-').reversed.join('/')}\n${_currencyFormat.format(spot.y)}',
                      const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: (maxY - minY) / 4,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: allDates.length > 5
                      ? (allDates.length / 5).floorToDouble()
                      : 1,
                  getTitlesWidget: (value, meta) {
                    if (value >= 0 && value < allDates.length) {
                      final dateComponents = allDates[value.toInt()].split('-');
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${dateComponents[1]}/${dateComponents[2]}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      _currencyFormat.format(value).replaceAll('.00', ''),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (allDates.length - 1).toDouble(),
            minY: minY - padding < 0 ? minY : minY - padding,
            maxY: maxY + padding,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(TransactionType type) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final categoryTotals = provider.getCategoryTotals(type);

        if (categoryTotals.isEmpty) {
          return _buildEmptyState(
              'No ${type == TransactionType.income ? 'income' : 'expense'} data available');
        }

        // Sort categories by amount
        final sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Calculate total for percentages
        final total =
            categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

        // Create chart data
        final pieChartSections = <PieChartSectionData>[];

        for (int i = 0; i < sortedCategories.length; i++) {
          final entry = sortedCategories[i];
          final percentage = (entry.value / total) * 100;

          pieChartSections.add(
            PieChartSectionData(
              color: _chartColors[i % _chartColors.length],
              value: entry.value,
              title: '', // Remove label from pie
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 0, // Hide text in the pie
              ),
              badgeWidget: percentage < 5
                  ? null
                  : Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              badgePositionPercentageOffset: 0.8,
            ),
          );
        }

        return LayoutBuilder(builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;

          if (isWide) {
            // Side-by-side layout for wide screens
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          sections: pieChartSections,
                          centerSpaceRadius: 30,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: _buildCategoryLegend(sortedCategories, total),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Stacked layout for narrow screens
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        sections: pieChartSections,
                        centerSpaceRadius: 30,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCategoryLegend(sortedCategories, total),
                ],
              ),
            );
          }
        });
      },
    );
  }

  Widget _buildCategoryLegend(
    List<MapEntry<String, double>> categories,
    double total,
  ) {
    return Card(
      shadowColor: Colors.black.withOpacity(0.1),
      elevation: 10,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...categories.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final percentage = (category.value / total) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _chartColors[index % _chartColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.key,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currencyFormat.format(category.value),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _chartColors[index % _chartColors.length]
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _chartColors[index % _chartColors.length],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Provider.of<TransactionProvider>(context, listen: false)
                  .setFilter(DateFilterType.all);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('View All Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
