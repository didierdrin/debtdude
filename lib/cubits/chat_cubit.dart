import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatCubit() : super(ChatInitial());

  Future<void> loadConversations() async {
    try {
      emit(ChatLoading());
      final user = _auth.currentUser;
      if (user == null) {
        emit(ConversationsLoaded([]));
        return;
      }

      final snapshot = await _firestore
          .collection('conversations')
          .where('userId', isEqualTo: user.uid)
          .orderBy('lastMessageTime', descending: true)
          .get();

      final conversations = snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();

      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> createConversation(String title) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(ChatError('User not logged in'));
        return;
      }

      await _firestore.collection('conversations').add({
        'title': title,
        'userId': user.uid,
        'lastMessage': '',
        'lastMessageTime': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      loadConversations();
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> getDashboardData(List<Map<String, dynamic>> transactions) async {
    try {
      final totalBalance = transactions.fold<int>(0, (sum, t) => sum + (t['amount'] as num).toInt());
      final weeklySpending = transactions
          .where((t) => (t['amount'] as num) < 0 && _isThisWeek(t['timestamp'] as int))
          .fold<int>(0, (sum, t) => sum + (t['amount'] as num).abs().toInt());

      emit(DashboardDataLoaded({
        'totalBalance': totalBalance,
        'weeklySpending': weeklySpending,
      }));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  bool _isThisWeek(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return date.isAfter(weekStart);
  }
}