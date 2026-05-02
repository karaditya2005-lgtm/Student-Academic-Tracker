// lib/services/auth_service.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_app/screens/performance_model.dart';
import 'package:student_app/screens/user_model.dart' show UserModel;
import 'package:uuid/uuid.dart';

class AuthService {
  static const _usersKey = 'registered_users';
  static const _currentUserKey = 'current_user';
  static const _performancePrefix = 'performance_';
  static const _chatHistoryPrefix = 'chat_history_';

  static final _uuid = Uuid();

  // ── Registration ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String studentClass,
    required String rollNumber,
    required String school,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final users = await _getAllUsers(prefs);
    if (users.any((u) => u['email'] == email)) {
      return {'success': false, 'message': 'Email already registered.'};
    }

    final uid = 'STU-${_uuid.v4().substring(0, 8).toUpperCase()}';
    final initials =
        name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join();

    final user = UserModel(
      uid: uid,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      studentClass: studentClass,
      rollNumber: rollNumber,
      school: school,
      avatarInitials: initials,
      registeredAt: DateTime.now(),
    );

    users.add({...user.toJson(), 'password': password});
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));

    return {'success': true, 'user': user};
  }

  // ── Login with email + password ───────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getAllUsers(prefs);

    final match = users.where((u) =>
        u['email'] == email.trim().toLowerCase() && u['password'] == password);

    if (match.isEmpty) {
      return {'success': false, 'message': 'Invalid email or password.'};
    }

    final userData = Map<String, dynamic>.from(match.first)..remove('password');
    final user = UserModel.fromJson(userData);
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    return {'success': true, 'user': user};
  }

  // ── Login with UID ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> loginWithUID(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await _getAllUsers(prefs);

    final match = users.where((u) => u['uid'] == uid.trim().toUpperCase());

    if (match.isEmpty) {
      return {'success': false, 'message': 'No student found with this UID.'};
    }

    final userData = Map<String, dynamic>.from(match.first)..remove('password');
    final user = UserModel.fromJson(userData);
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    return {'success': true, 'user': user};
  }

  // ── Current user ──────────────────────────────────────────────────────────
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentUserKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // ── Performance ───────────────────────────────────────────────────────────
  static Future<void> savePerformance(String uid, PerformanceData data) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_performancePrefix$uid';
    final existing = await getPerformanceHistory(uid);
    existing.add(data);
    // Keep last 10 records
    final trimmed = existing.length > 10
        ? existing.sublist(existing.length - 10)
        : existing;
    await prefs.setString(
        key, jsonEncode(trimmed.map((e) => e.toJson()).toList()));
  }

  static Future<List<PerformanceData>> getPerformanceHistory(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_performancePrefix$uid';
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => PerformanceData.fromJson(e)).toList();
  }

  // ── Chat history ──────────────────────────────────────────────────────────
  static Future<List<Map<String, String>>> getChatHistory(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_chatHistoryPrefix$uid');
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, String>.from(e))
        .toList();
  }

  static Future<void> saveChatHistory(
      String uid, List<Map<String, String>> history) async {
    final prefs = await SharedPreferences.getInstance();
    // Keep last 50 messages
    final trimmed =
        history.length > 50 ? history.sublist(history.length - 50) : history;
    await prefs.setString('$_chatHistoryPrefix$uid', jsonEncode(trimmed));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> _getAllUsers(
      SharedPreferences prefs) async {
    final raw = prefs.getString(_usersKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
