import 'dart:async';

import 'package:ai_chat_pot/chat/presentation/widgets/toggle_assistance.dart';
import 'package:ai_chat_pot/core/heleprs/print_helper.dart';
import 'package:ai_chat_pot/core/service_locator/service_locator.dart';
import 'package:dio/dio.dart';

class ChatController {
  final Dio dio = serviceLocator();

  ChatController();

  Future<String> ask(String question) async {
    dio.options.headers = {
      'Authorization': 'Bearer ${getApiKey()}',
      'OpenAI-Beta': 'assistants=v2',
      'Content-Type': 'application/json',
    };
    try {
      // Step 1: Create thread
      final threadResponse = await dio.post('https://api.openai.com/v1/threads');
      final threadId = threadResponse.data['id'];

      // Step 2: Add user message
      await dio.post(
        'https://api.openai.com/v1/threads/$threadId/messages',
        data: {'role': 'user', 'content': question},
      );

      // Step 3: Start assistant run
      final runResponse = await dio.post(
        'https://api.openai.com/v1/threads/$threadId/runs',
        data: pr({'assistant_id': getAssistanceId()}, 'Assistance Id'),
      );
      final runId = runResponse.data['id'];

      // Step 4: Poll until completed
      String status = '';
      int attempt = 0;
      const int maxAttempts = 60;

      do {
        await Future.delayed(Duration(seconds: 1));
        final statusResponse = await dio.get(
          'https://api.openai.com/v1/threads/$threadId/runs/$runId',
        );
        status = statusResponse.data['status'];
        attempt++;
      } while (status != 'completed' && attempt < maxAttempts);

      if (status != 'completed') {
        throw Exception('Assistant did not respond in time.');
      }

      // Step 5: Fetch messages
      final messagesResponse = await dio.get(
        'https://api.openai.com/v1/threads/$threadId/messages',
      );
      final List messages = messagesResponse.data['data'];

      for (var message in messages) {
        if (message['role'] == 'assistant') {
          return message['content'][0]['text']['value'] ?? 'No reply found.';
        }
      }

      return 'No assistant reply found.';
    } on DioException catch (e) {
      return 'Dio error: ${e.message}';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
