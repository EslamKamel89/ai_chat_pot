import 'package:ai_chat_pot/chat/presentation/widgets/language_selector.dart';
import 'package:ai_chat_pot/core/extensions/context-extensions.dart';
import 'package:ai_chat_pot/utils/styles/styles.dart';
import 'package:flutter/material.dart';

class LangDropDownWidget extends StatefulWidget {
  const LangDropDownWidget({
    super.key,
    required this.options,
    required this.label,
    required this.onSelect,
  });
  final List<LocaleEntity> options;
  final String label;
  final Function(String) onSelect;
  @override
  State<LangDropDownWidget> createState() => _LangDropDownWidgetState();
}

class _LangDropDownWidgetState extends State<LangDropDownWidget> {
  String? selectedValue;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: _decoration(widget.label),
      items:
          widget.options
              .map(
                (option) =>
                    DropdownMenuItem<String>(value: option.localeCode, child: txt(option.label)),
              )
              .toList(),
      onChanged: (String? value) {
        if (value == null) return;
        widget.onSelect(value);
        setState(() {
          selectedValue = value;
        });
      },
      validator: (value) => value == null ? 'Please Select A Value' : null,
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: context.inputDecorationTheme.labelStyle,
      hintStyle: context.inputDecorationTheme.hintStyle,
      border: context.inputDecorationTheme.border,
      enabledBorder: context.inputDecorationTheme.enabledBorder,
      focusedBorder: context.inputDecorationTheme.focusedBorder,
      contentPadding: context.inputDecorationTheme.contentPadding,
    );
  }
}
