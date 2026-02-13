import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

    const initializationSettingsAndroid = AndroidInitializationSettings(
      'app_icon',
    );
    //TODO IOS initialization settings
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      //TODO IOS initialization settings
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      //TODO 
    );
  }
}
