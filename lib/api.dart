import 'dart:convert';
import 'package:bambuscanner/classes/spool.dart';
import 'package:http/http.dart' as http;

String bambuddyurl = "http://192.168.125.100:8076";
String apiurl = "/api/v1";
String xapikey = "bb_YimOj_xLFFdv5fzc_2UKcimwi8KUiTRceCkuRjRopiw";
Map<String, String> headers = {'X-API-Key': xapikey};

void test() async {}

Future<Spool> getSpoolById(id) async {
  http.Response res = await apiReq("/inventory/spools/$id");
  Spool spool = Spool.fromJson(jsonDecode(res.body));
  return spool;
}

Future<void> setSlotToSpoolId(
  String printerid,
  String amsid,
  String trayid,
  String spoolid,
) async {
  await apiPost("/inventory/assignments", {
    "spool_id": int.parse(spoolid),
    "printer_id": int.parse(printerid),
    "ams_id": int.parse(amsid),
    "tray_id": int.parse(trayid),
  });
}

Future<http.Response> apiReq(String apiEndpoint) async {
  http.Response res = await http.get(
    Uri.parse(bambuddyurl + apiurl + apiEndpoint),
    headers: headers,
  );
  print(res.body);
  return res;
}

Future<http.Response> apiPost(
  String apiEndpoint,
  Map<String, dynamic> data,
) async {
  http.Response res = await http.post(
    Uri.parse(bambuddyurl + apiurl + apiEndpoint),
    headers: {...headers, 'Content-Type': 'application/json'},
    body: jsonEncode(data),
  );

  print(res.body);
  return res;
}
