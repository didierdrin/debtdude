import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String geminiApiKey = 'AIzaSyDDkWO6fsx_E0BemYQDB4M_WPXXlY_eJ2U';
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
  
  static final List<Map<String, dynamic>> _conversations = [];
  static final Map<String, List<Map<String, dynamic>>> _messages = {};

  Future<Map<String, dynamic>> getConversations() async {
    return {'success': true, 'data': _conversations};
  }

  Future<Map<String, dynamic>> createConversation(String title, String userId) async {
    final conversationId = DateTime.now().millisecondsSinceEpoch.toString();
    final conversation = {
      'id': conversationId,
      'title': title,
      'userId': userId,
      'createdAt': DateTime.now().toIso8601String(),
      'lastMessage': 'Conversation started',
      'lastMessageTime': DateTime.now().toIso8601String(),
    };
    _conversations.add(conversation);
    _messages[conversationId] = [];
    return {'success': true, 'data': conversation};
  }

  Future<Map<String, dynamic>> getMessages(String conversationId) async {
    return {'success': true, 'data': _messages[conversationId] ?? []};
  }

  Future<Map<String, dynamic>> sendMessage(String conversationId, String message, String userId, List<Map<String, dynamic>>? transactions) async {
    final userMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': message,
      'isMe': true,
      'timestamp': DateTime.now().toIso8601String(),
      'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    };
    
    _messages[conversationId] ??= [];
    _messages[conversationId]!.add(userMessage);
    
    final aiResponse = await _generateChatResponse(message, transactions);
    
    final aiMessage = {
      'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      'text': aiResponse,
      'isMe': false,
      'timestamp': DateTime.now().toIso8601String(),
      'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    };
    
    _messages[conversationId]!.add(aiMessage);
    
    final conversationIndex = _conversations.indexWhere((c) => c['id'] == conversationId);
    if (conversationIndex != -1) {
      _conversations[conversationIndex]['lastMessage'] = message;
      _conversations[conversationIndex]['lastMessageTime'] = DateTime.now().toIso8601String();
    }
    
    return {'success': true, 'data': {'userMessage': userMessage, 'aiMessage': aiMessage}};
  }

  Future<String> _generateChatResponse(String message, List<Map<String, dynamic>>? transactions) async {
    try {
      final analysis = _analyzeTransactions(transactions ?? []);
      final prompt = 'You are DebtDude, a financial assistant. Based on the user\'s transaction data and their message: "$message", provide a helpful response about their finances.\n\nRecent transactions summary:\n${json.encode(analysis)}\n\nRespond in a conversational, helpful manner. Keep responses concise and actionable.';
      
      final response = await http.post(
        Uri.parse('$geminiApiUrl?key=$geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': [{
            'parts': [{'text': prompt}]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 500
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
      return 'Sorry, I\'m having trouble processing your request right now. Please try again later.';
    } catch (e) {
      return 'Sorry, I\'m having trouble processing your request right now. Please try again later.';
    }
  }

  Map<String, dynamic> _analyzeTransactions(List<Map<String, dynamic>> transactions, [String period = 'week']) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (period) {
      case 'day':
        startDate = now.subtract(const Duration(days: 1));
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'year':
        startDate = now.subtract(const Duration(days: 365));
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }
    
    final filteredTransactions = transactions.where((t) {
      final timestamp = t['timestamp'] as int? ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(timestamp).isAfter(startDate);
    }).toList();
    
    final totalSpent = filteredTransactions
        .where((t) => (t['amount'] as num) < 0)
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).abs());
        
    final totalReceived = filteredTransactions
        .where((t) => (t['amount'] as num) > 0)
        .fold(0.0, (sum, t) => sum + (t['amount'] as num));
    
    final topSenders = _getTopPeople(filteredTransactions.where((t) => (t['amount'] as num) > 0).toList());
    final topReceivers = _getTopPeople(filteredTransactions.where((t) => (t['amount'] as num) < 0).toList());
    
    return {
      'period': period,
      'totalSpent': totalSpent,
      'totalReceived': totalReceived,
      'netAmount': totalReceived - totalSpent,
      'transactionCount': filteredTransactions.length,
      'topSenders': topSenders,
      'topReceivers': topReceivers,
    };
  }

  List<Map<String, dynamic>> _getTopPeople(List<Map<String, dynamic>> transactions) {
    final Map<String, Map<String, dynamic>> people = {};
    
    for (final t in transactions) {
      final name = t['name'] as String? ?? 'Unknown';
      if (!people.containsKey(name)) {
        people[name] = {'name': name, 'amount': 0.0, 'count': 0};
      }
      people[name]!['amount'] = (people[name]!['amount'] as double) + (t['amount'] as num).abs();
      people[name]!['count'] = (people[name]!['count'] as int) + 1;
    }
    
    final sortedPeople = people.values.toList()
      ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
    
    return sortedPeople.take(5).toList();
  }

  Future<Map<String, dynamic>> getDashboard(List<Map<String, dynamic>> transactions) async {
    final analysis = _analyzeTransactions(transactions, 'week');
    final totalBalance = transactions.fold(0.0, (sum, t) => sum + (t['amount'] as num));
    
    return {
      'success': true,
      'data': {
        'totalBalance': totalBalance,
        'weeklySpending': analysis['totalSpent'],
        'weeklyReceived': analysis['totalReceived'],
        'netWeekly': analysis['netAmount'],
      }
    };
  }
}