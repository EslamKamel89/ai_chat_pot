// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ai_chat_pot/chat/presentation/widgets/lang_dropdown_widget.dart';
import 'package:flutter/material.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({super.key});

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

LocaleEntity? selectedLang;

class _LanguageDropdownState extends State<LanguageDropdown> {
  List<LocaleEntity> allowedLanguages = [
    LocaleEntity(localeCode: 'ar', label: 'العربية'),
    LocaleEntity(localeCode: 'en', label: 'English'),
    LocaleEntity(localeCode: 'sp', label: 'Spanish'),
    LocaleEntity(localeCode: 'ra', label: 'Russian'),
  ];

  @override
  Widget build(BuildContext context) {
    return LangDropDownWidget(
      options: allowedLanguages,
      label: "الرجاء اختيار لغة",
      onSelect: (code) {
        selectedLang = allowedLanguages.where((lang) => lang.localeCode == code).firstOrNull;
        // pr(selectedLang);
      },
    );
  }
}

class LocaleEntity {
  String localeCode;
  String label;
  LocaleEntity({required this.localeCode, required this.label});

  @override
  String toString() => 'LocaleEntity(localeCode: $localeCode, label: $label)';
}
