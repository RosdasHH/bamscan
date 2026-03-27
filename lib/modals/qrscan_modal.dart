import 'package:bambuscanner/api.dart';
import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/modals/filament__scanned_modal.dart';
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
  bool scanenabled = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR-Code")),
      body: QrScan(
        enabled: scanenabled,
        scanDataCallback: (spoolid) async {
          spoolid = spoolid.toString();
          setState(() {
            scanenabled = false;
          });
          final Spool spool = await getSpoolById(spoolid);

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilamentScannedModal(
                scannedSpool: spool,
                printerid: widget.printerid,
                amsid: widget.amsid,
                trayid: widget.trayid,
              ),
            ),
          );
        },
      ),
    );
  }
}
