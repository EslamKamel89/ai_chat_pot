String cleanReply(String reply) {
  // Remove the pattern 【4:<digits>†الزنا.docx】
  reply = reply.replaceAll(RegExp(r'【.*?】'), '');
  reply = reply.replaceAll('html```', '');
  reply = reply.replaceAll('```', '');
  reply = reply.replaceAll('html', '');
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
  reply = reply.replaceAll(RegExp(r'\s+'), ' ');

  // Trim leading and trailing spaces
  reply = reply.trim();

  return reply;
}

void main() {
  String reply = "كما ورد في الملف الذي أرفقته   وبعض النصوص الأخرى.";
  String cleaned = cleanReply(reply);
  print(cleaned); // Output: "بعض النصوص الأخرى."
}
