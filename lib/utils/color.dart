import 'dart:ui';
import 'package:flutter/material.dart';

Color toFlutterColor(String hexstring) {
  Color color;
  if (hexstring != "") {
    color = Color(int.parse("FF${hexstring.substring(0, 6)}", radix: 16));
  } else {
    color = Colors.white;
  }
  return color;
}
