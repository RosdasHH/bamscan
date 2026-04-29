import 'package:bamscan/theme/app_theme.dart';
import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message, Color? color) {
  color ??= context.appColor.primary;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: context.appColor.base1,
      content: Text(message, style: TextStyle(color: color)),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      duration: Duration(seconds: 2),
      margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 75),
    ),
  );
}
