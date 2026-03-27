import 'dart:convert';

import 'package:bambuscanner/classes/spool.dart';
import 'package:http/http.dart' as http;

String bambuddyurl = "http://192.168.125.100:8076";
String apiurl = "/api/v1";
String xapikey = "bb_YimOj_xLFFdv5fzc_2UKcimwi8KUiTRceCkuRjRopiw";
Map<String, String> headers = {'X-API-Key': xapikey};

void test() async {}

Future<Spool> getSpoolById(id) async {
  http.Response res = await _apiReq("/inventory/spools/$id");
  Spool spool = Spool.fromJson(jsonDecode(res.body));
  return spool;
}

Future<http.Response> _apiReq(String apiEndpoint) async {
  http.Response res = await http.get(
    Uri.parse(bambuddyurl + apiurl + apiEndpoint),
    headers: headers,
  );
  return res;
}
