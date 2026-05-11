import 'package:bamscan/classes/printer.dart';
import 'package:bamscan/services/globals.dart';
import 'package:bamscan/services/storage.dart';
import 'package:bamscan/widgets/mjpeg_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrinterView extends StatefulWidget {
  const PrinterView({super.key, required this.printer});
  final Printer printer;

  @override
  State<PrinterView> createState() => _PrinterViewState();
}

class _PrinterViewState extends State<PrinterView> {
  @override
  Widget build(BuildContext context) {
    StorageService storageService = context.read<StorageService>();
    String mjpegUrl = "${storageService.getString(StorageService.kBambuddyUrl)}${Globals.apinamespace}/printers/${widget.printer.id}/camera/stream";
    return Scaffold(
      appBar: AppBar(title: Text(widget.printer.name)),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: MjpegView(url: mjpegUrl),
            ),
          ],
        ),
      ),
    );
  }
}
