import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';
import 'save_firebase_cubit.dart';
part 'conversation_state.dart';

class ConversationCubit extends Cubit<ConversationState> {
  final String conversationId;
  final SaveFirebaseCubit? firebaseCubit;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _messages = [];

  ConversationCubit(this.conversationId, {this.firebaseCubit}) : super(ConversationInitial());

  Future<void> loadMessages() async {
    try {
      if (isClosed) return;
      emit(ConversationLoading());
      final user = _auth.currentUser;
      if (user == null) {
        if (!isClosed) emit(ConversationError('User not logged in'));
        return;
      }

      final doc = await _firestore
          .collection('conversations')
          .doc(user.uid)
          .collection('chats')
          .doc(conversationId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);
      } else {
        _messages = [];
      }
      
      if (!isClosed) emit(MessagesLoaded(List.from(_messages)));
    } catch (e) {
      _messages = [];
      if (!isClosed) emit(MessagesLoaded([]));
    }
  }

  Future<void> sendMessage(String message) async {
    try {
      // Add user message immediately
      final userMessage = {
        'text': message,
        'isMe': true,
        'time': DateTime.now().toString().substring(11, 16),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      _messages.add(userMessage);
      if (!isClosed) emit(MessagesLoaded(List.from(_messages)));
      await _saveMessagesToFirebase();
      
      // Show sending state
      if (!isClosed) emit(MessageSending());

      final user = _auth.currentUser;
      if (user == null) {
        emit(ConversationError('User not logged in'));
        return;
      }

      // Get transactions from Firebase if available
      List<Map<String, dynamic>> transactions = [];
      if (firebaseCubit != null) {
        try {
          transactions = await firebaseCubit!.getRecentTransactions().first;
        } catch (e) {
          // Continue with empty transactions if Firebase fetch fails
        }
      }

      final response = await _apiService.sendMessage(conversationId, message, user.uid, transactions);
      
      if (response['success'] == true && response['data'] != null) {
        // Add AI response - handle both response formats
        final responseText = response['data']['aiMessage']?['text'] ?? 
                           response['data']['response'] ?? 
                           'No response available';
        
        final aiMessage = {
          'text': responseText,
          'isMe': false,
          'time': DateTime.now().toString().substring(11, 16),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        _messages.add(aiMessage);
        if (!isClosed) emit(MessagesLoaded(List.from(_messages)));
        await _saveMessagesToFirebase();
      } else {
        // Add fallback message instead of showing error
        final fallbackMessage = {
          'text': 'I\'m currently experiencing high demand. Please try again in a few moments, or ask me about your balance, spending, or recent transactions for basic insights.',
          'isMe': false,
          'time': DateTime.now().toString().substring(11, 16),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        
        _messages.add(fallbackMessage);
        if (!isClosed) emit(MessagesLoaded(List.from(_messages)));
        await _saveMessagesToFirebase();
      }
    } catch (e) {
      // Add error message to chat instead of showing error state
      final errorMessage = {
        'text': 'Sorry, I\'m having trouble right now. Please check your connection and try again.',
        'isMe': false,
        'time': DateTime.now().toString().substring(11, 16),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      _messages.add(errorMessage);
      if (!isClosed) emit(MessagesLoaded(List.from(_messages)));
      await _saveMessagesToFirebase();
    }
  }

  Future<void> _saveMessagesToFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('conversations')
          .doc(user.uid)
          .collection('chats')
          .doc(conversationId)
          .set({
        'messages': _messages,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastMessage': _messages.isNotEmpty ? _messages.last['text'] : '',
        'lastMessageTime': _messages.isNotEmpty ? DateTime.now().toIso8601String() : null,
      }, SetOptions(merge: true));
    } catch (e) {
      // Silently fail to avoid disrupting user experience
    }
  }
}