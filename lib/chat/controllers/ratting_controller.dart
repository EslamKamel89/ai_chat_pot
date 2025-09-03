import 'package:ai_chat_pot/core/api_service/api_consumer.dart';
import 'package:ai_chat_pot/core/heleprs/print_helper.dart';
import 'package:ai_chat_pot/core/service_locator/service_locator.dart';

class RatingController {
  final ApiConsumer api = serviceLocator();
  final addMessageEndpoint = "https://ioqs.org/control-panel/api/v1/ai";
  final addRatingEndpoint = "https://ioqs.org/control-panel/api/v1/ai/update";

  Future<String?> getId(String question, String answer) async {
    // dio.options.headers = {'Content-Type': 'application/json'};
    final t = "ChatService - getId";
    try {
      final response = await api.post(
        addMessageEndpoint,
        data: {"question": question, "answer": answer},
      );
      return pr(response['id'], t);
    } catch (e) {
      pr(e, t);
    }

    return null;
  }

  Future<String?> addRating(int rate, String comment, String id) async {
    // dio.options.headers = {'Content-Type': 'application/json'};
    final t = "ChatService - addRating";
    try {
      final response = await api.put(
        "$addRatingEndpoint/$id",
        data: {"rate": rate, "comment": comment},
      );
      return pr(response['id'], t);
    } catch (e) {
      pr(e, t);
    }

    return null;
  }
}
