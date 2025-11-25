import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/conversation_cubit.dart';
import '../cubits/save_firebase_cubit.dart';

class ConversationScreen extends StatefulWidget {
  final String conversationId;
  final String title;
  final String? initialMessage;
  
  const ConversationScreen({
    super.key,
    required this.conversationId,
    required this.title,
    this.initialMessage,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _transactions = [];

  void _sendMessage(BuildContext context) {
    if (_messageController.text.trim().isNotEmpty) {
      final message = _messageController.text;
      _messageController.clear();
      context.read<ConversationCubit>().sendMessage(message, _transactions);
    }
  }



  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messageController.text = widget.initialMessage!;
        _sendMessage(context);
      });
    }
  }

  void _loadTransactions(BuildContext context) {
    context.read<SaveFirebaseCubit>().getRecentTransactions().listen((transactions) {
      if (mounted) {
        setState(() {
          _transactions = transactions;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ConversationCubit(widget.conversationId)..loadMessages()),
        BlocProvider(create: (_) => SaveFirebaseCubit()),
      ],
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadTransactions(context);
          });
          return Scaffold(
            body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 24),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocConsumer<ConversationCubit, ConversationState>(
                    listener: (context, state) {
                      if (state is MessageSent || state is MessagesLoaded) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      }
                      if (state is ConversationError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is ConversationLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is MessagesLoaded) {
                        final messages = state.messages;
                        if (messages.isEmpty) {
                          return const Center(
                            child: Text('Start a conversation with DebtDude!'),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 8.0),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            return _buildMessageBubble(
                              text: message['text'] ?? '',
                              isMe: message['isMe'] ?? false,
                              time: message['time'] ?? '',
                            );
                          },
                        );
                      }
                      return const Center(
                        child: Text('Start a conversation with DebtDude!'),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(24.0),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              onSubmitted: (_) => _sendMessage(context),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      BlocBuilder<ConversationCubit, ConversationState>(
                        builder: (context, state) {
                          return GestureDetector(
                            onTap: state is MessageSending ? null : () => _sendMessage(context),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: state is MessageSending 
                                    ? Colors.grey 
                                    : const Color(0xFF5573F6),
                                shape: BoxShape.circle,
                              ),
                              child: state is MessageSending
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ), );
        },
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isMe,
    required String time,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF5573F6) : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16.0),
            topRight: const Radius.circular(16.0),
            bottomLeft: isMe ? const Radius.circular(16.0) : const Radius.circular(4.0),
            bottomRight: isMe ? const Radius.circular(4.0) : const Radius.circular(16.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}