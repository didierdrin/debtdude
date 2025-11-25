import 'package:debtdude/screens/notifications_screen.dart';
import 'package:debtdude/screens/conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:debtdude/widgets/dialog_box.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:debtdude/cubits/save_firebase_cubit.dart';
import 'package:debtdude/cubits/currency_cubit.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedTab = 0; // 0 for Income, 1 for Outcome
  final Set<String> _readTransactions = {};

  List<Map<String, dynamic>> _calculateCategoryData(List<Map<String, dynamic>> transactions, bool isIncome) {
    final categoryTotals = <String, int>{};
    final categoryColors = {
      'Money Received': const Color(0xFF4CAF50),
      'Money Sent': const Color(0xFFF44336),
      'Loan Received': const Color(0xFF2196F3),
      'Loan Repayment': const Color(0xFFFF9800),
      'Vendor Payment': const Color(0xFF9C27B0),
    };

    for (final transaction in transactions) {
      final amount = (transaction['amount'] as num).abs().toInt();
      final type = transaction['type'] as String;
      final isPositive = (transaction['amount'] as num) > 0;
      
      if ((isIncome && isPositive) || (!isIncome && !isPositive)) {
        categoryTotals[type] = (categoryTotals[type] ?? 0) + amount;
      }
    }

    final total = categoryTotals.values.fold(0, (sum, amount) => sum + amount);
    if (total == 0) return [];

    return categoryTotals.entries.map((entry) {
      final percentage = ((entry.value / total) * 100).round();
      return {
        'category': entry.key,
        'amount': entry.value,
        'percentage': percentage,
        'color': categoryColors[entry.key] ?? const Color(0xFF5573F6),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _filterTransactions(List<Map<String, dynamic>> transactions, bool isIncome) {
    return transactions.where((transaction) {
      final amount = transaction['amount'] as num;
      return isIncome ? amount > 0 : amount < 0;
    }).map((transaction) => {
      ...transaction,
      'time': _formatTime(transaction['timestamp'] as int),
      'description': '${transaction['type']} via ${transaction['service']}',
    }).toList();
  }

  String _formatTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'pm' : 'am';
    return '${hour == 0 ? 12 : hour}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  double _getTotalAmount(List<Map<String, dynamic>> data) {
    return data.fold(0, (sum, item) => sum + (item['amount'] as num).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SaveFirebaseCubit(),
      child: BlocBuilder<SaveFirebaseCubit, SaveFirebaseState>(
        builder: (context, state) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: context.read<SaveFirebaseCubit>().getRecentTransactions(),
            builder: (context, snapshot) {
              final transactions = snapshot.data ?? [];
              final incomeData = _calculateCategoryData(transactions, true);
              final outcomeData = _calculateCategoryData(transactions, false);
              final incomeRecords = _filterTransactions(transactions, true);
              final outcomeRecords = _filterTransactions(transactions, false);
              
              final currentRecords = _selectedTab == 0 ? incomeRecords : outcomeRecords;
              final currentData = _selectedTab == 0 ? incomeData : outcomeData;
              final totalAmount = _getTotalAmount(currentData);

              return _buildStatsScreen(context, currentRecords, currentData, totalAmount);
            },
          );
        },
      ),
    );
  }

  Widget _buildStatsScreen(BuildContext context, List<Map<String, dynamic>> currentRecords, List<Map<String, dynamic>> currentData, double totalAmount) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Stats',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_outlined,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())); 
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Income and Outcome tabs
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? const Color(0xFF5573F6)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Income',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _selectedTab == 0
                                    ? Colors.white
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? const Color(0xFF5573F6)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'Expenses',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _selectedTab == 1
                                    ? Colors.white
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pie Chart Widget
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Simple Pie Chart representation using stacked containers
                    SizedBox(
                      height: 120,
                      child: currentData.isEmpty
                          ? const Center(
                              child: Text(
                                'No data available',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : Stack(
                              children: _buildPieChartSegments(currentData),
                            ),
                    ),
                    const SizedBox(height: 16),
                    // Legend
                    if (currentData.isNotEmpty)
                      Column(
                        children: currentData.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: item['color'],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item['category'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              Text(
                                '${item['percentage']}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              BlocBuilder<CurrencyCubit, CurrencyState>(
                                builder: (context, currencyState) {
                                  return Text(
                                    context.read<CurrencyCubit>().formatAmount(item['amount']),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                _selectedTab == 0 ? 'Income Breakdown' : 'Expense Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: currentRecords.isEmpty
                    ? const Center(
                        child: Text(
                          'No transactions found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: currentRecords.length,
                        itemBuilder: (context, index) {
                    final record = currentRecords[index];
                    final transactionId = "${record['name']}_${record['timestamp']}";
                    final isRead = _readTransactions.contains(transactionId);
                    
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DialogBox(
                              title: record['name'],
                              content: record['description'],
                              onAskDebtDude: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConversationScreen(
                                      conversationId: 'transaction_${record['timestamp']}',
                                      title: 'DebtDude Chat',
                                      initialMessage: 'Tell me about this transaction: ${record['name']} - ${record['description']} for ${context.read<CurrencyCubit>().formatAmount((record['amount'] as num).abs())}',
                                    ),
                                  ),
                                );
                              },
                              onMarkAsRead: () {
                                Navigator.pop(context);
                                setState(() {
                                  _readTransactions.add(transactionId);
                                });
                              },
                            );
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isRead ? Colors.transparent : Theme.of(context).dividerColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _getAvatarColor(record['category']),
                              child: Icon(
                                _getAvatarIcon(record['category']),
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          record['name'],
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        record['time'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    record['description'],
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  BlocBuilder<CurrencyCubit, CurrencyState>(
                                    builder: (context, currencyState) {
                                      return Text(
                                        context.read<CurrencyCubit>().formatAmount((record['amount'] as num).abs()),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedTab == 0
                                              ? const Color(0xFF4CAF50)
                                              : const Color(0xFFF44336),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                        },
                      ),),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPieChartSegments(List<Map<String, dynamic>> data) {
    final List<Widget> segments = [];
    double startAngle = 0;

    for (final item in data) {
      final percentage = item['percentage'] / 100;
      final sweepAngle = percentage * 360;

      segments.add(
        CustomPaint(
          painter: PieChartSegmentPainter(
            startAngle: startAngle,
            sweepAngle: sweepAngle,
            color: item['color'],
          ),
          size: const Size(120, 120),
        ),
      );

      startAngle += sweepAngle;
    }

    // Center text
    segments.add(
      Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<CurrencyCubit, CurrencyState>(
              builder: (context, currencyState) {
                return Text(
                  context.read<CurrencyCubit>().formatAmount(_getTotalAmount(data)),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                );
              },
            ),
            Text(
              _selectedTab == 0 ? 'Total Income' : 'Total Expenses',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    return segments;
  }

  Color _getAvatarColor(String category) {
    switch (category) {
      case 'received':
      case 'loan-received':
        return const Color(0xFF4CAF50);
      case 'sent':
      case 'loan-paid':
        return const Color(0xFFF44336);
      case 'vendor-paid':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF5573F6);
    }
  }

  IconData _getAvatarIcon(String category) {
    switch (category) {
      case 'received':
      case 'loan-received':
        return Icons.arrow_downward;
      case 'sent':
      case 'loan-paid':
        return Icons.arrow_upward;
      case 'vendor-paid':
        return Icons.store;
      default:
        return Icons.attach_money;
    }
  }
}

class PieChartSegmentPainter extends CustomPainter {
  final double startAngle;
  final double sweepAngle;
  final Color color;

  PieChartSegmentPainter({
    required this.startAngle,
    required this.sweepAngle,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    canvas.drawArc(
      rect,
      startAngle * (3.14159 / 180) -
          (3.14159 / 2), // Convert to radians and start from top
      sweepAngle * (3.14159 / 180), // Convert to radians
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
