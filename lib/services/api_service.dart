import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://debtdude-expressjs-backend.onrender.com';

  Future<Map<String, dynamic>> getConversations() async {
    final response = await http.get(Uri.parse('$baseUrl/api/conversations'));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createConversation(String title, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/conversations'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title, 'userId': userId}),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getMessages(String conversationId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/conversations/$conversationId/messages'));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> sendMessage(String conversationId, String message, String userId, List<Map<String, dynamic>>? transactions) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/conversations/$conversationId/messages'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'message': message,
        'userId': userId,
        'transactions': transactions,
      }),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getDashboard(List<Map<String, dynamic>> transactions) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/dashboard'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'transactions': transactions}),
    );
    return json.decode(response.body);
  }
}