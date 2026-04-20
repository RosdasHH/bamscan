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
    if (!await NfcManager.instance.isAvailable() &&
        widget.spoolCallback != null) {
      widget.spoolCallback!(null);
      if (!mounted) {
        return;
      }
      showSnackbar(context, "NFC is not enabled!", context.appColor.error);
      return;
    }
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        String id = tag.data["nfca"]["identifier"]
            .toString()
            .replaceAll("[", "")
            .replaceAll("]", "");
        if (widget.nfcIdCallback != null) {
          widget.nfcIdCallback!(id);
        }
        if (widget.spoolCallback != null) {
          AvailableFilaments availableFilaments = context
              .read<AvailableFilaments>();
          List<Spool> spools = await availableFilaments.getSpoolsByNfc(id);
          Spool? spool;
          try {
            spool = spools[0];
          } catch (_) {
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
