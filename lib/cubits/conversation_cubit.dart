import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  final String conversationId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ConversationCubit(this.conversationId) : super(ConversationInitial());

  Future<void> loadMessages() async {
    try {
      emit(ConversationLoading());
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp')
          .get();

      final messages = snapshot.docs.map((doc) => doc.data()).toList();
      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> sendMessage(String message, List<Map<String, dynamic>> transactions) async {
    try {
      emit(MessageSending());
      final user = _auth.currentUser;
      if (user == null) return;

      final timestamp = DateTime.now();
      final userMessage = {
        'text': message,
        'isMe': true,
        'time': _formatTime(timestamp),
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(userMessage);

      final aiResponse = _generateFinancialResponse(message, transactions);
      final aiMessage = {
        'text': aiResponse,
        'isMe': false,
        'time': _formatTime(DateTime.now()),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(aiMessage);

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .update({
            'lastMessage': message,
            'lastMessageTime': timestamp.toIso8601String(),
          });

      loadMessages();
      emit(MessageSent());
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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }
}