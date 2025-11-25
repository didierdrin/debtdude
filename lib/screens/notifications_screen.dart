import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/save_firebase_cubit.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Notifications",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).textTheme.bodyLarge?.color),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _topButton("SENT", 0),
                _topButton("RECEIVED", 1),
                // _topButton("TRACKING", 2),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: context.read<SaveFirebaseCubit>().getRecentTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final transactions = snapshot.data ?? [];
                final filteredTransactions = _getFilteredTransactions(transactions);
                
                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Text(
                      'No ${_getTabName()} notifications',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return _notificationTile(transaction);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _topButton(String text, int tabIndex) {
    final isActive = selectedTab == tabIndex;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = tabIndex),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.indigoAccent : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.indigoAccent),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.indigoAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredTransactions(List<Map<String, dynamic>> transactions) {
    switch (selectedTab) {
      case 0: // WITHDRAW (Money Sent)
        return transactions.where((tx) => 
          tx['category'] == 'sent' || 
          tx['category'] == 'vendor-paid' ||
          tx['category'] == 'loan-received'
        ).toList();
      case 1: // RECEIVED (Money Received)
        return transactions.where((tx) => 
          tx['category'] == 'received' ||
          tx['category'] == 'loan-paid'
        ).toList();
      case 2: // TRACKING (All transactions)
        return transactions;
      default:
        return [];
    }
  }

  String _getTabName() {
    switch (selectedTab) {
      case 0: return 'withdraw';
      case 1: return 'received';
      case 2: return 'tracking';
      default: return '';
    }
  }

  Widget _notificationTile(Map<String, dynamic> transaction) {
    final amount = transaction['amount'] as int? ?? 0;
    final isPositive = amount > 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.arrow_downward : Icons.arrow_upward;
    final name = transaction['name'] ?? 'Unknown';
    final type = transaction['type'] ?? 'Transaction';
    final service = transaction['service'] ?? '';
    final date = transaction['date'] ?? 'Unknown';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name - $type',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                Text(
                  'RWF ${amount.abs().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (service.isNotEmpty)
                  Text(
                    service,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
              ],
            ),
          ),
          Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
