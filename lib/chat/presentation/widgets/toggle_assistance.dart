import 'package:ai_chat_pot/env.dart';
import 'package:flutter/material.dart';

class ToggleAssistanceId extends StatefulWidget {
  final void Function(bool) onChanged;

  const ToggleAssistanceId({super.key, required this.onChanged});

  @override
  State<ToggleAssistanceId> createState() => _ToggleAssistanceIdState();
}

int _assistanceIdSelector = 0;
List<String> _assistances = [
  //
  Env.assistantId,
  Env.assistantId2,
  // Env.assistantId3,
  'rag',
];
List<String> _apiKeys = [
  //
  Env.apiKey,
  Env.apiKey2,
  // Env.apiKey3,
  'rag',
];
List<String> _assistancesLabels = [
  //
  'Main',
  'Updated',
  // 'Quran Assistance',
  'Rag',
];
String getAssistanceId() {
  return _assistances[_assistanceIdSelector];
}

String getApiKey() {
  return _apiKeys[_assistanceIdSelector];
}

class _ToggleAssistanceIdState extends State<ToggleAssistanceId> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Label
            // Text(getAssistanceId(), style: TextStyle(fontSize: 14), textAlign: TextAlign.right),
            ...List.generate(_assistances.length, (index) {
              return RadioListTile<int>(
                title: Text(_assistancesLabels[index]),
                value: index,
                groupValue: _assistanceIdSelector,
                onChanged: (int? value) {
                  setState(() {
                    _assistanceIdSelector = value!;
                  });
                },
              );
            }),

            // Toggle Switch
          ],
        ),
      ),
    );
  }
}
