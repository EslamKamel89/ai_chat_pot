String cleanReply(String reply, {bool removeHtml = false, String? header}) {
  // Remove the pattern 【4:<digits>†الزنا.docx】
  reply = reply.replaceAll(RegExp(r'【.*?】'), '');
  reply = reply.replaceAll('#', '');
  reply = reply.replaceAll('*', '');
  if (removeHtml) {
    reply =
        reply
            .replaceAll(RegExp(r'</p>\s*<p>'), '''
''')
            .replaceAll(RegExp(r'<br\s*/?>'), '''
''')
            .replaceAll(RegExp(r'<[^>]+>'), '''
''')
            .trim();
  }
  reply = reply.replaceAll('html```', '');
  reply = reply.replaceAll('```', '');
  reply = reply.replaceAll('html', '');
  reply = reply.replaceAll('<"lang="ar>', '');
  reply = reply.replaceAll('lang="ar"', '');
  reply = reply.replaceAll('< >', '');
  // reply = reply.replaceAll(RegExp(r'【4:\d{1,3}†الزنا\.docx】'), '');
  // reply = reply.replaceAll(RegExp(r'【\d+:\d+†source】'), '');

  // Remove specific phrases
  List<String> phrasesToRemove = [
    'كما ورد في الملف الذي أرفقته',
    'بحسب المعلومات الواردة في ملفك،',
    'كما ورد في الملف المرفق',
  ];

  for (var phrase in phrasesToRemove) {
    reply = reply.replaceAll(phrase, '');
  }

  // Replace multiple spaces with a single space
  if (!removeHtml) {
    reply = reply.replaceAll(RegExp(r'\s+'), ' ');
  }

  // Trim leading and trailing spaces
  reply = reply.trim();
  if (header != null) {
    reply = '''
سؤال: 
$header
—————————————————

جواب:
$reply
''';
  }
  if (removeHtml) {
    reply = '''
$reply

———
هذا المحتوى مشارك من تطبيق دلالات شات
''';
  }
  reply = reply.replaceAll('  ', ' ');
  return reply;
}
