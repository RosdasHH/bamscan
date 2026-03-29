import 'package:bambuscanner/theme/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  const TextInput({
    super.key,
    required this.controller,
    required this.labeltext,
    this.obscure = false,
    this.margin = 4.0,
    this.onchanged,
  });
  final TextEditingController controller;
  final String labeltext;
  final bool obscure;
  final double margin;
  final void Function(String)? onchanged;

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).extension<AppColor>()!;
    return Padding(
      padding: EdgeInsetsGeometry.all(widget.margin),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: widget.labeltext,
          labelStyle: TextStyle(color: appColor.secondary),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: appColor.secondary, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[200]!, width: 2),
          ),
        ),
        obscureText: widget.obscure,
        style: TextStyle(color: appColor.secondary),
        onChanged: widget.onchanged,
      ),
    );
  }
}
