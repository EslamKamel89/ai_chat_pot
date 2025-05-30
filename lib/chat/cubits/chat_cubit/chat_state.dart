// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ai_chat_pot/chat/entities/chat_history_entity.dart';
import 'package:ai_chat_pot/chat/entities/chat_message_entity.dart';

class ChatState {
  List<ChatMessageEntity> messages;
  List<ChatHistoryEntity>? filteredConversations;
  List<ChatHistoryEntity> conversationsInHistory;
  ChatHistoryEntity? currentSessionConversation;
  ChatHistoryEntity? selectedConversation;
  bool? scrollToBottom;
  ChatState({
    required this.messages,
    required this.conversationsInHistory,
    this.filteredConversations,
    this.currentSessionConversation,
    this.selectedConversation,
    this.scrollToBottom = false,
  });

  ChatState copyWith({
    List<ChatMessageEntity>? messages,
    List<ChatHistoryEntity>? conversationsInHistory,
    List<ChatHistoryEntity>? filteredConversations,
    ChatHistoryEntity? currentSessionConversation,
    ChatHistoryEntity? selectedConversation,
    bool? scrollToBottom,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      conversationsInHistory: conversationsInHistory ?? this.conversationsInHistory,
      filteredConversations: filteredConversations ?? this.filteredConversations,
      currentSessionConversation: currentSessionConversation ?? this.currentSessionConversation,
      selectedConversation: selectedConversation ?? this.selectedConversation,
      scrollToBottom: scrollToBottom ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'messages': messages.map((x) => x.toJson()).toList(),
      'conversationsInHistory': conversationsInHistory.map((x) => x.toJson()).toList(),
      'currentSessionConversation': currentSessionConversation?.toJson(),
      'selectedConversation': selectedConversation?.toJson(),
    };
  }

  factory ChatState.fromJson(Map<String, dynamic> json) {
    return ChatState(
      messages: List<ChatMessageEntity>.from(
        (json['messages'] as List<int>).map<ChatMessageEntity>(
          (x) => ChatMessageEntity.fromJson(x as Map<String, dynamic>),
        ),
      ),
      conversationsInHistory: List<ChatHistoryEntity>.from(
        (json['conversationsInHistory'] as List<int>).map<ChatHistoryEntity>(
          (x) => ChatHistoryEntity.fromJson(x as Map<String, dynamic>),
        ),
      ),
      currentSessionConversation: ChatHistoryEntity.fromJson(
        json['currentSessionConversation'] as Map<String, dynamic>,
      ),
      selectedConversation:
          json['selectedConversation'] != null
              ? ChatHistoryEntity.fromJson(json['selectedConversation'] as Map<String, dynamic>)
              : null,
    );
  }

  @override
  String toString() {
    return 'ChatState(messages: $messages, conversationsInHistory: $conversationsInHistory, currentSessionConversation: $currentSessionConversation, selectedConversation: $selectedConversation)';
  }
}
