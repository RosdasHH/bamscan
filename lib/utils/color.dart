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

Color getContrastColor(Color bgColor) {
  final brightness = bgColor.computeLuminance();
  final hsl = HSLColor.fromColor(bgColor);

  double newLightness;
  if (brightness > 0.5) {
    newLightness = (hsl.lightness * 0.5).clamp(0.0, 1.0);
  } else {
    newLightness = (hsl.lightness + (1 - hsl.lightness) * 0.5).clamp(0.0, 1.0);
  }

  return hsl.withLightness(newLightness).toColor();
}
