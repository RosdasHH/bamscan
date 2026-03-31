import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/modals/filament__scanned_modal.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
import 'package:bambuscanner/qrscan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final availableFilaments = context.watch<AvailableFilaments>();
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR-Code")),
      body: QrScan(
        enabled: scanenabled,
        scanDataCallback: (qrcode) async {
          qrcode = qrcode.toString();
          setState(() {
            scanenabled = false;
          });
          final List<Spool> spools = await availableFilaments.getSpoolsByQrCode(
            qrcode,
          );

          if (!context.mounted) return;
          if (spools.length > 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Multiple assignments: ${spools.map((s) => s.id)}",
                ),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: spools.isNotEmpty
                  ? Text("Found Spool")
                  : Text("No Spool found"),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
          if (spools.isEmpty) {
            Navigator.pop(context);
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilamentScannedModal(
                scannedSpool: spools[0],
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
