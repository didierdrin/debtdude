import 'package:debtdude/screens/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'conversation_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/chat_cubit.dart';
import '../cubits/save_firebase_cubit.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late SaveFirebaseCubit _saveFirebaseCubit;

  @override
  void initState() {
    super.initState();
    _saveFirebaseCubit = SaveFirebaseCubit();
    context.read<ChatCubit>().loadConversations();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    _saveFirebaseCubit.getRecentTransactions().listen((transactions) {
      if (transactions.isNotEmpty && mounted) {
        context.read<ChatCubit>().getDashboardData(transactions);
      }
    });
  }

  @override
  void dispose() {
    _saveFirebaseCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _saveFirebaseCubit,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add, color: Theme.of(context).textTheme.titleLarge?.color),
                          onPressed: () {
                            context.read<ChatCubit>().createConversation('New Chat');
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications_none_outlined, color: Theme.of(context).textTheme.titleLarge?.color),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())); 
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5573F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Questions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildQuickPrompt('Tell me my last 3 transactions'),
                            const SizedBox(width: 8),
                            _buildQuickPrompt('Who sent me the most money this week?'),
                            const SizedBox(width: 8),
                            _buildQuickPrompt('What\'s my spending pattern?'),
                            const SizedBox(width: 8),
                            _buildQuickPrompt('Show my balance summary'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recent Chat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      if (state is ChatLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is ConversationsLoaded) {
                        final conversations = state.conversations;
                        if (conversations.isEmpty) {
                          return const Center(
                            child: Text('No conversations yet. Tap + to start a new chat.'),
                          );
                        }
                        return ListView.builder(
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConversationScreen(
                                      conversationId: conversation['id'],
                                      title: conversation['title'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Color(0xFF5573F6),
                                      child: Icon(
                                        Icons.chat,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  conversation['title'] ?? 'Chat',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                _formatTime(conversation['lastMessageTime']),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            conversation['lastMessage'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: Text('Tap + to start a new conversation'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPrompt(String text) {
    return GestureDetector(
      onTap: () => _handleQuickPrompt(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _handleQuickPrompt(String prompt) {
    context.read<ChatCubit>().createConversation(prompt);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationScreen(
          conversationId: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Quick Chat',
          initialMessage: prompt,
        ),
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}

