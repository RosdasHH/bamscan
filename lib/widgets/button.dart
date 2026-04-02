import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.expanded = false,
  });

  final Function() onPressed;
  final Widget child;
  final Color? color;
  final bool expanded;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.expanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ButtonStyle(
          backgroundColor: widget.color != null
              ? WidgetStateProperty.all(widget.color)
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}
