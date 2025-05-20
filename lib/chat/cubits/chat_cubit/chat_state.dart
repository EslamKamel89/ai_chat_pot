class ChatState {
  final List<ChatMessage> messages;

  const ChatState({required this.messages});
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
}
