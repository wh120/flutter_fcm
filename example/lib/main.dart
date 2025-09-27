import 'package:flutter/material.dart';
import 'package:flutter_fcm/flutter_fcm.dart';

void main() {
  Messaging.initFCM();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter FCM Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Messaging {
  static String? token;

  static deleteToken() {
    Messaging.token = null;
    FCM.deleteRefreshToken();
  }

  static subscribeToTopic(String topic) {
    FCM.subscribeToTopic(topic);
  }

  static unsubscribeFromTopic(String topic) {
    FCM.unsubscribeFromTopic(topic);
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
        onNotificationPressed: (Map<String, dynamic> data) {},
        onTokenChanged: (String? token) {
          if (token != null) {
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
