import 'package:ai_chat_pot/chat/cubits/chat_cubit/chat_state.dart';
import 'package:ai_chat_pot/chat/helpers/clean_reply.dart';
import 'package:ai_chat_pot/utils/assets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lottie/lottie.dart';

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
              backgroundColor: Colors.green.withOpacity(0.05),
              child: Image.asset(AssetsData.logoSmall, height: 30),
            );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        mainAxisAlignment: !isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUser) avatar,
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
                      ? Lottie.asset(AssetsData.loading, height: 100, width: double.infinity)
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     const SizedBox(width: 8),
                      //     const SizedBox(
                      //       height: 12,
                      //       width: 12,
                      //       child: CircularProgressIndicator(strokeWidth: 2),
                      //     ),
                      //     const SizedBox(width: 8),
                      //   ],
                      // )
                      : InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: message.text));
                        },

                        // child: MarkdownBody(
                        //   data: cleanReply(message.text),
                        //   // textAlign: TextAlign.right,
                        //   styleSheet: MarkdownStyleSheet(
                        //     p: TextStyle(color: Colors.green),
                        //     listBullet: Theme.of(
                        //       context,
                        //     ).textTheme.bodyMedium?.copyWith(color: Colors.green),
                        //     a: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue),
                        //   ),
                        // ),
                        child: Html(
                          data: cleanReply(message.text),
                          // textAlign: TextAlign.right,
                        ),
                      ),
            ),
          ),
          if (!isUser) avatar,
        ],
      ),
    );
  }
}
