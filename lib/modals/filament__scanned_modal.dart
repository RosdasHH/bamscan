import 'dart:ffi';

import 'package:bambuscanner/classes/spool.dart';
import 'package:flutter/material.dart';

class FilamentScannedModal extends StatefulWidget {
  const FilamentScannedModal({super.key, required this.scannedSpool});
  final Spool scannedSpool;
  @override
  State<FilamentScannedModal> createState() => _FilamentScannedModalState();
}

class _FilamentScannedModalState extends State<FilamentScannedModal> {
  @override
  Widget build(BuildContext context) {
    Color color = Color(int.parse("FF${widget.scannedSpool.rgba.substring(0, 6)}", radix: 16));

    return AlertDialog(
      title: const Text("Scanned spool"),
      content: Column(
        children: [
          Row(children: [Text("Material: ${widget.scannedSpool.material}")]),
          Row(children: [Text("Subtype: ${widget.scannedSpool.subtype}")]),
          Row(children: [Text("Color Name: ${widget.scannedSpool.colorName}")]),
          Row(children: [Text("Brand: ${widget.scannedSpool.brand}")]),
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: color),
                child: SizedBox.square(dimension: 20),
              ),
            ],
          ),
        ],
      ),
      actions: [],
    );
  }
}
