import 'dart:convert';
import 'package:bambuscanner/classes/ams_spool.dart';
import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/services/globals.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:http/http.dart' as http;

Map<String, String> headers = {'X-API-Key': StorageService().xapitoken};

Future<Spool> getSpoolById(id) async {
  http.Response res = await apiReq("/inventory/spools/$id");
  Spool spool = Spool.fromJson(jsonDecode(res.body));
  return spool;
}

Future<bool> setSlotToSpoolId(
  String printerid,
  String amsid,
  String trayid,
  String spoolid,
) async {
  final res = await apiPost("/inventory/assignments", {
    "spool_id": int.parse(spoolid),
    "printer_id": int.parse(printerid),
    "ams_id": int.parse(amsid),
    "tray_id": int.parse(trayid),
  });
  final Map<String, dynamic> json = jsonDecode(res.body);
  bool configured = json["configured"];
  return configured;
}

Future<List<AmsSpool>> getAllFilamentMappings() async {
  final res = await apiReq("/inventory/assignments");
  final List<dynamic> data = jsonDecode(res.body);
  return data.map((e) => AmsSpool.fromJson(e as Map<String, dynamic>)).toList();
}

Future<http.Response> apiReq(String apiEndpoint) async {
  http.Response res = await http.get(
    Uri.parse(
      StorageService().bambuddyUrl + Globals.apinamespace + apiEndpoint,
    ),
    headers: headers,
  );
  return res;
}

Future<http.Response> apiPost(
  String apiEndpoint,
  Map<String, dynamic> data,
) async {
  http.Response res = await http.post(
    Uri.parse(
      StorageService().bambuddyUrl! + Globals.apinamespace + apiEndpoint,
    ),
    headers: {...headers, 'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );

  return res;
}
