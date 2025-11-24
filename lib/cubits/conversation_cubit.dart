import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

part 'conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  final String conversationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  ConversationCubit(this.conversationId) : super(ConversationInitial());

  Future<void> loadMessages() async {
    try {
      emit(ConversationLoading());
      final response = await _apiService.getMessages(conversationId);
      
      if (response['success'] == true) {
        emit(MessagesLoaded(response['data'] ?? []));
      } else {
        emit(MessagesLoaded([]));
      }
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> sendMessage(String message, List<Map<String, dynamic>> transactions) async {
    try {
      emit(MessageSending());
      final user = _auth.currentUser;
      if (user == null) {
        emit(ConversationError('User not logged in'));
        return;
      }

      final response = await _apiService.sendMessage(conversationId, message, user.uid, transactions);
      
      if (response['success'] == true) {
        loadMessages();
        emit(MessageSent());
      } else {
        emit(ConversationError('Failed to send message'));
      }
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  String _generateFinancialResponse(String message, List<Map<String, dynamic>> transactions) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('balance') || lowerMessage.contains('total')) {
      final balance = transactions.fold<int>(0, (total, t) => total + (t['amount'] as num).toInt());
      return 'Your current balance is RWF $balance based on your recent transactions.';
    }
    
    if (lowerMessage.contains('spending') || lowerMessage.contains('expenses')) {
      final expenses = transactions.where((t) => (t['amount'] as num) < 0)
          .fold<int>(0, (total, t) => total + (t['amount'] as num).abs().toInt());
      return 'Your total expenses are RWF $expenses. This includes money sent, loan payments, and vendor payments.';
    }
    
    if (lowerMessage.contains('income') || lowerMessage.contains('received')) {
      final income = transactions.where((t) => (t['amount'] as num) > 0)
          .fold<int>(0, (total, t) => total + (t['amount'] as num).toInt());
      return 'Your total income is RWF $income from money received and loans.';
    }
    
    if (lowerMessage.contains('recent') || lowerMessage.contains('latest')) {
      if (transactions.isEmpty) {
        return 'You have no recent transactions.';
      }
      final latest = transactions.first;
      return 'Your latest transaction: ${latest['type']} of RWF ${(latest['amount'] as num).abs()} via ${latest['service']}.';
    }
    
    if (lowerMessage.contains('loan')) {
      final loans = transactions.where((t) => (t['type'] as String).contains('Loan')).toList();
      if (loans.isEmpty) {
        return 'You have no loan transactions in your recent history.';
      }
      final loanBalance = loans.fold<int>(0, (total, t) => total + (t['amount'] as num).toInt());
      return 'Your loan balance is RWF $loanBalance. You have ${loans.length} loan-related transactions.';
    }
    
    return 'I can help you with your financial information. Ask me about your balance, spending, income, recent transactions, or loans!';
  }

}