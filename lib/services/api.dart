import 'dart:convert';
import 'package:bambuscanner/services/globals.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:http/http.dart' as http;

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
