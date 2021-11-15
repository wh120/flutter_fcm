import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'LocalNotification.dart';


class FCM{

  static ValueChanged<String> _onTokenChanged;
  static var _onNotificationReceived;
  static initializeFCM({
    void onTokenChanged(String token),
    void onNotificationPressed(Map<String, dynamic> data),
    void onNotificationReceived(Map<String, dynamic> data),
      GlobalKey<NavigatorState> navigatorKey,
    String icon
  }
    )async{
    _onTokenChanged=onTokenChanged;
    _onNotificationReceived = onNotificationReceived;

    await LocalNotification.initializeLocalNotification(
        onNotificationPressed: onNotificationPressed,
      icon: icon
    );
    await Firebase.initializeApp();
    FirebaseMessaging.instance.getToken().then(onTokenChanged);
    Stream<String> _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
    _tokenStream.listen(onTokenChanged);

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(

            (RemoteMessage message) async {
              onNotificationReceived( message?.data??{});
          // If you're going to use other Firebase services in the background, such as Firestore,
          // make sure you call `initializeApp` before using other Firebase services.
          await Firebase.initializeApp();
          print('Handling a background message ${message.messageId}');

        }
    );

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );


    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {

      print('getInitialMessage');
      print(message);
      if (message != null) {
        if(navigatorKey!= null)
        Timer.periodic(
          Duration(milliseconds: 500),
              (timer) {
            if ( navigatorKey.currentState == null) return;
            onNotificationPressed(message.data);
            timer.cancel();
          },
        );

      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('A new onMessage event was published!');

      onNotificationReceived( message.data);
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;

      if (notification != null && android != null) {
        LocalNotification.showNotification(
            notification: notification ,
            payload:  message.data,
            icon: icon
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      onNotificationPressed(message.data);
       }
    );

    // FirebaseMessaging.onBackgroundMessage((RemoteMessage message)async {
    //   print('A new onBackgroundMessage event was published!');
    //   onNotificationPressed(message.data);
    //   onNotificationReceived( message.data);
    //  }
    //);
  }

  //static Future<void> _firebaseMessagingBackgroundHandler
  static deleteRefreshToken(){

    FirebaseMessaging.instance.deleteToken();
    FirebaseMessaging.instance.getToken().then(_onTokenChanged);
  }


}