import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class AuthStorage {
  static const String _tokenKey = 'github_token';
  static const String _userKey = 'github_user';

  static void saveToken(String token) {
    _storeString(_tokenKey, token);
    print('✅ Token 已保存');
  }

  static String? getToken() {
    return _getString(_tokenKey);
  }

  static void clearToken() {
    _removeString(_tokenKey);
    print('🗑️ Token 已清除');
  }

  static void saveUserInfo(Map<String, dynamic> userInfo) {
    _storeString(_userKey, json.encode(userInfo));
    print('✅ 用户信息已保存');
  }

  static Map<String, dynamic>? getUserInfo() {
    final userStr = _getString(_userKey);
    if (userStr == null) return null;
    return json.decode(userStr);
  }

  static void clearUserInfo() {
    _removeString(_userKey);
    print('🗑️ 用户信息已清除');
  }

  static bool isAuthenticated() {
    return _getString(_tokenKey) != null;
  }

  static void _storeString(String key, String value) {
    html.window.localStorage[key] = value;
  }

  static String? _getString(String key) {
    return html.window.localStorage[key];
  }

  static void _removeString(String key) {
    html.window.localStorage.remove(key);
  }
}
