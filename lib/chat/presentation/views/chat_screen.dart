import 'package:ai_chat_pot/chat/cubits/chat_cubit/chat_cubit.dart';
import 'package:ai_chat_pot/chat/cubits/chat_cubit/chat_state.dart';
import 'package:ai_chat_pot/chat/presentation/widgets/chat_bubble.dart';
import 'package:ai_chat_pot/chat/presentation/widgets/message_input.dart';
import 'package:ai_chat_pot/core/widgets/default_screen_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Scaffold(
              appBar: AppBar(title: const Text("دلالات شات"), backgroundColor: Colors.green),
              body: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  _scrollToBottom();
                },
                builder: (context, state) {
                  return DefaultScreenPadding(
                    child: Column(
                      children: [
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
                        MessageInput(
                          onSend: (text) {
                            context.read<ChatCubit>().sendMessage(text);
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
