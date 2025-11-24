import 'package:bloc/bloc.dart';
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


}