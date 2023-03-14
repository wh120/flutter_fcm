# Firebase Messaging Plugin for Flutter

A Flutter plugin to use the [Firebase Cloud Messaging API](https://firebase.google.com/docs/cloud-messaging).

To learn more about Firebase Cloud Messaging, please visit the [Firebase website](https://firebase.google.com/products/cloud-messaging)

## Getting Started

To get started with Firebase Cloud Messaging for Flutter, please [see the documentation](https://firebase.flutter.dev/docs/messaging/overview).


## Why flutter_fcm?

- 🚀 Easy to use 
- ❤ Supports local notification
- 🛡️ Null safety
- ⚡ On notification Received/Pressed works in all states: foreground,background and even when app is closed(not running)

## Getting Started

To get started with Firebase Cloud Messaging for Flutter,
see [Android Installation](https://firebase.flutter.dev/docs/manual-installation/android).
and [iOS Installation](https://firebase.flutter.dev/docs/manual-installation/ios).

## Usage

The easiest way to use this library is via the top-level functions.

```dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_fcm/flutter_fcm.dart';

class Messaging {
  static String? token;

  static deleteToken() {
    Messaging.token = null;
    FCM.deleteRefreshToken();
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationReceived(RemoteMessage message) async {
    await Firebase.initializeApp();
    //print('Handling a message ${message}');

  }

  @pragma('vm:entry-point')
  static initFCM() async {
    try {
      await Firebase.initializeApp();
      await FCM.initializeFCM(
        withLocalNotification: true,
        // navigatorKey: Keys.navigatorKey,
        onNotificationReceived: onNotificationReceived,
        onNotificationPressed: (Map<String, dynamic> data) {

        },
        onTokenChanged: (String? token) {
          if (token != null) {
            //print('FCM token  $token');
            Messaging.token = token;


          }
        },
        // TODO add this icon to android/app/src/main/res/drawable/ic_launcher.png
        icon: 'ic_launcher',
      );
    } catch (e) {
      print(e);
    }
  }
}

```
 

  
