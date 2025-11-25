import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; 

class ApiService {
  static String? _geminiApiKey; 
  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
  
  static final List<Map<String, dynamic>> _conversations = [];
  static final Map<String, List<Map<String, dynamic>>> _messages = {};



  // Initialize API key from secure storage
  static Future<void> initializeApiKey() async {
    try {
      // Try to load from assets first
      final String response = await rootBundle.loadString('assets/config/api_keys.json');
      final data = json.decode(response);
      _geminiApiKey = data['gemini_api_key'];
    } catch (e) {
      // Fallback: Use environment variable or continue without API
      _geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY');
      if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
        print('Gemini API key not found. Chat features will use fallback responses.');
        _geminiApiKey = null; // Allow app to continue without API
      }
    }
  }

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
    
    return {'success': true, 'data': {'userMessage': userMessage, 'aiMessage': aiMessage, 'response': aiResponse}};
  }



  Future<String> _generateChatResponse(String message, List<Map<String, dynamic>>? transactions) async {
    try {
      if (_geminiApiKey == null) {
        await initializeApiKey();
      }

      final analysis = _analyzeTransactions(transactions ?? []);
      final prompt = 'You are DebtDude, a financial assistant. Based on the user\'s transaction data and their message: "$message", provide a helpful response about their finances.\n\nRecent transactions summary:\n${json.encode(analysis)}\n\nRespond in a conversational, helpful manner. Keep responses concise and actionable.';
      
      final response = await http.post(
        Uri.parse('$geminiApiUrl?key=$_geminiApiKey'),
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
      } else if (response.statusCode == 429) {
        // Rate limit exceeded - provide intelligent fallback
        return _generateFallbackResponse(message, analysis);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        return _generateFallbackResponse(message, analysis);
      }
    } catch (e) {
      print('Error generating response: $e');
      return _generateFallbackResponse(message, transactions != null ? _analyzeTransactions(transactions) : {});
    }
  }

  String _generateFallbackResponse(String message, Map<String, dynamic> analysis) {
    final lowerMessage = message.toLowerCase();
    
    // Balance inquiry
    if (lowerMessage.contains('balance') || lowerMessage.contains('money')) {
      final netAmount = analysis['netAmount'] ?? 0.0;
      if (netAmount > 0) {
        return 'Based on your recent transactions, you have a positive net flow of ${netAmount.toStringAsFixed(0)} RWF. Keep up the good financial management!';
      } else {
        return 'Your recent transactions show a net outflow of ${netAmount.abs().toStringAsFixed(0)} RWF. Consider reviewing your spending patterns.';
      }
    }
    
    // Spending inquiry
    if (lowerMessage.contains('spend') || lowerMessage.contains('expense')) {
      final totalSpent = analysis['totalSpent'] ?? 0.0;
      return 'You\'ve spent ${totalSpent.toStringAsFixed(0)} RWF recently. ${totalSpent > 50000 ? "Consider tracking your expenses more closely." : "Your spending looks reasonable."}';
    }
    
    // Income inquiry
    if (lowerMessage.contains('income') || lowerMessage.contains('receive')) {
      final totalReceived = analysis['totalReceived'] ?? 0.0;
      return 'You\'ve received ${totalReceived.toStringAsFixed(0)} RWF recently. ${totalReceived > 0 ? "Great job on maintaining income flow!" : "Consider exploring additional income sources."}';
    }
    
    // General advice
    if (lowerMessage.contains('advice') || lowerMessage.contains('help')) {
      return 'Here are some quick tips: Track your daily expenses, set a monthly budget, save at least 10% of your income, and avoid unnecessary debt. Would you like specific advice about any of these areas?';
    }
    
    // Default response
    return 'I\'m currently experiencing high demand and my AI responses are temporarily limited. However, I can see you have ${analysis['transactionCount'] ?? 0} recent transactions. Feel free to ask about your balance, spending, or income for basic insights!';
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