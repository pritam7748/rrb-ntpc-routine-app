import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/routine_item.dart';
import '../screens/alarm_ringing_screen.dart';
import 'storage_service.dart';

class AlarmService {
  static GlobalKey<NavigatorState>? navigatorKey;
  static StreamSubscription<AlarmSettings>? _ringSubscription;

  static Future<void> init(GlobalKey<NavigatorState> navKey) async {
    navigatorKey = navKey;

    // Initialize native alarm clock engine
    await Alarm.init();

    // Check & request permissions on start
    await requestPermissions();

    // Listen to ringing alarms from background service
    _ringSubscription?.cancel();
    _ringSubscription = Alarm.ringStream.stream.listen((alarmSettings) {
      _handleAlarmRing(alarmSettings);
    });

    // Schedule all enabled routines on app launch
    await rescheduleAllRoutines();
  }

  static Future<void> requestPermissions() async {
    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } catch (e) {
      print('Permission request error: $e');
    }
  }

  static int getAlarmId(String routineId) {
    return (routineId.hashCode.abs() % 100000) + 1;
  }

  static DateTime getNextDateTime(int hour, int minute, List<int> repeatDays) {
    final now = DateTime.now();
    DateTime candidate = DateTime(now.year, now.month, now.day, hour, minute);

    if (candidate.isBefore(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    if (repeatDays.isNotEmpty && repeatDays.length < 7) {
      while (!repeatDays.contains(candidate.weekday)) {
        candidate = candidate.add(const Duration(days: 1));
      }
    }

    return candidate;
  }

  static Future<void> scheduleRoutine(RoutineItem item) async {
    if (!item.isEnabled) {
      await cancelRoutine(item);
      return;
    }

    final nextTime = getNextDateTime(item.hour, item.minute, item.repeatDays);
    final alarmId = getAlarmId(item.id);

    // Cancel old alarm with this ID
    await Alarm.stop(alarmId);

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: nextTime,
      assetAudioPath: 'assets/audio/rrb_alarm.wav',
      loopAudio: item.isPersistentAlarm,
      vibrate: true,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fixed(
        volume: 1.0,
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: '⏰ RRB NTPC: ${item.title}',
        body: 'Time for ${item.category}! Tap to dismiss.',
        stopButton: 'Dismiss',
        icon: 'ic_launcher',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    print('Scheduled alarm $alarmId for ${item.title} at $nextTime');
  }

  static Future<void> cancelRoutine(RoutineItem item) async {
    final alarmId = getAlarmId(item.id);
    await Alarm.stop(alarmId);
    print('Cancelled alarm $alarmId for ${item.title}');
  }

  static Future<void> rescheduleAllRoutines() async {
    final routines = StorageService.getRoutines();
    for (final r in routines) {
      if (r.isEnabled) {
        await scheduleRoutine(r);
      }
    }
  }

  static void _handleAlarmRing(AlarmSettings alarmSettings) {
    final routines = StorageService.getRoutines();
    RoutineItem? matchedItem;
    for (final r in routines) {
      if (getAlarmId(r.id) == alarmSettings.id) {
        matchedItem = r;
        break;
      }
    }

    final title = matchedItem?.title ?? 'Study Routine Alarm';
    final category = matchedItem?.category ?? 'RRB NTPC Routine';

    // Reschedule next occurrence for tomorrow / next repeat day
    if (matchedItem != null && matchedItem.isEnabled) {
      scheduleRoutine(matchedItem);
    }

    // Open Alarm Ringing Screen
    if (navigatorKey?.currentContext != null) {
      navigatorKey!.currentState?.push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => AlarmRingingScreen(
            title: title,
            category: category,
            alarmId: alarmSettings.id,
          ),
        ),
      );
    }
  }

  static Future<void> stopAlarm([int? id]) async {
    if (id != null) {
      await Alarm.stop(id);
    } else {
      final alarms = await Alarm.getAlarms();
      for (final a in alarms) {
        if (await Alarm.isRinging(a.id)) {
          await Alarm.stop(a.id);
        }
      }
    }
  }

  /// Test alarm: schedules an alarm X seconds from now
  /// Test alarm: schedules an alarm X seconds from now
  static Future<void> testAlarmAfterSeconds(int seconds, {String? title, String? category}) async {
    const testId = 99999;
    await Alarm.stop(testId);

    final alarmSettings = AlarmSettings(
      id: testId,
      dateTime: DateTime.now().add(Duration(seconds: seconds)),
      assetAudioPath: 'assets/audio/rrb_alarm.wav',
      loopAudio: true,
      vibrate: true,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fixed(
        volume: 1.0,
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: title ?? '⏰ TEST ALARM: RRB NTPC Wake-up',
        body: 'App background test successful! Tap to dismiss.',
        stopButton: 'Dismiss',
        icon: 'ic_launcher',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  /// Trigger alarm ringing immediately
  static Future<void> startAlarmRinging({
    required String title,
    required String category,
  }) async {
    await testAlarmAfterSeconds(1, title: title, category: category);
  }
}
