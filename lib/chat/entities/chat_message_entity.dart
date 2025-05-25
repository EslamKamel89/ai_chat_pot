class ChatMessageEntity {
  final String text;
  final bool isUser;
  final bool isTyping; // For bot typing indicator

  const ChatMessageEntity({required this.text, required this.isUser, this.isTyping = false});

  ChatMessageEntity copyWith({String? text, bool? isUser, bool? isTyping}) {
    return ChatMessageEntity(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'text': text, 'isUser': isUser, 'isTyping': isTyping};
  }

  factory ChatMessageEntity.fromJson(Map<String, dynamic> map) {
    return ChatMessageEntity(
      text: map['text'] as String,
      isUser: map['isUser'] as bool,
      isTyping: map['isTyping'] as bool,
    );
  }

  @override
  String toString() => 'ChatMessage(text: $text, isUser: $isUser, isTyping: $isTyping)';
}
