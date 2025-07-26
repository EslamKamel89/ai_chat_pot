import 'dart:async';

import 'package:ai_chat_pot/chat/presentation/widgets/toggle_assistance.dart';
import 'package:ai_chat_pot/core/api_service/api_interceptors.dart';
import 'package:ai_chat_pot/core/heleprs/print_helper.dart';
import 'package:ai_chat_pot/core/service_locator/service_locator.dart';
import 'package:dio/dio.dart';

class ChatController {
  final Dio dio = serviceLocator();
  void initDio() {
    dio.options.connectTimeout = const Duration(minutes: 2);
    dio.options.receiveTimeout = const Duration(minutes: 2);
    dio.options.headers = {"Accept": "application/json"};
    dio.interceptors.add(DioInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  ChatController();

  Future<String> ask(String question) async {
    if (getAssistanceId() == 'rag') {
      return await _askRag(question);
    }
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

  Future<String> _askRag(String question) async {
    dio.options.headers = {'Content-Type': 'application/json'};
    final t = prt('_askBag - ChatController');
    try {
      final response = await dio.get(
        "https://raggy.gaztec.org/http-controller",
        queryParameters: {"question ": question},
      );
      pr(response.data, t);
      return response.data['data']['answer'] ?? "عذرًا، حدث خطأ. يرجى المحاولة مرة أخرى لاحقًا.";
    } on DioException catch (e) {
      pr('Dio error: $e', t);
      return pr('Dio error: ${e.message ?? "unkwon error"}', t);
    } catch (e) {
      return pr('Error: $e', t);
    }
  }
}
