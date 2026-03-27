import 'package:http/http.dart' as http;

String bambuddyurl = "http://192.168.125.100:8076";
String xapikey = "bb_YimOj_xLFFdv5fzc_2UKcimwi8KUiTRceCkuRjRopiw";
Map<String, String> headers = {'X-API-Key': xapikey};

void test() async {
}

Future<http.Response> getSpoolById(id) async {
  http.Response res = await _apiReq("/api/v1/inventory/spools/$id");
  print(res.body);
  return res;
}

Future<http.Response> _apiReq(String apiEndpoint) async {
  http.Response res = await http.get(
    Uri.parse(bambuddyurl + apiEndpoint),
    headers: headers,
  );
  return res;
}
