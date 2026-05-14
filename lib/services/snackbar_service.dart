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

  static void custom(String text, color) {
    _show(text, color);
  }

  static void _show(String text, Color color) {
    Globals.scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(backgroundColor: color, content: Text(text)));
  }
}
