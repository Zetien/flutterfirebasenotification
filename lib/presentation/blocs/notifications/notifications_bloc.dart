import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_notificacion_app/config/local_notifications/local_notifications.dart';
import 'package:push_notificacion_app/domain/entities/push_message.dart';
import 'package:push_notificacion_app/firebase_options.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  int pushNumberId = 0;

  final Future<void> Function()? requestPermissionLocalNotifications;
  final void Function({
    required int id,
    String? title,
    String? body,
    String? data,
  })?
  showLocalNotification;

  NotificationsBloc({
    this.showLocalNotification,
    this.requestPermissionLocalNotifications,
  }) : super(const NotificationsState()) {
    on<NotificationStatusChanged>(_notificationStatusChanged);
    on<NotificationReceived>(_onPueshMessageReceived);

    // verificar estado de las notificaciones
    _initialStatusCheck();

    // Listener de mensajes en foreground
    _onForegroundMessages();
  }

  static Future<void> initializeFCM() async {
    //FCM = Firebase Cloud Messaging
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _notificationStatusChanged(
    NotificationStatusChanged event,
    Emitter<NotificationsState> emit,
  ) {
    emit(state.copyWith(status: event.status));
    _getFCMToken();
  }

  void _onPueshMessageReceived(
    NotificationReceived event,
    Emitter<NotificationsState> emit,
  ) {
    emit(
      state.copyWith(
        notificactions: [event.pushMessage, ...state.notificactions],
      ),
    );
  }

  void _initialStatusCheck() async {
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  void _getFCMToken() async {
    if (state.status != AuthorizationStatus.authorized) return;
    final fcmToken = await messaging.getToken();

    print('FCM Token: $fcmToken');
  }

  void handleRemoteMessage(RemoteMessage message) {
    if (message.notification == null) return;
    final notification = PushMessage(
      messageId:
          message.messageId?.replaceAll(':', '').replaceAll('%', '') ?? '',
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      sentDate: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid
          ? message.notification!.android?.imageUrl
          : message.notification!.apple?.imageUrl,
    );

    if (showLocalNotification != null) {
      showLocalNotification!(
        id: ++pushNumberId,
        title: notification.title,
        body: notification.body,
        data: notification.messageId,
      );
    }

    add(NotificationReceived(notification));
  }

  void _onForegroundMessages() {
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }

  void requestPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Solicitar permiso para notificaciones locales
    if (requestPermissionLocalNotifications != null) {
      await requestPermissionLocalNotifications!();
    }
    //await LocalNotifications.requestPermissionLocalNotifications();
    add(NotificationStatusChanged(settings.authorizationStatus));
  }

  PushMessage? getMessageById(String pushMessageId) {
    final exist = state.notificactions.any(
      (element) => element.messageId == pushMessageId,
    );
    if (!exist) return null;

    return state.notificactions.firstWhere(
      (element) => element.messageId == pushMessageId,
    );
  }
}
