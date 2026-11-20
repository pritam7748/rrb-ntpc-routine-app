import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/routine_item.dart';
import '../models/study_log.dart';

class StorageService {
  static const _keyRoutines = 'user_routines_v1';
  static const _keyStudyLogs = 'user_study_logs_v1';
  static const _keyUserPin = 'user_security_pin';
  static const _keyBiometricEnabled = 'is_biometric_enabled';
  static const _keySecurityEnabled = 'is_security_enabled';
  static const _keyStreakCount = 'rrb_study_streak';
  static const _keyLastStudyDate = 'rrb_last_study_date';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Seed default routines if first time
    if (!_prefs.containsKey(_keyRoutines)) {
      await _seedDefaultRoutines();
    }
  }

  // --- ROUTINES ---
  static List<RoutineItem> getRoutines() {
    final raw = _prefs.getString(_keyRoutines);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((item) => RoutineItem.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveRoutines(List<RoutineItem> list) async {
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyRoutines, raw);
  }

  static Future<void> addRoutine(RoutineItem item) async {
    final list = getRoutines();
    list.add(item);
    await saveRoutines(list);
  }

  static Future<void> updateRoutine(RoutineItem item) async {
    final list = getRoutines();
    final idx = list.indexWhere((e) => e.id == item.id);
    if (idx != -1) {
      list[idx] = item;
      await saveRoutines(list);
    }
  }

  static Future<void> deleteRoutine(String id) async {
    final list = getRoutines();
    list.removeWhere((e) => e.id == id);
    await saveRoutines(list);
  }

  static Future<void> _seedDefaultRoutines() async {
    final uuid = const Uuid();
    final defaultList = [
      RoutineItem(
        id: uuid.v4(),
        title: 'Morning Current Affairs & GS Revision',
        category: 'General Awareness',
        hour: 6,
        minute: 30,
        repeatDays: [1, 2, 3, 4, 5, 6, 7],
        isPersistentAlarm: true,
        colorHex: 0xFF06B6D4,
      ),
      RoutineItem(
        id: uuid.v4(),
        title: 'Quantitative Aptitude (Maths Formula & Practice)',
        category: 'Mathematics',
        hour: 9,
        minute: 30,
        repeatDays: [1, 2, 3, 4, 5, 6],
        isPersistentAlarm: true,
        colorHex: 0xFF6366F1,
      ),
      RoutineItem(
        id: uuid.v4(),
        title: 'General Intelligence & Reasoning Puzzles',
        category: 'Reasoning',
        hour: 15,
        minute: 0,
        repeatDays: [1, 2, 3, 4, 5, 6],
        isPersistentAlarm: true,
        colorHex: 0xFFF59E0B,
      ),
      RoutineItem(
        id: uuid.v4(),
        title: 'RRB NTPC CBT-1 Full Mock Test & Analysis',
        category: 'Mock Test',
        hour: 20,
        minute: 0,
        repeatDays: [1, 2, 3, 4, 5, 6, 7],
        isPersistentAlarm: true,
        colorHex: 0xFFEF4444,
      ),
    ];
    await saveRoutines(defaultList);
  }

  // --- STUDY LOGS ---
  static List<StudyLog> getStudyLogs() {
    final raw = _prefs.getString(_keyStudyLogs);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List decoded = jsonDecode(raw);
      final list = decoded.map((item) => StudyLog.fromJson(item)).toList();
      // sort latest first
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveStudyLogs(List<StudyLog> list) async {
    final raw = jsonEncode(list.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyStudyLogs, raw);
  }

  static Future<void> addStudyLog(StudyLog log) async {
    final list = getStudyLogs();
    list.insert(0, log);
    await saveStudyLogs(list);
    await _updateStreak();
  }

  static Future<void> deleteStudyLog(String id) async {
    final list = getStudyLogs();
    list.removeWhere((e) => e.id == id);
    await saveStudyLogs(list);
  }

  // --- STREAK TRACKER ---
  static int getStreakCount() {
    return _prefs.getInt(_keyStreakCount) ?? 0;
  }

  static Future<void> _updateStreak() async {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final lastDateStr = _prefs.getString(_keyLastStudyDate);

    if (lastDateStr == null) {
      await _prefs.setInt(_keyStreakCount, 1);
      await _prefs.setString(_keyLastStudyDate, todayStr);
    } else if (lastDateStr != todayStr) {
      final lastDate = DateTime.parse(lastDateStr);
      final diff = DateTime.now().difference(lastDate).inDays;
      if (diff == 1) {
        final current = _prefs.getInt(_keyStreakCount) ?? 0;
        await _prefs.setInt(_keyStreakCount, current + 1);
      } else if (diff > 1) {
        await _prefs.setInt(_keyStreakCount, 1);
      }
      await _prefs.setString(_keyLastStudyDate, todayStr);
    }
  }

  // --- SECURITY PIN & BIOMETRICS ---
  static String? getUserPin() {
    return _prefs.getString(_keyUserPin);
  }

  static Future<void> setUserPin(String pin) async {
    await _prefs.setString(_keyUserPin, pin);
    await setSecurityEnabled(true);
  }

  static bool isSecurityEnabled() {
    return _prefs.getBool(_keySecurityEnabled) ?? false;
  }

  static Future<void> setSecurityEnabled(bool enabled) async {
    await _prefs.setBool(_keySecurityEnabled, enabled);
  }

  static bool isBiometricEnabled() {
    return _prefs.getBool(_keyBiometricEnabled) ?? true;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_keyBiometricEnabled, enabled);
  }
}
