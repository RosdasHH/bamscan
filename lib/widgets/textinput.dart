import 'package:bambuscanner/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  const TextInput({
    super.key,
    required this.controller,
    this.labeltext = "",
    this.obscure = false,
    this.margin = 4.0,
    this.onchanged,
    this.value = "",
  });
  final TextEditingController controller;
  final String labeltext;
  final bool obscure;
  final double margin;
  final String value;
  final void Function(String)? onchanged;

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(widget.margin),
      child: TextField(
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
        },
        controller: widget.controller,
        decoration: InputDecoration(
          fillColor: context.appColor.base2,
          isDense: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(999),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(999),
          ),
          filled: true,
          hint: Text(widget.labeltext),
        ),

        obscureText: widget.obscure,
        onChanged: widget.onchanged,
        autocorrect: false,
      ),
    );
  }
}
