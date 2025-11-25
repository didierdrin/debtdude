import 'package:shared_preferences/shared_preferences.dart';

class ReadTransactionsService {
  static const String _readTransactionsKey = 'read_transactions';

  static Future<Set<String>> getReadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final readTransactions = prefs.getStringList(_readTransactionsKey) ?? [];
    return readTransactions.toSet();
  }

  static Future<void> markAsRead(String transactionId) async {
    final prefs = await SharedPreferences.getInstance();
    final readTransactions = await getReadTransactions();
    readTransactions.add(transactionId);
    await prefs.setStringList(_readTransactionsKey, readTransactions.toList());
  }
}
