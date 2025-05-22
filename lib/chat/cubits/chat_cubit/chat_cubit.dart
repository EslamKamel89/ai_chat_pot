import 'package:ai_chat_pot/chat/controllers/chat_controller.dart';
import 'package:ai_chat_pot/core/service_locator/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatState(messages: []));
  ChatController controller = serviceLocator();
  Future<void> sendMessage(String text) async {
    final userMessage = ChatMessage(text: text, isUser: true);
    emit(ChatState(messages: [...state.messages, userMessage]));

    // Add typing indicator
    final typingIndicator = ChatMessage(text: '', isUser: false, isTyping: true);
    emit(ChatState(messages: [...state.messages, typingIndicator]));
    String response = await controller.ask(text);
    final botReply = ChatMessage(
      // text: "Bot: هذه هي الإجابة على سؤالك.",
      text: response,
      isUser: false,
    );
    final updatedMessages = state.messages.where((msg) => !msg.isTyping).toList()..add(botReply);
    emit(ChatState(messages: updatedMessages));
  }
}
