import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/provider/available_filaments.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

String? parseQrCodeFromString(String string) {
  final qrRegex = RegExp(r'\[QR-CODE\]=>\[(.*?)\]');
  return qrRegex.firstMatch(string)?.group(1);
}

String deleteQrCodeFromString(String string) {
  return string.replaceAll(RegExp(r'\[QR-CODE\]=>\[.*?\]\n'), '');
}

String addQrCodeToString(String string, String id) {
  return "[QR-CODE]=>[$id]\n$string";
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
  bool success = await availableFilaments.patchSpool(
    spool.id.toString(),
    newNotes,
  );
  return success;
}

Future<bool> deleteQrCodeReq(BuildContext context, Spool spool) async {
  final availableFilaments = context.read<AvailableFilaments>();
  final newNotes = deleteQrCodeFromString(spool.note.toString());
  bool success = await availableFilaments.patchSpool(
    spool.id.toString(),
    newNotes,
  );
  return success;
}
