import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification{


  /// Create a [AndroidNotificationChannel] for heads up notifications
  static AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );


  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();


  static initializeLocalNotification({
    void onNotificationPressed(Map<String, dynamic> data),
        String icon
      } )async{

    // Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);


    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
     AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings(icon);
    final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) {
         return onSelectNotification(payload: payload , onData: onNotificationPressed);
        },);
  }

  static Future onSelectNotification({String payload , onData}) async {

    if (payload != null) {
      debugPrint('notification payload: $payload');

      var jsonData = jsonDecode(payload);
      onData(jsonData);

    }

  }


  static Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    print(title);

  }

  static showNotification({
    RemoteNotification notification ,
    Map<String, dynamic>  payload,
    String icon
    }
    ){

    flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
           icon: icon,
          ),
        ),
        payload: jsonEncode( payload)
    );

  }


}