import 'package:flutter/material.dart';

class BadgeCard extends StatelessWidget {
  const BadgeCard({super.key, required this.text, required this.color, this.padding = 5.0, this.fontsize = 12});
  final String text;
  final Color color;
  final double padding;
  final double fontsize;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: color.withValues(alpha: 0.4)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: padding / 2, horizontal: padding),
          child: Text(
            text,
            style: TextStyle(color: color, fontSize: fontsize),
          ),
        ),
      ),
    );
  }
}
