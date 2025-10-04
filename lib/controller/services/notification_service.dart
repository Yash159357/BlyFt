import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blyft/utils/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'bookmark_services.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String _reminderEnabledKey = 'bookmark_reminder_enabled';
  static const String _reminderTimeKey = 'bookmark_reminder_time';
  static const int _bookmarkReminderId = 1;

  Future<void> initialize() async {
    if (_isInitialized) {
      Log.d('NOTIFICATION_SERVICE: Service already initialized, skipping');
      return;
    }

    Log.i('NOTIFICATION_SERVICE: Initializing notification service');

    try {
      // Initialize timezone data
      tz.initializeTimeZones();
      Log.d('NOTIFICATION_SERVICE: Timezone data initialized');

      // Set local timezone (you may need to adjust this based on your needs)
      final String timeZoneName = await _getDeviceTimeZone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      Log.d('NOTIFICATION_SERVICE: Local timezone set to $timeZoneName');

      // Android initialization with proper settings
      const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization (if you plan to support iOS)
      const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final bool? initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        _isInitialized = true;
        Log.i('NOTIFICATION_SERVICE: Notification service initialized successfully');

        // Create notification channel for Android
        await _createNotificationChannel();
      } else {
        Log.e('NOTIFICATION_SERVICE: Failed to initialize notification service');
      }
    } catch (e) {
      Log.e('NOTIFICATION_SERVICE: Error initializing notifications', e);
    }
  }

  Future<String> _getDeviceTimeZone() async {
    try {
      // You might want to use a package like device_info_plus to get actual timezone
      // For now, using a common default
      const timezone = 'Asia/Kolkata';
      Log.d('NOTIFICATION_SERVICE: Using timezone: $timezone');
      return timezone;
    } catch (e) {
      Log.w('NOTIFICATION_SERVICE: Failed to get device timezone, using UTC fallback');
      return 'UTC'; // Fallback
    }
  }

  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      Log.d('NOTIFICATION_SERVICE: Creating Android notification channels');

      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      _notifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
      >();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'bookmark_reminder',
            'Bookmark Reminders',
            description: 'Daily reminders to check your bookmarked articles',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
          ),
        );
        Log.d('NOTIFICATION_SERVICE: Created bookmark_reminder channel');

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'test_channel',
            'Test Notifications',
            description: 'Test notification channel',
            importance: Importance.high,
          ),
        );
        Log.d('NOTIFICATION_SERVICE: Created test_channel');
      } else {
        Log.w('NOTIFICATION_SERVICE: Android plugin not available for channel creation');
      }
    } else {
      Log.d('NOTIFICATION_SERVICE: Skipping channel creation for non-Android platform');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to bookmarks screen
    Log.i('NOTIFICATION_SERVICE: Notification tapped - ID: ${response.id}, Payload: ${response.payload}');

    // Log additional response details
    if (response.actionId != null) {
      Log.d('NOTIFICATION_SERVICE: Action ID: ${response.actionId}');
    }
    if (response.input != null) {
      Log.d('NOTIFICATION_SERVICE: User input: ${response.input}');
    }

    // Add your navigation logic here if needed
  }

  Future<bool> requestPermissions() async {
    Log.i('NOTIFICATION_SERVICE: Requesting notification permissions');

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      _notifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
      >();

      if (androidPlugin != null) {
        // Request notification permission (Android 13+)
        final bool? granted =
        await androidPlugin.requestNotificationsPermission();

        // Request exact alarm permission (Android 12+)
        final bool? exactAlarmGranted =
        await androidPlugin.requestExactAlarmsPermission();

        Log.i('NOTIFICATION_SERVICE: Permission request results - Notification: $granted, Exact alarm: $exactAlarmGranted');

        return granted ?? false;
      } else {
        Log.w('NOTIFICATION_SERVICE: Android plugin not available for permission request');
      }
    } else if (Platform.isIOS) {
      final bool? result = await _notifications
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
      >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      Log.i('NOTIFICATION_SERVICE: iOS permission request result: $result');
      return result ?? false;
    }

    Log.d('NOTIFICATION_SERVICE: Permissions granted by default for this platform');
    return true; // For other platforms
  }

  Future<bool> isReminderEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_reminderEnabledKey) ?? false;
      Log.d('NOTIFICATION_SERVICE: Reminder enabled status: $enabled');
      return enabled;
    } catch (e) {
      Log.e('NOTIFICATION_SERVICE: Error getting reminder enabled status', e);
      return false;
    }
  }

  Future<void> setReminderEnabled(bool enabled) async {
    try {
      Log.i('NOTIFICATION_SERVICE: Setting reminder enabled to: $enabled');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reminderEnabledKey, enabled);

      if (enabled) {
        Log.d('NOTIFICATION_SERVICE: Scheduling bookmark reminder');
        await _scheduleBookmarkReminder(true);
      } else {
        Log.d('NOTIFICATION_SERVICE: Cancelling bookmark reminder');
        await _cancelBookmarkReminder();
      }
    } catch (e) {
      Log.e('NOTIFICATION_SERVICE: Error setting reminder enabled', e);
    }
  }

  Future<String> getReminderTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final time = prefs.getString(_reminderTimeKey) ?? '09:00';
      Log.d('NOTIFICATION_SERVICE: Retrieved reminder time: $time');
      return time;
    } catch (e) {
      Log.e('NOTIFICATION_SERVICE: Error getting reminder time', e);
      return '09:00';
    }
  }

  Future<void> setReminderTime(String time) async {
    try {
      Log.i('NOTIFICATION_SERVICE: Setting reminder time to: $time');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_reminderTimeKey, time);

      // Reschedule if reminder is enabled
      if (await isReminderEnabled()) {
        Log.d('NOTIFICATION_SERVICE: Rescheduling reminder with new time');
        await _scheduleBookmarkReminder();
      }
    } catch (e) {
      Log.e('NOTIFICATION_SERVICE: Error setting reminder time', e);
    }
  }

  Future<void> _scheduleBookmarkReminder([bool allowSameDay = false]) async {
    try {
      Log.i('NOTIFICATION_SERVICE: Scheduling bookmark reminder (allowSameDay: $allowSameDay)');

      // Ensure we're initialized
      if (!_isInitialized) {
        Log.d('NOTIFICATION_SERVICE: Service not initialized, initializing now');
        await initialize();
      }

      // Cancel existing reminder first
      await _notifications.cancel(_bookmarkReminderId);
      Log.d('NOTIFICATION_SERVICE: Cancelled existing reminder with ID: $_bookmarkReminderId');

      // Check if user has bookmarks
      final bookmarkService = BookmarkServices();
      final bookmarks = await bookmarkService.getBookmarks();

      if (bookmarks.isEmpty) {
        Log.w('NOTIFICATION_SERVICE: No bookmarks found, skipping reminder scheduling');
        return;
      }

      Log.d('NOTIFICATION_SERVICE: Found ${bookmarks.length} bookmarks, proceeding with scheduling');

      final timeString = await getReminderTime();
      final timeParts = timeString.split(':');

      if (timeParts.length != 2) {
        Log.e('NOTIFICATION_SERVICE: Invalid time format: $timeString');
        return;
      }

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);

      if (hour == null ||
          minute == null ||
          hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59) {
        Log.e('NOTIFICATION_SERVICE: Invalid hour or minute: $hour:$minute');
        return;
      }

      Log.d('NOTIFICATION_SERVICE: Parsed time - Hour: $hour, Minute: $minute');

      final now = tz.TZDateTime.now(tz.local);
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the scheduled time has passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now.add(const Duration(minutes: 1))) &&
          !allowSameDay) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
        Log.d('NOTIFICATION_SERVICE: Scheduled time has passed, moved to tomorrow');
      }

      final title = 'Time to catch up! 📚';
      final body = 'You have ${bookmarks.length} bookmarked article${bookmarks.length == 1 ? '' : 's'} waiting to be read.';

      Log.i('NOTIFICATION_SERVICE: Preparing notification - Title: "$title", Body: "$body"');

      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'bookmark_reminder',
        'Bookmark Reminders',
        channelDescription:
        'Daily reminders to check your bookmarked articles',
        importance: Importance.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        autoCancel: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        _bookmarkReminderId,
        title,
        body,
        scheduledTime,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'bookmark_reminder',
      );

      Log.i('NOTIFICATION_SERVICE: Bookmark reminder scheduled successfully for ${scheduledTime.toString()}');
    } catch (e) {
      Log.e('NOTIFICATION_SERVICE: Error scheduling bookmark reminder', e);
    }
  }

  Future<void> _cancelBookmarkReminder() async {
    try {
      await _notifications.cancel(_bookmarkReminderId);
      Log.i('NOTIFICATION_SERVICE: Bookmark reminder cancelled (ID: $_bookmarkReminderId)');
    } catch (e) {
      Log.e('NOTIFICATION_SERVICE: Error cancelling bookmark reminder', e);
    }
  }

  // Call this method when bookmarks are added/removed to update the reminder
  Future<void> updateBookmarkReminder() async {
    Log.d('NOTIFICATION_SERVICE: Updating bookmark reminder');

    if (await isReminderEnabled()) {
      Log.d('NOTIFICATION_SERVICE: Reminder is enabled, rescheduling');
      await _scheduleBookmarkReminder();
    } else {
      Log.d('NOTIFICATION_SERVICE: Reminder is disabled, no action needed');
    }
  }

  Future<void> showTestNotification() async {
    try {
      Log.i('NOTIFICATION_SERVICE: Showing test notification');

      // Ensure we're initialized
      if (!_isInitialized) {
        Log.d('NOTIFICATION_SERVICE: Service not initialized, initializing now');
        await initialize();
      }

      const title = 'Test Notification 🔔';
      const body = 'This is a test notification to verify everything is working!';

      Log.d('NOTIFICATION_SERVICE: Test notification content - Title: "$title", Body: "$body"');

      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Test notification channel',
        importance: Importance.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        autoCancel: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        999,
        title,
        body,
        platformDetails,
        payload: 'test',
      );

      Log.i('NOTIFICATION_SERVICE: Test notification sent successfully (ID: 999)');
    } catch (e) {
      Log.e('NOTIFICATION_SERVICE: Error showing test notification', e);
    }
  }

  // Helper method to check if notifications are enabled at system level
  Future<bool> areNotificationsEnabled() async {
    Log.d('NOTIFICATION_SERVICE: Checking if notifications are enabled at system level');

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      _notifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
      >();

      if (androidPlugin != null) {
        final enabled = await androidPlugin.areNotificationsEnabled() ?? false;
        Log.d('NOTIFICATION_SERVICE: System notifications enabled: $enabled');
        return enabled;
      } else {
        Log.w('NOTIFICATION_SERVICE: Android plugin not available for checking notification status');
      }
    }

    Log.d('NOTIFICATION_SERVICE: Assuming notifications are enabled for this platform');
    return true;
  }

  // Get list of pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      Log.d('NOTIFICATION_SERVICE: Retrieved ${pending.length} pending notifications');

      for (final notification in pending) {
        Log.d('NOTIFICATION_SERVICE: Pending notification - ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}');
      }

      return pending;
    } catch (e) {
      Log.e('NOTIFICATION_SERVICE: Error getting pending notifications', e);
      return [];
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      Log.i('NOTIFICATION_SERVICE: All notifications cancelled');
    } catch (e) {
      Log.e('NOTIFICATION_SERVICE: Error cancelling all notifications', e);
    }
  }
}

