import 'package:bambuscanner/api.dart';
import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/utils/color.dart';
import 'package:flutter/material.dart';

class FilamentScannedModal extends StatefulWidget {
  const FilamentScannedModal({
    super.key,
    required this.scannedSpool,
    required this.printerid,
    required this.amsid,
    required this.trayid,
  });
  final Spool scannedSpool;
  final String printerid;
  final String amsid;
  final String trayid;

  @override
  State<FilamentScannedModal> createState() => _FilamentScannedModalState();
}

class _FilamentScannedModalState extends State<FilamentScannedModal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scanned spool")),
      body: Column(
        children: [
          Row(children: [Text("Material: ${widget.scannedSpool.material}")]),
          Row(children: [Text("Subtype: ${widget.scannedSpool.subtype}")]),
          Row(children: [Text("Color Name: ${widget.scannedSpool.colorName}")]),
          Row(children: [Text("Brand: ${widget.scannedSpool.brand}")]),
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: toFlutterColor(widget.scannedSpool.rgba),
                ),
                child: SizedBox.square(dimension: 20),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  bool configured = await setSlotToSpoolId(
                    widget.printerid,
                    widget.amsid,
                    widget.trayid,
                    widget.scannedSpool.id.toString(),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: configured
                          ? Text("Spool assigned")
                          : Text("Spool NOT assigned"),
                      duration: Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.popUntil(context, (route) => route.settings.name == "ams");
                },
                child: const Text("Apply"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
