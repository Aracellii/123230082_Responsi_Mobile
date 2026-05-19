import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyLoggedIn = 'is_logged_in';
  static const _keyUsername = 'username';
  static const _keyPassword = 'password_hash';

  static final ValueNotifier<String?> _activeUser = ValueNotifier<String?>(
    null,
  );

  static ValueListenable<String?> activeUserListenable() => _activeUser;

  static String _hash(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  /// Register a single account. If an account already exists and [overwrite]
  /// is false, registration fails and returns false.
  static Future<bool> register(
    String username,
    String password, {
    bool overwrite = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keyUsername);

    if (existing != null && !overwrite) {
      return false;
    }

    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyPassword, _hash(password));
    return true;
  }

  /// Returns whether an account has been registered
  static Future<bool> hasAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_keyUsername);
    final passwordHash = prefs.getString(_keyPassword);
    return username != null &&
        username.isNotEmpty &&
        passwordHash != null &&
        passwordHash.isNotEmpty;
  }

  /// Returns whether the stored account matches [username]
  static Future<bool> hasAccountFor(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString(_keyUsername);
    final storedHash = prefs.getString(_keyPassword);
    if (storedUser == null || storedHash == null) return false;
    if (storedUser.isEmpty || storedHash.isEmpty) return false;
    return storedUser == username;
  }

  /// Validate provided credentials against stored account
  static Future<bool> validateCredentials(
    String username,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString(_keyUsername);
    final storedHash = prefs.getString(_keyPassword);
    if (storedUser == null || storedHash == null) return false;
    if (storedUser != username) return false;
    return storedHash == _hash(password);
  }

  /// Saves login state and username to SharedPreferences
  static Future<void> login(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyUsername, username);
    _activeUser.value = username;
  }

  /// Clears stored login state
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    // keep registered account intact; only remove login flag
    _activeUser.value = null;
  }

  /// Returns whether user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  /// Returns stored username or null
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<String?> syncActiveUser() async {
    final loggedIn = await isLoggedIn();
    if (!loggedIn) {
      _activeUser.value = null;
      return null;
    }

    final username = await getUsername();
    if (username == null || username.isEmpty) {
      _activeUser.value = null;
      return null;
    }

    _activeUser.value = username;
    return username;
  }
}
