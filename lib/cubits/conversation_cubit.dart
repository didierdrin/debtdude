import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

part 'conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  final String conversationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _messages = [];

  ConversationCubit(this.conversationId) : super(ConversationInitial());

  Future<void> loadMessages() async {
    try {
      emit(ConversationLoading());
      final response = await _apiService.getMessages(conversationId);
      
      if (response['success'] == true) {
        _messages = List<Map<String, dynamic>>.from(response['data'] ?? []);
        emit(MessagesLoaded(List.from(_messages)));
      } else {
        _messages = [];
        emit(MessagesLoaded([]));
      }
    } catch (e) {
      _messages = [];
      emit(MessagesLoaded([]));
    }
  }

  Future<void> sendMessage(String message, List<Map<String, dynamic>> transactions) async {
    try {
      // Add user message immediately
      final userMessage = {
        'text': message,
        'isMe': true,
        'time': DateTime.now().toString().substring(11, 16),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      _messages.add(userMessage);
      emit(MessagesLoaded(List.from(_messages)));
      
      // Show sending state
      emit(MessageSending());

      final user = _auth.currentUser;
      if (user == null) {
        emit(ConversationError('User not logged in'));
        return;
      }

      final response = await _apiService.sendMessage(conversationId, message, user.uid, transactions);
      
      if (response['success'] == true && response['data'] != null) {
        // Add AI response
        final aiMessage = {
          'text': response['data']['response'] ?? 'No response',
          'isMe': false,
          'time': DateTime.now().toString().substring(11, 16),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        _messages.add(aiMessage);
        emit(MessagesLoaded(List.from(_messages)));
      } else {
        emit(ConversationError('Failed to send message'));
      }
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }



}