import 'package:ai_chat_pot/core/globals.dart';
import 'package:ai_chat_pot/utils/styles/styles.dart';
import 'package:flutter/material.dart';

Future<bool?> showAreYouSureDialog() async {
  BuildContext? context = navigatorKey.currentContext;
  if (context == null) return null;
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (contex) {
      return AlertDialog(
        title: txt('Warning', e: St.bold14, c: Colors.red),
        content: txt('Do You Want To Proceed?!', e: St.semi12),
        actions: [
          TextButton(
            child: txt('Yes', e: St.reg12),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
          TextButton(
            child: txt('No', e: St.reg12),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
        ],
      );
    },
  );
  return result;
}
