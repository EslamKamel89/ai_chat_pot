import 'dart:convert';

import 'package:ai_chat_pot/chat/controllers/chat_controller.dart';
import 'package:ai_chat_pot/chat/entities/chat_history_entity.dart';
import 'package:ai_chat_pot/chat/entities/chat_message_entity.dart';
import 'package:ai_chat_pot/core/service_locator/service_locator.dart';
import 'package:ai_chat_pot/core/static_data/shared_prefrences_key.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_state.dart';

ChatHistoryEntity? currentSession;

class ChatCubit extends Cubit<ChatState> {
  final sharedPreferences = serviceLocator<SharedPreferences>();
  ChatController controller = serviceLocator();
  ChatCubit() : super(ChatState(messages: [], conversationsInHistory: []));
  void init() async {
    List<String> conversationsInHistoryJson =
        sharedPreferences.getStringList(ShPrefKey.chatHistoryData) ?? [];
    List<ChatHistoryEntity> conversationsInHistory =
        conversationsInHistoryJson
            .map((json) => ChatHistoryEntity.fromJson(jsonDecode(json)))
            .toList();
    if (currentSession == null) {
      currentSession = ChatHistoryEntity(timestamp: DateTime.now());
      await sharedPreferences.setStringList(ShPrefKey.chatHistoryData, [
        jsonEncode(currentSession?.toJson()),
        ...conversationsInHistoryJson,
      ]);
      conversationsInHistory = [currentSession!, ...conversationsInHistory];
    }
    List<String> chatDataJson =
        sharedPreferences.getStringList("${ShPrefKey.chatData}.${currentSession!.id}") ?? [];
    List<ChatMessageEntity> chatData =
        chatDataJson.map((chat) => ChatMessageEntity.fromJson(jsonDecode(chat))).toList();
    emit(
      state.copyWith(
        conversationsInHistory: conversationsInHistory,
        messages: chatData,
        currentSessionConversation: currentSession,
        selectedConversation: currentSession,
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    final userMessage = ChatMessageEntity(
      text: text,
      isUser: true,
      chatHistoryId: state.currentSessionConversation!.id!,
    );

    emit(
      state.copyWith(
        messages: [...state.messages, userMessage],
        currentSessionConversation: state.currentSessionConversation!.copyWith(
          title: state.currentSessionConversation?.title ?? text,
        ),
        conversationsInHistory: cacheChatHistory(
          state.conversationsInHistory
              .map(
                (conversation) =>
                    conversation.id == currentSession!.id && conversation.title == null
                        ? conversation.copyWith(title: text)
                        : conversation,
              )
              .toList(),
        ),
      ),
    );

    // Add typing indicator
    final typingIndicator = ChatMessageEntity(
      text: '',
      isUser: false,
      isTyping: true,
      chatHistoryId: state.currentSessionConversation!.id!,
    );
    emit(state.copyWith(messages: [...state.messages, typingIndicator]));
    String response = await controller.ask(text);
    final botReply = ChatMessageEntity(
      // text: "Bot: هذه هي الإجابة على سؤالك.",
      text: response,
      isUser: false,
      chatHistoryId: state.currentSessionConversation!.id!,
    );
    final updatedMessages = state.messages.where((msg) => !msg.isTyping).toList()..add(botReply);
    emit(state.copyWith(messages: updatedMessages));
    sharedPreferences.setStringList(
      "${ShPrefKey.chatData}.${state.selectedConversation?.id}",
      state.messages.map((chat) => jsonEncode(chat.toJson())).toList(),
    );
  }

  void selectConversation(String conversationId) {
    final ChatHistoryEntity selectedCoversation = state.conversationsInHistory.firstWhere(
      (conversation) => conversation.id == conversationId,
    );
    List<String> chatDataJson =
        sharedPreferences.getStringList("${ShPrefKey.chatData}.${selectedCoversation.id}") ?? [];
    List<ChatMessageEntity> chatData =
        chatDataJson.map((chat) => ChatMessageEntity.fromJson(jsonDecode(chat))).toList();
    emit(state.copyWith(messages: chatData, selectedConversation: selectedCoversation));
  }

  List<ChatHistoryEntity> cacheChatHistory(List<ChatHistoryEntity> conversations) {
    sharedPreferences.setStringList(
      ShPrefKey.chatHistoryData,
      conversations.map((conversation) => jsonEncode(conversation.toJson())).toList(),
    );
    return conversations;
  }
}
