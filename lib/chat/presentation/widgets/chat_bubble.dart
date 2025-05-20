import 'package:ai_chat_pot/chat/cubits/chat_cubit/chat_state.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final avatar =
        isUser
            ? CircleAvatar(child: Icon(Icons.person, color: Colors.white, size: 16))
            : CircleAvatar(
              backgroundColor: Colors.green,
              child: Text('BOT', style: TextStyle(fontSize: 12, color: Colors.white)),
            );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) avatar,
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.green[200] : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  message.isTyping
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // const SizedBox(width: 4),
                          // const SizedBox(
                          //   height: 12,
                          //   width: 12,
                          //   child: CircularProgressIndicator(strokeWidth: 2),
                          // ),
                          const SizedBox(width: 8),
                          const SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          // const SizedBox(
                          //   height: 12,
                          //   width: 12,
                          //   child: CircularProgressIndicator(strokeWidth: 2),
                          // ),
                        ],
                      )
                      : Text(
                        message.text,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
            ),
          ),
          if (isUser) avatar,
        ],
      ),
    );
  }
}
