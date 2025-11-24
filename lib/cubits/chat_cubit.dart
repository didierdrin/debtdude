import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  ChatCubit() : super(ChatInitial());

  Future<void> loadConversations() async {
    try {
      emit(ChatLoading());
      final response = await _apiService.getConversations();
      
      if (response['success'] == true) {
        emit(ConversationsLoaded(response['data'] ?? []));
      } else {
        emit(ConversationsLoaded([]));
      }
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

      final response = await _apiService.createConversation(title, user.uid);
      
      if (response['success'] == true) {
        loadConversations();
      } else {
        emit(ChatError('Failed to create conversation'));
      }
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
}