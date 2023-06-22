import 'dart:developer';

import 'package:chatting_app/api/api.dart';
import 'package:chatting_app/screens/authScreen/loginScreen.dart';
import 'package:chatting_app/screens/homescreen/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/notification_visibility.dart';


late Size size;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]).then((value) async{
    await Firebase.initializeApp();
    var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For Showing Message notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats',
      visibility: NotificationVisibility.VISIBILITY_PUBLIC,

    );
    log('channel result $result');
    runApp(const MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChitChat',
      theme: ThemeData(
        primaryColor: Colors.yellow,
        appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              centerTitle: true,
              iconTheme: IconThemeData(color:Colors.blue.shade700),
              elevation: 1,
              titleTextStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.normal,color: Colors.black,),
      )),
      home: (APIs.auth.currentUser != null) ? HomeScreen():LoginScreen()
    );
  }
}




