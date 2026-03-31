import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  const Button({super.key, required this.onPressed, required this.child});
  final Function() onPressed;
  final Widget child;
  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: widget.onPressed, child: widget.child);
  }
}
