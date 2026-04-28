import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/helper/showSnackbar.dart';
import 'package:bamscan/provider/available_filaments.dart';
import 'package:bamscan/services/device_capabilities.dart';
import 'package:bamscan/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

class Nfcscan extends StatefulWidget {
  const Nfcscan({super.key, this.nfcIdCallback, this.spoolCallback});
  final Function(String nfcid)? nfcIdCallback;
  final Function(Spool? spool)? spoolCallback;

  @override
  State<Nfcscan> createState() => _NfcscanState();
}

class _NfcscanState extends State<Nfcscan> {
  Future<void> startNFC() async {
    if (!await NfcManager.instance.isAvailable() && widget.spoolCallback != null) {
      widget.spoolCallback!(null);
      if (!mounted) {
        return;
      }
      showSnackbar(context, "NFC is not enabled!", context.appColor.error);
      return;
    }
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        String? nfca = tag.data['nfca']?['identifier'].toString();
        String? nfcv = tag.data['nfcv']?['identifier'].toString();
        String? mifareultralight = tag.data['mifareultralight']?['identifier'].toString();
        String? ndef = tag.data['ndef']?['identifier'].toString();
        String? nfcb = tag.data['nfcb']?['identifier'].toString();
        String? nfcf = tag.data['nfcf']?['identifier'].toString();
        String? isodep = tag.data['isodep']?['identifier'].toString();
        String? mifareclassic = tag.data['mifareclassic']?['identifier'].toString();

        if (nfca == "") nfca = null;
        if (nfcv == "") nfcv = null;
        if (mifareultralight == "") mifareultralight = null;
        if (ndef == "") ndef = null;
        if (nfcb == "") nfcb = null;
        if (nfcf == "") nfcf = null;
        if (isodep == "") isodep = null;
        if (mifareclassic == "") mifareclassic = null;

        String? id = nfca ?? nfcv ?? mifareultralight ?? ndef ?? nfcb ?? nfcf ?? isodep ?? mifareclassic;

        if (id == null) {
          showSnackbar(context, "Could not read tag!", context.appColor.error);
          return;
        } else {
          id = id.replaceAll("[", "").replaceAll("]", "");
        }

        if (widget.nfcIdCallback != null) {
          widget.nfcIdCallback!(id);
        }
        if (widget.spoolCallback != null) {
          AvailableFilaments availableFilaments = context.read<AvailableFilaments>();
          List<Spool> spools = await availableFilaments.getSpoolsByNfc(id);
          Spool? spool;
          try {
            spool = spools[0];
          } catch (_) {
            if (mounted) {
              showSnackbar(context, "No Spool found!", context.appColor.error);
            }
            spool = null;
          }
          widget.spoolCallback!(spool);
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    DeviceCapabilities().checkDevicesCapabilities();
    startNFC();
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
