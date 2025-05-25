import 'dart:convert';

import 'package:ai_chat_pot/chat/controllers/chat_controller.dart';
import 'package:ai_chat_pot/chat/entities/chat_message_entity.dart';
import 'package:ai_chat_pot/core/service_locator/service_locator.dart';
import 'package:ai_chat_pot/core/static_data/shared_prefrences_key.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final sharedPreferences = serviceLocator<SharedPreferences>();
  ChatCubit() : super(ChatState(messages: []));
  void init() {
    List<String> chatData = sharedPreferences.getStringList(ShPrefKey.chatData) ?? [];
    emit(
      ChatState(
        messages: chatData.map((chat) => ChatMessageEntity.fromJson(jsonDecode(chat))).toList(),
      ),
    );
  }

  ChatController controller = serviceLocator();
  Future<void> sendMessage(String text) async {
    final userMessage = ChatMessageEntity(text: text, isUser: true);
    emit(ChatState(messages: [...state.messages, userMessage]));

    // Add typing indicator
    final typingIndicator = ChatMessageEntity(text: '', isUser: false, isTyping: true);
    emit(ChatState(messages: [...state.messages, typingIndicator]));
    String response = await controller.ask(text);
    final botReply = ChatMessageEntity(
      // text: "Bot: هذه هي الإجابة على سؤالك.",
      text: response,
      isUser: false,
    );
    final updatedMessages = state.messages.where((msg) => !msg.isTyping).toList()..add(botReply);
    emit(ChatState(messages: updatedMessages));
    sharedPreferences.setStringList(
      ShPrefKey.chatData,
      state.messages.map((chat) => jsonEncode(chat.toJson())).toList(),
    );
  }
}
