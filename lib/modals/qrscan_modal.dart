import 'package:bambuscanner/api.dart';
import 'package:bambuscanner/qrscan.dart';
import 'package:flutter/material.dart';

class QrscanModal extends StatefulWidget {
  const QrscanModal({
    super.key,
    required this.printerid,
    required this.amsid,
    required this.trayid,
  });

  final String printerid;
  final String amsid;
  final String trayid;

  @override
  State<QrscanModal> createState() => _QrscanModalState();
}

class _QrscanModalState extends State<QrscanModal> {
  @override
  Widget build(BuildContext context) {
    bool scanenabled = true;
    String? spoolid;
    return AlertDialog(
      title: const Text("Ams selection"),
      content: QrScan(
        enabled: scanenabled,
        scanDataCallback: (spoolid) {
          spoolid = spoolid.toString();
          setState(() {
            scanenabled = false;
          });
          setSlotToSpoolId(
            widget.printerid,
            widget.amsid,
            widget.trayid,
            spoolid,
          );
          Navigator.pop(context);
        },
      ),
      actions: [],
    );
  }
}
