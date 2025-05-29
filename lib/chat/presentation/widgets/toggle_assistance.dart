import 'package:ai_chat_pot/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ToggleAssistanceId extends StatefulWidget {
  final void Function(bool) onChanged;

  const ToggleAssistanceId({super.key, required this.onChanged});

  @override
  State<ToggleAssistanceId> createState() => _ToggleAssistanceIdState();
}

bool _assistanceIdSelector = true;
String getAssistanceId() {
  return _assistanceIdSelector ? Env.assistantId : Env.assistantId2;
}

class _ToggleAssistanceIdState extends State<ToggleAssistanceId>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _colorAnimation = ColorTween(begin: Colors.grey[300], end: Colors.green).animate(_controller);

    if (_assistanceIdSelector) {
      _controller.forward();
    }
  }

  // @override
  // void didUpdateWidget(CustomToggleSwitch oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   if (oldWidget.initialValue != widget.initialValue) {
  //     setState(() {
  //       _value = widget.initialValue;
  //       _controller.animateTo(widget.initialValue ? 1.0 : 0.0);
  //     });
  //   }
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _assistanceIdSelector = !_assistanceIdSelector;
      _controller.animateTo(_assistanceIdSelector ? 1.0 : 0.0);
      widget.onChanged(_assistanceIdSelector);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Label
          Text(getAssistanceId(), style: TextStyle(fontSize: 14), textAlign: TextAlign.right),

          // Toggle Switch
          GestureDetector(
            onTap: _toggle,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Container(
                  width: 48.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: _colorAnimation.value,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 0.5,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Thumb
                      Positioned(
                            top: 2.0,
                            bottom: 2.0,
                            left: _controller.value * 16.0,
                            child: Container(
                              width: 28.0,
                              height: 28.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          )
                          .animate()
                          .fade(duration: 200.ms)
                          .moveX(end: _controller.value == 1 ? 0.0 : 0.2),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
