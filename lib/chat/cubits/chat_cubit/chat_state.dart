// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:ai_chat_pot/chat/entities/chat_message_entity.dart';

class ChatState {
  final List<ChatMessageEntity> messages;

  const ChatState({required this.messages});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'messages': messages.map((x) => x.toJson()).toList()};
  }

  factory ChatState.fromJson(Map<String, dynamic> map) {
    return ChatState(
      messages: List<ChatMessageEntity>.from(
        (map['messages'] as List<int>).map<ChatMessageEntity>(
          (x) => ChatMessageEntity.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  @override
  String toString() => 'ChatState(messages: $messages)';
}
