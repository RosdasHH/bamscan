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
        String? id = getUid(tag);
        print(id);
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

  String? getUid(NfcTag tag) {
    final data = tag.data;

    String? type;
    List<int>? id;

    if (data['nfca']?['identifier'] != null) {
      type = 'nfca';
      id = data['nfca']?['identifier'];
    } else if (data['nfcv']?['identifier'] != null) {
      type = 'nfcv';
      id = data['nfcv']?['identifier'];
    } else if (data['nfcb']?['identifier'] != null) {
      type = 'nfcb';
      id = data['nfcb']?['identifier'];
    } else if (data['nfcf']?['identifier'] != null) {
      type = 'nfcf';
      id = data['nfcf']?['identifier'];
    } else if (data['mifareultralight']?['identifier'] != null) {
      type = 'ultralight';
      id = data['mifareultralight']?['identifier'];
    } else if (data['mifareclassic']?['identifier'] != null) {
      type = 'classic';
      id = data['mifareclassic']?['identifier'];
    } else if (data['ndef']?['identifier'] != null) {
      type = 'ndef';
      id = data['ndef']?['identifier'];
    } else if (data['isodep']?['identifier'] != null) {
      type = 'isodep';
      id = data['isodep']?['identifier'];
    }

    if (id == null || type == null) return null;

    final uid = id.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':');

    return '$type:$uid';
  }
}
