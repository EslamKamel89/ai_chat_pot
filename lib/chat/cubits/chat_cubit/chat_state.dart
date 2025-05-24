// ignore_for_file: public_member_api_docs, sort_constructors_first

class ChatState {
  final List<ChatMessage> messages;

  const ChatState({required this.messages});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'messages': messages.map((x) => x.toJson()).toList()};
  }

  factory ChatState.fromJson(Map<String, dynamic> map) {
    return ChatState(
      messages: List<ChatMessage>.from(
        (map['messages'] as List<int>).map<ChatMessage>(
          (x) => ChatMessage.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  @override
  String toString() => 'ChatState(messages: $messages)';
}

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isTyping; // For bot typing indicator

  const ChatMessage({required this.text, required this.isUser, this.isTyping = false});

  ChatMessage copyWith({String? text, bool? isUser, bool? isTyping}) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'text': text, 'isUser': isUser, 'isTyping': isTyping};
  }

  factory ChatMessage.fromJson(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] as String,
      isUser: map['isUser'] as bool,
      isTyping: map['isTyping'] as bool,
    );
  }

  @override
  String toString() => 'ChatMessage(text: $text, isUser: $isUser, isTyping: $isTyping)';
}
