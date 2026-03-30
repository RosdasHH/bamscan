import 'dart:convert';
import 'package:bambuscanner/classes/ams_spool.dart';
import 'package:bambuscanner/classes/spool.dart';
import 'package:bambuscanner/services/globals.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:http/http.dart' as http;

Future<Spool> getSpoolById(id) async {
  http.Response res = await apiReq("/inventory/spools/$id");
  Spool spool = Spool.fromJson(jsonDecode(res.body));
  return spool;
}

Future<bool?> checkHealth(String url) async {
  try {
    http.Response res = await http.get(Uri.parse(url));
    return res.statusCode == 200;
  } catch (e) {
    return null;
  }
}

Future<bool?> checkApiKey(String url, String apikey) async {
  try {
    http.Response res = await http.get(
      Uri.parse("$url${Globals.apinamespace}/users"),
      headers: {'X-API-Key': apikey},
    );
    if (res.statusCode == 401) return false;
    if (res.statusCode == 200) return true;
  } catch (e) {}
  return null;
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

Future<bool> patchSpool(String id, String note) async {
  final res = await apiPatch("/inventory/spools/$id", {"note": note});
  return res.statusCode == 200;
}

Future<List<Spool>> getAllSpools() async {
  final res = await apiReq("/inventory/spools");
  final List<dynamic> data = jsonDecode(res.body);
  return data.map((e) => Spool.fromJson(e as Map<String, dynamic>)).toList();
}

Future<List<AmsSpool>> getAllFilamentMappings() async {
  final res = await apiReq("/inventory/assignments");
  final List<dynamic> data = jsonDecode(res.body);
  return data.map((e) => AmsSpool.fromJson(e as Map<String, dynamic>)).toList();
}

Future<List<AmsSpool>> getFilamentMappingForPrinter(int printerId) async {
  final res = await apiReq("/inventory/assignments?printer_id=$printerId");
  final List<dynamic> data = jsonDecode(res.body);
  return data.map((e) => AmsSpool.fromJson(e as Map<String, dynamic>)).toList();
}

Future<http.Response> apiReq(String apiEndpoint) async {
  http.Response res = await http.get(
    Uri.parse(
      StorageService().bambuddyUrl + Globals.apinamespace + apiEndpoint,
    ),
    headers: {"x-api-key": StorageService().xapitoken},
  );
  return res;
}

Future<http.Response> apiPost(
  String apiEndpoint,
  Map<String, dynamic> data,
) async {
  http.Response res = await http.post(
    Uri.parse(
      StorageService().bambuddyUrl + Globals.apinamespace + apiEndpoint,
    ),
    headers: {
      "x-api-key": StorageService().xapitoken,
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  return res;
}

Future<http.Response> apiPatch(
  String apiEndpoint,
  Map<String, dynamic> data,
) async {
  http.Response res = await http.patch(
    Uri.parse(
      StorageService().bambuddyUrl + Globals.apinamespace + apiEndpoint,
    ),
    headers: {
      "x-api-key": StorageService().xapitoken,
      'Content-Type': 'application/json',
    },
    body: jsonEncode(data),
  );

  return res;
}
