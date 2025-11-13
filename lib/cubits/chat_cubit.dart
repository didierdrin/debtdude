import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChatCubit() : super(ChatInitial());

  Future<void> loadConversations() async {
    try {
      emit(ChatLoading());
      final response = await _apiService.getConversations();
      if (response['success']) {
        emit(ConversationsLoaded(response['data']));
      } else {
        emit(ChatError('Failed to load conversations'));
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
      if (response['success']) {
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
      final response = await _apiService.getDashboard(transactions);
      if (response['success']) {
        emit(DashboardDataLoaded(response['data']));
      } else {
        emit(ChatError('Failed to load dashboard data'));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}