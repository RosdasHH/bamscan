import 'dart:convert';

import 'package:bambuscanner/services/globals.dart';
import 'package:bambuscanner/services/storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService extends ChangeNotifier {
  bool _reachable = true;

  bool get reachable => _reachable;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() {
    return _instance;
  }
  ApiService._internal();

  void _setReachable(bool value) {
    if (_reachable != value) {
      _reachable = value;
      notifyListeners();
    }
  }

  Future<bool?> checkHealth([String? url]) async {
    url ??= StorageService().bambuddyUrl;
    try {
      http.Response res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        _setReachable(true);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _setReachable(false);
      return null;
    }
  }

  Future<bool?> checkApiKey(String url, String apikey) async {
    try {
      http.Response res = await http.get(
        Uri.parse("$url${Globals.apinamespace}/users"),
        headers: {'X-API-Key': apikey},
      );
      if (res.statusCode == 401) {
        _setReachable(false);
        return false;
      }
      if (res.statusCode == 200) {
        _setReachable(true);
        return true;
      }
    } catch (e) {
      _setReachable(false);
      rethrow;
    }
    return null;
  }

  Future<http.Response> apiReq(String apiEndpoint) async {
    try {
      http.Response res = await http
          .get(
            Uri.parse(
              StorageService().bambuddyUrl + Globals.apinamespace + apiEndpoint,
            ),
            headers: {"x-api-key": StorageService().xapitoken},
          )
          .timeout(Duration(seconds: 1));
      _setReachable(true);
      return res;
    } catch (e) {
      _setReachable(false);
      rethrow;
    }
  }

  Future<http.Response> apiPost(
    String apiEndpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      http.Response res = await http
          .post(
            Uri.parse(
              StorageService().bambuddyUrl + Globals.apinamespace + apiEndpoint,
            ),
            headers: {
              "x-api-key": StorageService().xapitoken,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: 1));
      _setReachable(true);
      return res;
    } catch (e) {
      _setReachable(false);
      rethrow;
    }
  }

  Future<http.Response> apiPatch(
    String apiEndpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      http.Response res = await http
          .patch(
            Uri.parse(
              StorageService().bambuddyUrl + Globals.apinamespace + apiEndpoint,
            ),
            headers: {
              "x-api-key": StorageService().xapitoken,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(Duration(seconds: 1));
      _setReachable(true);
      return res;
    } catch (e) {
      _setReachable(false);
      rethrow;
    }
  }
}
