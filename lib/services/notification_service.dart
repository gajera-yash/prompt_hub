import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prompt_model.dart';
import 'local_storage_service.dart';

class Time {
  final int hour;
  final int minute;
  final int second;
  const Time(this.hour, this.minute, this.second);
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  factory NotificationService() {
    return instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? selectedNotificationPayload;
  void Function(String payload)? onNotificationClick;

  Future<void> init() async {
    await _configureLocalTimeZone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        if (notificationResponse.payload != null) {
          selectedNotificationPayload = notificationResponse.payload;
          if (onNotificationClick != null) {
            onNotificationClick!(notificationResponse.payload!);
          }
        }
      },
    );
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('America/Detroit')); // Fallback
    }
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  Future<void> scheduleDailyPrompts(List<PromptModel> allPrompts) async {
    if (allPrompts.isEmpty) return;

    // Cancel previously scheduled daily prompts to avoid duplicates
    await flutterLocalNotificationsPlugin.cancelAll();

    final random = Random();
    
    // We will schedule 3 notifications per day at specific times
    final scheduleTimes = [
      const Time(10, 0, 0), // 10:00 AM
      const Time(12, 0, 0), // 12:00 PM
      const Time(15, 0, 0), // 3:00 PM
      const Time(16, 0, 0), // 4:00 PM 
      const Time(18, 0, 0), // 6:00 PM 
      const Time(20, 0, 0), // 8:00 PM 
    ];

    // Pick random prompts
    final selectedPrompts = <PromptModel>[];
    for (int i = 0; i < scheduleTimes.length; i++) {
      selectedPrompts.add(allPrompts[random.nextInt(allPrompts.length)]);
    }

    final now = tz.TZDateTime.now(tz.local);
    final scheduledNotifications = <Map<String, dynamic>>[];

    for (int i = 0; i < scheduleTimes.length; i++) {
      final time = scheduleTimes[i];
      final prompt = selectedPrompts[i];
      
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // If time has passed for today, schedule it for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      scheduledNotifications.add({
        'id': prompt.id,
        'time': scheduledDate.millisecondsSinceEpoch,
      });

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: i,
        title: '🔥 Prompt of the Day',
        body: 'Try this ${prompt.aiTool} prompt: ${prompt.title}',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_prompts_channel',
            'Daily Prompts',
            channelDescription: 'Daily AI prompt recommendations',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            presentBanner: true,
            presentList: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: prompt.id,
      );
    }

    try {
      final storage = await LocalStorageService.getInstance();
      await storage.saveScheduledNotificationsJson(scheduledNotifications);
    } catch (e) {
      debugPrint('Error saving notifications json: $e');
    }
  }
  Future<void> scheduleDailyTrendingPhotos(List<PromptModel> trendingPhotos) async {
    if (trendingPhotos.isEmpty) return;

    final random = Random();

    // Photo notification times - different from prompt times to spread throughout the day
    final photoTimes = [
      const Time(9, 0, 0),  // 9:00 AM
      const Time(13, 0, 0), // 1:00 PM
      const Time(17, 0, 0), // 5:00 PM
      const Time(21, 0, 0), // 9:00 PM
    ];

    final photoMessages = [
      '🎨 Create stunning AI art today!',
      '🖼️ Turn your imagination into reality',
      '✨ New trending photo prompts await you',
      '🌟 Create beautiful AI images tonight',
    ];

    final now = tz.TZDateTime.now(tz.local);

    // Use IDs starting at 100 to avoid conflict with prompt notifications (0-5)
    for (int i = 0; i < photoTimes.length; i++) {
      final time = photoTimes[i];
      final photo = trendingPhotos[random.nextInt(trendingPhotos.length)];

      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 100 + i,
        title: photoMessages[i],
        body: '📸 "${photo.title}" — Tap to see the prompt & recreate it!',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'trending_photos_channel',
            'Trending Photo Prompts',
            channelDescription: 'Daily trending AI image prompt notifications',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            presentBanner: true,
            presentList: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: photo.id,
      );
    }
  }
}
