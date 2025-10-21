import 'package:debtdude/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:debtdude/widgets/dialog_box.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedTab = 0; // 0 for Income, 1 for Outcome
  final List<Map<String, dynamic>> _incomeData = [
    {
      'category': 'Salary',
      'amount': 50000,
      'percentage': 50,
      'color': const Color(0xFF5573F6),
    },
    {
      'category': 'Freelance',
      'amount': 25000,
      'percentage': 25,
      'color': const Color(0xFF4CAF50),
    },
    {
      'category': 'Investments',
      'amount': 15000,
      'percentage': 15,
      'color': const Color(0xFFFF9800),
    },
    {
      'category': 'Other',
      'amount': 10000,
      'percentage': 10,
      'color': const Color(0xFFF44336),
    },
  ];

  final List<Map<String, dynamic>> _outcomeData = [
    {
      'category': 'Food',
      'amount': 20000,
      'percentage': 40,
      'color': const Color(0xFF5573F6),
    },
    {
      'category': 'Transport',
      'amount': 10000,
      'percentage': 20,
      'color': const Color(0xFF4CAF50),
    },
    {
      'category': 'Entertainment',
      'amount': 8000,
      'percentage': 16,
      'color': const Color(0xFFFF9800),
    },
    {
      'category': 'Bills',
      'amount': 12000,
      'percentage': 24,
      'color': const Color(0xFFF44336),
    },
  ];

  final List<Map<String, dynamic>> _incomeRecords = [
    {
      'name': 'John - Debt Record',
      'time': '2:15 pm',
      'description': 'You borrowed 15,000 on 20th Sept.',
      'amount': 15000,
      'type': 'borrowed',
    },
    {
      'name': 'Sarah - Payment',
      'time': '1:30 pm',
      'description': 'Sarah paid back 8,000',
      'amount': 8000,
      'type': 'received',
    },
    {
      'name': 'Mike - Debt Record',
      'time': '11:45 am',
      'description': 'You borrowed 25,000 on 19th Sept.',
      'amount': 25000,
      'type': 'borrowed',
    },
    {
      'name': 'Emma - Payment',
      'time': '10:20 am',
      'description': 'Emma paid back 12,000',
      'amount': 12000,
      'type': 'received',
    },
    {
      'name': 'David - Debt Record',
      'time': '9:15 am',
      'description': 'You borrowed 10,000 on 18th Sept.',
      'amount': 10000,
      'type': 'borrowed',
    },
  ];

  final List<Map<String, dynamic>> _outcomeRecords = [
    {
      'name': 'Grocery Store',
      'time': '2:15 pm',
      'description': 'Weekly grocery shopping',
      'amount': 5000,
      'type': 'food',
    },
    {
      'name': 'Fuel Station',
      'time': '1:30 pm',
      'description': 'Car refueling',
      'amount': 3000,
      'type': 'transport',
    },
    {
      'name': 'Electricity Bill',
      'time': '11:45 am',
      'description': 'Monthly electricity payment',
      'amount': 2500,
      'type': 'bills',
    },
    {
      'name': 'Movie Tickets',
      'time': '10:20 am',
      'description': 'Weekend movie',
      'amount': 2000,
      'type': 'entertainment',
    },
    {
      'name': 'Restaurant',
      'time': '9:15 am',
      'description': 'Dinner with friends',
      'amount': 4500,
      'type': 'food',
    },
  ];

  double _getTotalAmount(List<Map<String, dynamic>> data) {
    return data.fold(
      0,
      (sum, item) => sum + (item['amount'] as num).toDouble(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRecords = _selectedTab == 0 ? _incomeRecords : _outcomeRecords;

    final currentData = _selectedTab == 0 ? _incomeData : _outcomeData;
    final totalAmount = _getTotalAmount(currentData);

    return Scaffold(
      backgroundColor: Colors.white,
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
                  const Text(
                    'Stats',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen())); 
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Income and Outcome tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
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
                                    : Colors.black,
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
                              'Outcome',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _selectedTab == 1
                                    ? Colors.white
                                    : Colors.black,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Simple Pie Chart representation using stacked containers
                    Container(
                      height: 120,
                      child: Stack(
                        children: _buildPieChartSegments(currentData),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Legend
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
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Text(
                                '${item['percentage']}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'RWF${item['amount']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: currentRecords.length,
                  itemBuilder: (context, index) {
                    final record = currentRecords[index];
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
                                print(
                                  'Ask DebtDude pressed for ${record['name']}',
                                );
                              },
                              onMarkAsRead: () {
                                Navigator.pop(context);
                                print(
                                  'Mark as Read pressed for ${record['name']}',
                                );
                              },
                            );
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _getAvatarColor(record['type']),
                              child: Icon(
                                _getAvatarIcon(record['type']),
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
                                      Text(
                                        record['name'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
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
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'RWF${record['amount']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedTab == 0
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFFF44336),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
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
            Text(
              'RWF${_getTotalAmount(data).toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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

  Color _getAvatarColor(String type) {
    switch (type) {
      case 'borrowed':
        return const Color(0xFF5573F6);
      case 'received':
        return const Color(0xFF4CAF50);
      case 'food':
        return const Color(0xFFFF9800);
      case 'transport':
        return const Color(0xFF9C27B0);
      case 'bills':
        return const Color(0xFFF44336);
      case 'entertainment':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF5573F6);
    }
  }

  IconData _getAvatarIcon(String type) {
    switch (type) {
      case 'borrowed':
        return Icons.arrow_downward;
      case 'received':
        return Icons.arrow_upward;
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'bills':
        return Icons.receipt;
      case 'entertainment':
        return Icons.movie;
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
