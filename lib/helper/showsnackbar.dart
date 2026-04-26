import 'package:bamscan/theme/app_theme.dart';
import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message, Color? color) {
  color ??= context.appColor.primary;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color,
      content: Text(message, style: TextStyle(color: Colors.grey[100])),
      duration: Duration(seconds: 2),
      margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 75),
    ),
  );
}
