import 'dart:ffi';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notificacion_app/config/router/app_router.dart';

class LocalNotifications {
  static Future<void> requestPermissionLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> initializeLocalNotifications() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    //TODO IOS initialization settings
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      //TODO IOS initialization settings
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
    
  }

  static void showLocalNotification({

     required int id,
    String? title,
    String? body,
    String? data,
  }) {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notificationsound'),
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      //TODO IOS notification details
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.show(id: id, title: title, body: body, notificationDetails: notificationDetails, payload: data
    );
  }

  static void onDidReceiveNotificationResponse(NotificationResponse response){
    appRouter.push('/push-details/${response.payload}');
  }
}
