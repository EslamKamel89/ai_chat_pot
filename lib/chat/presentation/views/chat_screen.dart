import 'package:ai_chat_pot/chat/cubits/chat_cubit/chat_cubit.dart';
import 'package:ai_chat_pot/chat/cubits/chat_cubit/chat_state.dart';
import 'package:ai_chat_pot/chat/presentation/widgets/chat_bubble.dart';
import 'package:ai_chat_pot/chat/presentation/widgets/chat_histroy_drawer.dart';
import 'package:ai_chat_pot/chat/presentation/widgets/message_input.dart';
import 'package:ai_chat_pot/core/widgets/default_screen_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  late ChatCubit controller;
  @override
  void initState() {
    controller = context.read<ChatCubit>();
    WakelockPlus.enable();
    super.initState();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Scaffold(
              appBar: AppBar(title: const Text("دلالات شات"), backgroundColor: Colors.green),
              drawer: ChatHistoryDrawer(),
              body: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state.scrollToBottom == true) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  return DefaultScreenPadding(
                    child: Column(
                      children: [
                        if (state.messages.isNotEmpty)
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: state.messages.length,
                              itemBuilder: (context, index) {
                                final message = state.messages[index];
                                return ChatBubble(
                                  message: message,
                                ).animate().fadeIn(duration: 300.ms);
                              },
                            ),
                          ),
                        if (state.messages.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                "اطرح سؤالاً",
                                style: TextStyle(fontSize: 20, color: Colors.grey),
                              ),
                            ),
                          ),
                        MessageInput(
                          onSend: (text) {
                            controller.sendMessage(text);
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
