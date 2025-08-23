// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:ai_chat_pot/chat/entities/chat_message_entity.dart';
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

  Future<ChatResponse> ask(String question, ChatMessageEntity? lastMessage) async {
    if (getAssistanceId() == 'rag') {
      return await _askRagTwo(question, lastMessage);
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
          return ChatResponse(text: message['content'][0]['text']['value'] ?? 'No reply found.');
        }
      }

      return ChatResponse(text: 'No assistant reply found.');
    } on DioException catch (e) {
      return ChatResponse(text: 'Dio error: ${e.message}');
    } catch (e) {
      return ChatResponse(text: 'Error: $e');
    }
  }

  Future<ChatResponse> _askRagOne(String question, ChatMessageEntity? lastMessage) async {
    dio.options.headers = {'Content-Type': 'application/json'};
    final t = prt('_askBagOne - ChatController');
    try {
      final response = await dio.get(
        "https://raggy.gaztec.org/http-controller",
        queryParameters: {"question ": question},
      );
      pr(response.data, t);
      final chatResponse = ChatResponse(
        text: response.data['data']['answer'] ?? "عذرًا، حدث خطأ. يرجى المحاولة مرة أخرى لاحقًا.",
      );
      await _searchRag(question, chatResponse, lastMessage);
      return chatResponse;
    } on DioException catch (e) {
      pr('Dio error: $e', t);
      return pr(ChatResponse(text: 'Dio error: ${e.message ?? "unkwon error"}'), t);
    } catch (e) {
      return pr(ChatResponse(text: 'Error: $e'), t);
    }
  }

  Future<ChatResponse> _askRagTwo(String question, ChatMessageEntity? lastMessage) async {
    dio.options.headers = {'Content-Type': 'application/json'};
    final t = prt('_askBagTwo - ChatController');
    try {
      final response = await dio.post(
        "https://raggy.gaztec.org/proxy",
        data: {
          "method": "POST",
          "body": {"question": question},
          "path": "generate",
        },
      );
      pr(response.data, t);
      String text = response.data['Tfser'][0] ?? "عذرًا، حدث خطأ. يرجى المحاولة مرة أخرى لاحقًا.";
      text = text.split('القواعد المستخدمة للاجابة').first;
      final chatResponse = ChatResponse(text: text);
      // await _searchRag(question, chatResponse, lastMessage);
      final List<dynamic> ayat = response.data?['Ayat'] ?? [];
      chatResponse.ayat = ayat.map((a) => a.toString()).toList();
      return chatResponse;
    } on DioException catch (e) {
      pr('Dio error: $e', t);
      return pr(ChatResponse(text: 'Dio error: ${e.message ?? "unkwon error"}'), t);
    } catch (e) {
      return pr(ChatResponse(text: 'Error: $e'), t);
    }
  }

  Future _searchRag(
    String question,
    ChatResponse chatResponse,
    ChatMessageEntity? lastMessage,
  ) async {
    dio.options.headers = {'Content-Type': 'application/json'};
    final t = prt('_searchRag - ChatController');
    try {
      final response = await dio.get(
        "https://raggy.gaztec.org/get-ayat",
        queryParameters: {"question": question, 'userid': lastMessage?.searchId ?? -1},
      );
      pr(response.data, t);
      final List<dynamic> ayat = response.data?['data']?['ayat'] ?? [];
      chatResponse.ayat = ayat.map((a) => a.toString()).toList();
      chatResponse.searchId = response.data?['data']?['Pmsg_id'];
      chatResponse.hasFollowUp = response.data?['data']?['followUp'];
      chatResponse.searchMessage = response.data?['data']?['message'];
    } on DioException catch (e) {
      pr('Dio error: $e', t);
      return pr(ChatResponse(text: 'Dio error: ${e.message ?? "unkwon error"}'), t);
    } catch (e) {
      return pr(ChatResponse(text: 'Error: $e'), t);
    }
  }
}

class ChatResponse {
  String? text;
  List<String>? ayat;
  String? searchId;
  bool? hasFollowUp;
  String? searchMessage;
  ChatResponse({this.text, this.ayat, this.searchId, this.hasFollowUp, this.searchMessage});

  @override
  String toString() =>
      'ChatResponse(text: $text, ayat: $ayat, searchId: $searchId , hasFollowUp: $hasFollowUp, searchMessage: $searchMessage)';
}
