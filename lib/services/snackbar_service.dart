import 'package:bamscan/services/globals.dart';
import 'package:bamscan/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SnackbarService {
  static void success(String text) {
    final context = Globals.navigatorKey.currentContext;

    _show(text, context?.appColor.success ?? Colors.green);
  }

  static void error(String text) {
    final context = Globals.navigatorKey.currentContext;

    _show(text, context?.appColor.error ?? Colors.red);
  }

  static void info(String text) {
    final context = Globals.navigatorKey.currentContext;

    _show(text, context?.appColor.info ?? Colors.blue);
  }

  static void warning(String text) {
    final context = Globals.navigatorKey.currentContext;

    _show(text, context?.appColor.warning ?? Colors.orange);
  }

  static void custom(String text, color) {
    _show(text, color);
  }

  static void _show(String text, Color color) {
    final context = Globals.navigatorKey.currentContext;
    Globals.scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: context?.appColor.base1,
        content: Text(text, style: TextStyle(color: color)),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: color, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        duration: Duration(seconds: 2),
        margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 75),
      ),
    );
  }
}
