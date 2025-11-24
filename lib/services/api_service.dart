import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://debtdude-expressjs-backend.onrender.com';

  Future<Map<String, dynamic>> getConversations() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/conversations'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Failed to load conversations'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> createConversation(String title, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/conversations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'userId': userId}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Failed to create conversation'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getMessages(String conversationId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/conversations/$conversationId/messages'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Failed to load messages'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> sendMessage(String conversationId, String message, String userId, List<Map<String, dynamic>>? transactions) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/conversations/$conversationId/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': message,
          'userId': userId,
          'transactions': transactions,
        }),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Failed to send message'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getDashboard(List<Map<String, dynamic>> transactions) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/dashboard'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'transactions': transactions}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Failed to get dashboard data'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}