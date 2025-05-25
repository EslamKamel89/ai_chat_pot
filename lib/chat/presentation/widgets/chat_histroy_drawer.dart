import 'package:ai_chat_pot/chat/cubits/chat_cubit/chat_cubit.dart';
import 'package:ai_chat_pot/chat/cubits/chat_cubit/chat_state.dart';
import 'package:ai_chat_pot/chat/entities/chat_history_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHistoryDrawer extends StatelessWidget {
  // final List<ChatHistoryItem> chats;
  // final Function(String id) onDelete;

  const ChatHistoryDrawer({
    super.key,
    // required this.chats,
    // required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      color: Colors.white,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "المحادثات السابقة",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: Navigator.of(context).pop),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // InkWell(
            //   onTap: () {
            //     serviceLocator<SharedPreferences>().clear();
            //   },
            //   child: Container(
            //     padding: EdgeInsets.all(10),
            //     decoration: BoxDecoration(
            //       color: context.primaryColor,
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: Text('clear cache', style: TextStyle(color: Colors.white)),
            //   ),
            // ),
            // const SizedBox(height: 16),

            // Chat List
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  return ListView.builder(
                    itemCount: state.conversationsInHistory.length,
                    itemBuilder: (context, index) {
                      final chat = state.conversationsInHistory[index];
                      return InkWell(
                        onTap: () async {
                          final controller = context.read<ChatCubit>();
                          controller.selectConversation(chat.id!);
                          await Future.delayed(900.ms);
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).pop();
                        },
                        child: Transform.scale(
                          scale: state.selectedConversation?.id == chat.id ? 1.2 : 1,
                          child: _buildChatCard(chat, context),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCard(ChatHistoryEntity chat, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        // child: SlidableButton(
        //   startAction: () => onDelete(chat.id),
        // actionWidget:
        // Container(
        //   alignment: Alignment.center,
        //   padding: const EdgeInsets.only(left: 16),
        //   color: Colors.red,
        //   child: const Icon(Icons.delete, color: Colors.white),
        // ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: Colors.green,
                radius: 20,
                child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.title == null
                          ? "${chat.timestamp.hour}:${chat.timestamp.minute} - ${chat.timestamp.day}/${chat.timestamp.month}/${chat.timestamp.year}"
                          : chat.title!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   "${chat.timestamp.hour}:${chat.timestamp.minute} - ${chat.timestamp.day}/${chat.timestamp.month}/${chat.timestamp.year}",
                    //   textAlign: TextAlign.right,
                    //   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // ),
    ).animate().slideX(begin: 1.0, duration: 300.ms).fadeIn();
  }
}
