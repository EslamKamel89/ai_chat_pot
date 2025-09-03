import 'package:ai_chat_pot/chat/controllers/ratting_controller.dart';
import 'package:ai_chat_pot/chat/presentation/widgets/message_input.dart';
import 'package:ai_chat_pot/core/service_locator/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RatingCommentWidget extends StatefulWidget {
  const RatingCommentWidget({super.key, required this.question, required this.answer});
  final String question;
  final String answer;
  @override
  State<RatingCommentWidget> createState() => _RatingCommentWidgetState();
}

class _RatingCommentWidgetState extends State<RatingCommentWidget> {
  FocusNode ratingCommentFocusNode = FocusNode();
  int _rating = 0;
  final commentTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // _rating = widget.initialRating;
    // commentTextController.text = widget.initialComment;
  }

  @override
  void dispose() {
    ratingCommentFocusNode.dispose();
    super.dispose();
  }

  void _showRatingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "تقييم الإجابة",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                StarRating(
                  key: UniqueKey(),
                  initialRating: _rating,
                  onRatingChanged: (value) {
                    setState(() {
                      _rating = value;
                    });
                    _rating;
                  },
                ),
                const SizedBox(height: 24),
                TextField(
                  maxLines: 3,
                  controller: commentTextController,
                  focusNode: ratingCommentFocusNode,
                  decoration: InputDecoration(
                    hintText: "أضف تعليقك هنا...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: RatingCommentSendButton(
                    onTap: () async {
                      final RatingController controller = serviceLocator();
                      String? id = await controller.getId(widget.question, widget.answer);
                      if (id == null) return;
                      await controller.addRating(_rating, commentTextController.text, id);
                      // pr({
                      //   'id': id,
                      //   'question': widget.question,
                      //   'answer': widget.answer,
                      //   'rating': _rating,
                      //   'comment': commentTextController.text,
                      // }, 'Rating Info');
                      commentTextController.text = '';
                      ratingCommentFocusNode.unfocus();
                      messageInputFocusNode.unfocus();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ).animate().slideY(begin: 1, end: 0);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // pr(widget.id, 'id');
        _showRatingModal(context);
      },

      child: Container(
        // color: Colors.green.withOpacity(0.3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // const Text("التقييم: ", style: TextStyle(fontSize: 16, color: Colors.white)),
            const SizedBox(width: 8),
            StarRating(initialRating: _rating, key: UniqueKey()),
          ],
        ),
      ),
    );
  }
}

class StarRating extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int>? onRatingChanged;

  const StarRating({super.key, required this.initialRating, this.onRatingChanged});

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int rating;
  @override
  void initState() {
    rating = widget.initialRating;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Text('hello world');
    if (widget.onRatingChanged == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return _buildStar(index);
        }),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return InkWell(
          onTap: () {
            widget.onRatingChanged!(index + 1);
            rating = index + 1;
            setState(() {});
          },
          child: _buildStar(index),
        );
      }),
    );
  }

  Widget _buildStar(int index) => Icon(
    index < rating ? Icons.star : Icons.star_border,
    color: index < rating ? Colors.orange : Colors.grey,
    size: 28,
  ).animate().scale().then(delay: Duration(milliseconds: index * 50));
}

class RatingCommentSendButton extends StatefulWidget {
  const RatingCommentSendButton({super.key, required this.onTap});
  final void Function() onTap;
  @override
  State<RatingCommentSendButton> createState() => _RatingCommentSendButtonState();
}

class _RatingCommentSendButtonState extends State<RatingCommentSendButton> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        setState(() {
          loading = true;
        });
        widget.onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          // color: Colors.green.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        alignment: Alignment.center,
        child:
            loading
                ? Center(child: CircularProgressIndicator())
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("إرسال التقييم", style: TextStyle(color: Colors.black)),
                    SizedBox(width: 10),
                    const Icon(Icons.check, color: Colors.black),
                  ],
                ),
      ),
    );
  }
}
