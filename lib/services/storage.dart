import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends ChangeNotifier {
  static final _secureStorage = FlutterSecureStorage();

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  String _bambuddyUrl = "";
  String _xapitoken = "";
  String get bambuddyUrl => _bambuddyUrl;
  String get xapitoken => _xapitoken;

  Future<void> loadFromStorage() async {
    _bambuddyUrl = await getBambuddyUrl();
    _xapitoken = await getToken();
    notifyListeners();
  }

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
  }

  static Future<String> getToken() async {
    return await _secureStorage.read(key: 'token') ?? "";
  }

  //static Future<void> deleteToken() async {
  //  await _secureStorage.delete(key: 'token');
  //}

  static Future<void> setBambuddyUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("bambuddyUrl", url);
  }

  static Future<String> getBambuddyUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("bambuddyUrl") ?? "";
  }
}
