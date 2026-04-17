import 'package:bamscan/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  const TextInput({
    super.key,
    required this.controller,
    this.hinttext = "",
    this.obscure = false,
    this.margin = 4.0,
    this.onchanged,
    this.value = "",
    this.onTapOutside,
    this.labeltext = "",
    this.autofocus = false,
  });
  final TextEditingController controller;
  final String hinttext;
  final bool obscure;
  final double margin;
  final String value;
  final String labeltext;
  final void Function(String)? onchanged;
  final void Function()? onTapOutside;
  final bool autofocus;

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
          if (widget.onTapOutside != null) {
            widget.onTapOutside!.call();
          }
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
          hint: Text(widget.hinttext),
          label: widget.labeltext.isNotEmpty ? Text(widget.labeltext) : null,
        ),
        obscureText: widget.obscure,
        onChanged: widget.onchanged,
        autocorrect: false,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.go,
        onSubmitted: (_) {
          widget.onTapOutside!.call();
        },
      ),
    );
  }
}
