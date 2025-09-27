import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'local_notification.dart';

class FCM {
  FCM._();

  /// Callback for token changes.
  static late ValueChanged<String?> _onTokenChanged;

  /// Initialize Firebase Cloud Messaging and set up notification handling.
  ///
  /// [onTokenChanged] is a required callback function that is invoked when the FCM token changes.
  /// [onNotificationPressed] is an optional callback to handle notifications when pressed by the user.
  /// [onNotificationReceived] is a background message handler called when a notification is received while the app is in the background.
  /// [navigatorKey] is an optional `GlobalKey<NavigatorState>` for navigating within the app.
  /// [icon] is a string specifying the icon used for displaying notifications. icon must be in android/app/src/main/res/drawable/ic_launcher.png
  /// [withLocalNotification] is a boolean flag to enable or disable local notifications.
  ///
  /// This method initializes Firebase, sets up token handling, background message handling, and notification presentation options for iOS and Android.
  static Future<void> initializeFCM(
      {required void onTokenChanged(String? token),
      void onNotificationPressed(Map<String, dynamic> data)?,
      required BackgroundMessageHandler onNotificationReceived,
      GlobalKey<NavigatorState>? navigatorKey,
      required String icon,
      bool withLocalNotification = true}) async {
    _onTokenChanged = onTokenChanged;
    await Firebase.initializeApp();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    await LocalNotification.initializeLocalNotification(
        onNotificationPressed: onNotificationPressed, icon: icon);
    messaging.getToken().then(onTokenChanged);
    Stream<String> _tokenStream = messaging.onTokenRefresh;
    _tokenStream.listen(onTokenChanged);

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(onNotificationReceived);

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    messaging.getInitialMessage().then((RemoteMessage? message) {
      print('getInitialMessage');
      print(message);
      if (message != null) {
        if (navigatorKey != null) {
          Timer.periodic(
            Duration(milliseconds: 500),
            (timer) {
              if (navigatorKey.currentState == null) return;
              onNotificationPressed!(message.data);
              timer.cancel();
            },
          );
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('A new onMessage event was published!');

      onNotificationReceived(message);
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null && withLocalNotification) {
        LocalNotification.showNotification(
            notification: notification, payload: message.data, icon: icon);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      onNotificationPressed!(message.data);
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      print('A new onBackgroundMessage event was published!');
      onNotificationPressed!(message.data);
      onNotificationReceived(message);
    });
  }

  /// Delete the FCM refresh token and retrieve a new token.
  static deleteRefreshToken() {
    FirebaseMessaging.instance.deleteToken();
    FirebaseMessaging.instance.getToken().then(_onTokenChanged);
  }

  /// To subscribe to a topic, call subscribeToTopic() with the topic name. This method returns a Future, which resolves when the subscription succeeded:
  static subscribeToTopic(String topic) {
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  /// To unsubscribe from a topic, call the unsubscribeFromTopic method with the topic name:
  static unsubscribeFromTopic(String topic) {
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}
