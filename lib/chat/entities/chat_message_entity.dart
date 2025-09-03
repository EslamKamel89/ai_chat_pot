// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatMessageEntity {
  String? id;
  final String chatHistoryId;
  final String text;
  final bool isUser;
  final bool isTyping;
  final bool hasFollowUp;
  final String? searchId;
  String? question;

  ChatMessageEntity({
    required this.chatHistoryId,
    required this.text,
    required this.isUser,
    this.hasFollowUp = false,
    this.isTyping = false,
    this.id,
    this.question,
    this.searchId,
  }) {
    id ??= createId();
  }

  ChatMessageEntity copyWith({
    String? id,
    String? chatHistoryId,
    String? text,
    bool? isUser,
    bool? isTyping,
    String? question,
    bool? hasFollowUp,
    String? searchId,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      chatHistoryId: chatHistoryId ?? this.chatHistoryId,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isTyping: isTyping ?? this.isTyping,
      question: question ?? this.question,
      hasFollowUp: hasFollowUp ?? this.hasFollowUp,
      searchId: searchId ?? this.searchId,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'chatHistoryId': chatHistoryId,
      'text': text,
      'isUser': isUser,
      'isTyping': isTyping,
      'question': question,
      'hasFollowUp': hasFollowUp,
      'searchId': searchId,
    };
  }

  factory ChatMessageEntity.fromJson(Map<String, dynamic> json) {
    return ChatMessageEntity(
      id: json['id'] as String,
      chatHistoryId: json['chatHistoryId'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      isTyping: json['isTyping'] as bool,
      question: json['question'] as String?,
      hasFollowUp: (json['hasFollowUp'] ?? false) as bool,
      searchId: json['searchId'] as String?,
    );
  }
  static String createId() {
    return "ChatMessageEntity.${DateTime.now().millisecondsSinceEpoch}";
  }
}
