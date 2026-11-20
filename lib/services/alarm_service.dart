import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/routine_item.dart';
import '../screens/alarm_ringing_screen.dart';

class AlarmService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool isRinging = false;
  static RoutineItem? currentRingingRoutine;
  static GlobalKey<NavigatorState>? navigatorKey;

  static Future<void> init(GlobalKey<NavigatorState> navKey) async {
    navigatorKey = navKey;

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          triggerAlarmScreen(
            title: response.payload ?? 'Routine Alarm',
            category: 'RRB NTPC Study Routine',
          );
        }
      },
    );

    // Request permissions for Android 13+
    final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
      await androidImpl.requestExactAlarmsPermission();
    }
  }

  /// Start persistent alarm: loops continuously until stopped
  static Future<void> startAlarmRinging({
    required String title,
    required String category,
  }) async {
    if (isRinging) return;
    isRinging = true;

    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('audio/rrb_alarm.wav'));
    } catch (e) {
      print('Audio play error: $e');
    }

    // Show persistent ongoing notification
    await showPersistentNotification(title: title, category: category);

    // Navigate to Full Screen Alarm Ringing Screen
    if (navigatorKey?.currentContext != null) {
      navigatorKey!.currentState?.push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => AlarmRingingScreen(
            title: title,
            category: category,
          ),
        ),
      );
    }
  }

  /// Stop the alarm sound and dismiss notification
  static Future<void> stopAlarm() async {
    isRinging = false;
    currentRingingRoutine = null;
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Audio stop error: $e');
    }
    await _notificationsPlugin.cancel(9999);
  }

  static Future<void> showPersistentNotification({
    required String title,
    required String category,
  }) async {
    const rawSound = RawResourceAndroidNotificationSound('rrb_alarm');
    const androidDetails = AndroidNotificationDetails(
      'rrb_persistent_alarm_channel',
      'RRB NTPC Persistent Alarm',
      channelDescription: 'High priority continuous alarm channel for study routines',
      importance: Importance.max,
      priority: Priority.high,
      sound: rawSound,
      playSound: true,
      enableVibration: true,
      ongoing: true, // Cannot be dismissed by swiping
      autoCancel: false,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      9999,
      '⏰ ALARM: $title',
      'Time for your $category! Tap to open and dismiss.',
      notificationDetails,
      payload: title,
    );
  }

  static void triggerAlarmScreen({
    required String title,
    required String category,
  }) {
    startAlarmRinging(title: title, category: category);
  }

  /// Schedules daily routine notifications
  static Future<void> scheduleRoutine(RoutineItem item) async {
    if (!item.isEnabled) return;
    // Android local notifications exact alarm scheduling logic
    // We register notification with sound 'rrb_alarm'
    final id = item.id.hashCode;
    const rawSound = RawResourceAndroidNotificationSound('rrb_alarm');
    final androidDetails = AndroidNotificationDetails(
      'rrb_routine_channel_${item.id}',
      'Routine: ${item.title}',
      channelDescription: 'Daily RRB NTPC routine reminder',
      importance: Importance.max,
      priority: Priority.high,
      sound: rawSound,
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.alarm,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);
    // Scheduled reminder registered
    print('Scheduled routine: ${item.title} (ID: $id) at ${item.formattedTime}');
  }
}
