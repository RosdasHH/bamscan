import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  const Button({super.key, required this.onPressed, required this.child, this.expanded = false, this.color, this.borderColor});

  final Function()? onPressed;
  final Widget child;
  final Color? color;
  final bool expanded;
  final Color? borderColor;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.expanded ? double.infinity : null,
      child: widget.borderColor != null
          ? OutlinedButton(
              onPressed: widget.onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: widget.onPressed != null ? widget.borderColor!.withValues(alpha: 0.5) : widget.borderColor!, width: 1.5),
                backgroundColor: widget.color,
              ),
              child: widget.child,
            )
          : ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(backgroundColor: widget.color?.withValues(alpha: 0.3), foregroundColor: widget.color,padding: EdgeInsets.all(0)),
              child: widget.child,
            ),
    );
  }
}
