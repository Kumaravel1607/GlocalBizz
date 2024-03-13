import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:glocal_bizz/Controller/constand.dart';
import 'package:glocal_bizz/Google%20ADs/AdMob_Helper.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
import 'View/OnBoarding.dart';
import 'View/SpalshScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // AdmobHelper.initialization();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  HttpOverrides.global = new MyHttpOverrides();
  // if (kIsWeb) {
  //   // initialiaze the facebook javascript SDK
  //   FacebookAuth.instance.webInitialize(
  //     appId: "499893954543103",
  //     cookie: true,
  //     xfbml: true,
  //     version: "v9.0",
  //   );
  // }
  runApp(
    MaterialApp(
      theme: ThemeData(primaryColor: primaryColor),
      debugShowCheckedModeBanner: false,
      home: new MyApp(),
      // routes: <String,WidgetBuilder>{
      //   "/Notification":(BuildContext context)=> new  NotificationPage(),
      //   "/Chat":(BuildContext context)=> new  ChatListPage(),
      //   }
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: const Color(0xFFF7A11F),
      title: 'Glocal Bizz',
      theme: ThemeData(
        accentColor: Colors.red,
        fontFamily: 'Poppins',
        brightness: Brightness.light,
        primaryColor: const Color(0xFFF7A11F),
        buttonTheme: ButtonThemeData(
            buttonColor: const Color(0xFFF7A11F), disabledColor: Colors.black),
        // iconTheme: IconThemeData(
        //   color: Colors.black,
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                primary: Colors.white,
                textStyle: TextStyle(color: Colors.black))),
      ),
      home: SplashScreen(),
    );
  }
}
