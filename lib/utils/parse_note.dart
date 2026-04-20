import 'package:bamscan/classes/spool.dart';
import 'package:bamscan/provider/available_filaments.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

String? parseQrCodeFromString(String string) {
  final qrRegex = RegExp(r'\[QR-CODE\]=>\[(.*?)\]');
  return qrRegex.firstMatch(string)?.group(1);
}

String deleteQrCodeFromString(String string) {
  String newString = string.replaceAll(RegExp(r'\[QR-CODE\]=>\[.*?\]\n?'), '');
  return newString;
}

String addQrCodeToString(String string, String id) {
  return "[QR-CODE]=>[$id]\n$string";
}

String? parseNfcIdentifierFromString(String string) {
  final qrRegex = RegExp(r'\[NFC-ID\]=>\[(.*?)\]');
  return qrRegex.firstMatch(string)?.group(1);
}

String deleteNfcIdentifierFromString(String string) {
  String newString = string.replaceAll(RegExp(r'\[NFC-ID\]=>\[.*?\]\n?'), '');
  return newString;
}

String addNfcIdentifierToString(String string, String id) {
  return "[NFC-ID]=>[$id]\n$string";
}

Future<bool> addQrCodeReq(
  BuildContext context,
  Spool spool,
  String? qrid,
) async {
  final availableFilaments = context.read<AvailableFilaments>();
  String newNotes = spool.note ?? "";
  if (qrid != null) {
    newNotes = deleteQrCodeFromString(newNotes);
  }
  newNotes = addQrCodeToString(newNotes, qrid!);
  bool success = await availableFilaments.patchSpool(spool.id.toString(), {
    "note": newNotes,
  });
  return success;
}

Future<bool> deleteQrCodeReq(BuildContext context, Spool spool) async {
  final availableFilaments = context.read<AvailableFilaments>();
  await availableFilaments.getAllSpools();
  final newNotes = deleteQrCodeFromString(spool.note.toString());
  bool success = await availableFilaments.patchSpool(spool.id.toString(), {
    "note": newNotes,
  });
  return success;
}
Future<bool> addNfcIdReq(
  BuildContext context,
  Spool spool,
  String? nfcid,
) async {
  final availableFilaments = context.read<AvailableFilaments>();
  String newNotes = spool.note ?? "";
  if (nfcid != null) {
    newNotes = deleteNfcIdentifierFromString(newNotes);
  }
  newNotes = addNfcIdentifierToString(newNotes, nfcid!);
  bool success = await availableFilaments.patchSpool(spool.id.toString(), {
    "note": newNotes,
  });
  return success;
}

Future<bool> deleteNfcReq(BuildContext context, Spool spool) async {
  final availableFilaments = context.read<AvailableFilaments>();
  await availableFilaments.getAllSpools();
  final newNotes = deleteNfcIdentifierFromString(spool.note.toString());
  bool success = await availableFilaments.patchSpool(spool.id.toString(), {
    "note": newNotes,
  });
  return success;
}
