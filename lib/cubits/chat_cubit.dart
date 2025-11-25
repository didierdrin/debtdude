import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _apiService = ApiService();

  ChatCubit() : super(ChatInitial());

  Future<void> loadConversations() async {
    try {
      emit(ChatLoading());
      final user = _auth.currentUser;
      if (user == null) {
        emit(ChatError('User not logged in'));
        return;
      }

      final snapshot = await _firestore
          .collection('conversations')
          .doc(user.uid)
          .collection('chats')
          .orderBy('lastUpdated', descending: true)
          .get();
      
      final conversations = snapshot.docs.map((doc) => {
        'id': doc.id,
        'title': doc.data()['title'] ?? 'Chat',
        'lastMessage': doc.data()['lastMessage'] ?? '',
        'lastMessageTime': doc.data()['lastMessageTime'] ?? '',
      }).toList();
      
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ConversationsLoaded([]));
    }
  }

  Future<void> createConversation(String title) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(ChatError('User not logged in'));
        return;
      }

      final conversationId = DateTime.now().millisecondsSinceEpoch.toString();
      
      await _firestore
          .collection('conversations')
          .doc(user.uid)
          .collection('chats')
          .doc(conversationId)
          .set({
        'title': title,
        'messages': [],
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': null,
      });
      
      loadConversations();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> getDashboardData(List<Map<String, dynamic>> transactions) async {
    try {
      final totalBalance = transactions.fold<int>(0, (total, t) => total + (t['amount'] as num).toInt());
      final weeklySpending = transactions
          .where((t) => (t['amount'] as num) < 0 && _isThisWeek(t['timestamp'] as int))
          .fold<int>(0, (total, t) => total + (t['amount'] as num).abs().toInt());

      emit(DashboardDataLoaded({
        'totalBalance': totalBalance,
        'weeklySpending': weeklySpending,
      }));
    } catch (e) {
      _emitLocalDashboardData(transactions);
    }
  }

  void _emitLocalDashboardData(List<Map<String, dynamic>> transactions) {
    final totalBalance = transactions.fold<int>(0, (sum, t) => sum + (t['amount'] as num).toInt());
    final weeklySpending = transactions
        .where((t) => (t['amount'] as num) < 0 && _isThisWeek(t['timestamp'] as int))
        .fold<int>(0, (sum, t) => sum + (t['amount'] as num).abs().toInt());

    emit(DashboardDataLoaded({
      'totalBalance': totalBalance,
      'weeklySpending': weeklySpending,
    }));
  }

  bool _isThisWeek(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return date.isAfter(weekStart);
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(ChatError('User not logged in'));
        return;
      }

      await _firestore
          .collection('conversations')
          .doc(user.uid)
          .collection('chats')
          .doc(conversationId)
          .delete();
      
      loadConversations();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}