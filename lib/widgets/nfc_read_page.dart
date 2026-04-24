import 'package:bamscan/animation/nfc_animation.dart';
import 'package:bamscan/helper/showsnackbar.dart';
import 'package:bamscan/theme/app_theme.dart';
import 'package:bamscan/widgets/nfcscan.dart';
import 'package:flutter/material.dart';

enum Io { read, write }

class NfcReadPage extends StatefulWidget {
  const NfcReadPage({super.key, this.io = Io.read});
  final Io io;
  @override
  State<NfcReadPage> createState() => _NfcReadPageState();
}

class _NfcReadPageState extends State<NfcReadPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Read NFC-Tag")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NfcAnimation(),
            Nfcscan(
              spoolCallback: widget.io == Io.read
                  ? (spool) {
                      Navigator.pop(context, spool);
                      if (spool == null) {
                        showSnackbar(context, "No Spool found!", context.appColor.error);
                      }
                    }
                  : null,
              nfcIdCallback: widget.io == Io.write
                  ? (nfcid) {
                      Navigator.pop(context, nfcid);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
