// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ai_chat_pot/chat/presentation/widgets/lang_dropdown_widget.dart';
import 'package:flutter/material.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

String? selectedLang;

class _LanguageDropdownState extends State<LanguageDropdown> {
  List<String> allowedLanguages = ['ar', 'en', 'sp', 'ra'];

  @override
  Widget build(BuildContext context) {
    return LangDropDownWidget(
      options: allowedLanguages,
      label: 'Please select a language',
      onSelect: (lang) {},
    );
  }
}

class LocaleModel {
  String localeCode;
  String label;
  LocaleModel({required this.localeCode, required this.label});
}
