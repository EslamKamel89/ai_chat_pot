import 'package:flutter/material.dart';

typedef OnSendMessage = void Function(String text);

class MessageInput extends StatelessWidget {
  final OnSendMessage onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "اكتب سؤالك هنا...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                controller.clear();
                onSend(text);
              }
            },
          ),
        ],
      ),
    );
  }
}
