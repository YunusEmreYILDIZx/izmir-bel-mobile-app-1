// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notif = FlutterLocalNotificationsPlugin();

  /// Uygulama açılırken main.dart içinde çağıracağız
  static Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    await _notif.initialize(
      const InitializationSettings(android: android, iOS: iOS),
    );
  }

  /// Belirli bir tarihten [hoursBefore] saat önce, saat [atHour]:[atMinute]'da bildirim planlar
  static Future<void> scheduleEventNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    int hoursBefore = 24,
    int atHour = 9,
    int atMinute = 0,
  }) async {
    final scheduledDate = dateTime
        .subtract(Duration(hours: hoursBefore))
        .copyWith(hour: atHour, minute: atMinute);
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notif.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_channel',
          'Etkinlik Hatırlatmaları',
          importance: Importance.max,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
