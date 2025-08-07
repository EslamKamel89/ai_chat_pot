import 'dart:convert';

import 'package:ai_chat_pot/chat/controllers/chat_controller.dart';
import 'package:ai_chat_pot/chat/entities/chat_history_entity.dart';
import 'package:ai_chat_pot/chat/entities/chat_message_entity.dart';
import 'package:ai_chat_pot/chat/presentation/widgets/toggle_assistance.dart';
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
            .where((conversation) => conversation.title != null)
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
        filteredConversations: conversationsInHistory,
        messages: chatData,
        currentSessionConversation: currentSession,
        selectedConversation: currentSession,
        scrollToBottom: true,
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    final lastMessage = state.messages.lastOrNull;
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
    emit(state.copyWith(messages: [...state.messages, typingIndicator], scrollToBottom: true));
    final chatResponse = await controller.ask(text, lastMessage);
    String response = chatResponse.text ?? '';
    if (getAssistanceId() == 'rag') {
      response = formatMessageToHtml(response);
    }
    if (chatResponse.ayat != null && chatResponse.ayat?.isNotEmpty == true) {
      response += formatVersesToHtml(chatResponse.ayat ?? []);
    }
    if (chatResponse.searchMessage != null) {
      response += formatMessageToHtml(chatResponse.searchMessage!);
    }
    final botReply = ChatMessageEntity(
      text: response,
      isUser: false,
      chatHistoryId: state.currentSessionConversation!.id!,
      question: userMessage.text,
      searchId: chatResponse.searchId,
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
    emit(
      state.copyWith(
        messages: chatData,
        selectedConversation: selectedCoversation,
        scrollToBottom: true,
      ),
    );
  }

  void deleteConversation(String conversationId) {
    if (state.conversationsInHistory.length <= 1) return;
    state.conversationsInHistory.removeWhere((conversation) => conversation.id == conversationId);
    cacheChatHistory(state.conversationsInHistory);
    emit(state.copyWith());
  }

  List<ChatHistoryEntity> cacheChatHistory(List<ChatHistoryEntity> conversations) {
    sharedPreferences.setStringList(
      ShPrefKey.chatHistoryData,
      conversations.map((conversation) => jsonEncode(conversation.toJson())).toList(),
    );
    return conversations;
  }

  void filterConversations(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(filteredConversations: state.conversationsInHistory));
    } else {
      final filtered =
          state.conversationsInHistory.where((conversation) {
            return conversation.title?.toLowerCase().contains(query.toLowerCase()) ?? false;
          }).toList();
      emit(state.copyWith(filteredConversations: filtered));
    }
  }

  String formatVersesToHtml(List<String> verses) {
    final buffer = StringBuffer();
    buffer.write('''
<div style="font-size: 20px;  font-family: 'Traditional Arabic', Arial, sans-serif; direction: rtl; text-align: right;  margin: 0 auto; padding: 5px; background-color: #f5f5f5; border-radius: 10px;">
الايات
</div>
''');
    buffer.write('''
<div style="font-family: 'Traditional Arabic', Arial, sans-serif; direction: rtl; text-align: right;  margin: 0 auto; padding: 5px; background-color: #f5f5f5; border-radius: 10px;">
''');

    for (final verse in verses) {
      final parts = verse.split(' (');
      if (parts.length != 2) continue;

      final verseText = parts[0];
      final reference = '(${parts[1]}';

      buffer.write('''
  <div style="margin-bottom: 5px; line-height: 1; font-size: 16px; color: #2c3e50;">
    <p style="margin: 0 0 5px 0; text-align: justify; word-spacing: -2px;">
      $verseText
    </p>
    <p style="margin: 0; font-size: 16px; color: #7f8c8d; text-align: left; direction: ltr;">
      $reference
    </p>
  </div>
''');
    }

    buffer.write('</div>');

    return buffer.toString();
  }

  String formatMessageToHtml(String message) {
    return '''
<div style="font-family: 'Traditional Arabic', Arial, sans-serif; 
             direction: rtl; 
             text-align: start; 
             max-width: 600px; 
             margin: 20px auto; 
             padding: 5px; 
             background-color: #f8f9fa; 
             border-radius: 8px; 
             box-shadow: 0 2px 4px rgba(0,0,0,0.1); 
             font-size: 16px; 
             color: #5a5a5a;
             line-height: 1;">
  $message
</div>
''';
  }
}
