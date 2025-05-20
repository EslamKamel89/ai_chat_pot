import 'package:ai_chat_pot/core/heleprs/print_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatState(messages: []));

  void sendMessage(String text) {
    pr(text, 'send Message');
    final userMessage = ChatMessage(text: text, isUser: true);
    emit(ChatState(messages: [...state.messages, userMessage]));

    // Add typing indicator
    final typingIndicator = ChatMessage(text: '', isUser: false, isTyping: true);
    emit(ChatState(messages: [...state.messages, typingIndicator]));

    Future.delayed(const Duration(seconds: 1), () {
      final botReply = ChatMessage(text: "Bot: هذه هي الإجابة على سؤالك.", isUser: false);

      final updatedMessages = state.messages.where((msg) => !msg.isTyping).toList()..add(botReply);

      emit(ChatState(messages: updatedMessages));
    });
  }
}
