import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

part 'conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String conversationId;

  ConversationCubit(this.conversationId) : super(ConversationInitial());

  Future<void> loadMessages() async {
    try {
      emit(ConversationLoading());
      final response = await _apiService.getMessages(conversationId);
      if (response['success']) {
        emit(MessagesLoaded(response['data']));
      } else {
        emit(ConversationError('Failed to load messages'));
      }
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }

  Future<void> sendMessage(String message, List<Map<String, dynamic>>? transactions) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(ConversationError('User not logged in'));
        return;
      }

      emit(MessageSending());
      final response = await _apiService.sendMessage(conversationId, message, user.uid, transactions);
      if (response['success']) {
        emit(MessageSent(response['data']));
        loadMessages();
      } else {
        emit(ConversationError('Failed to send message'));
      }
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }
}