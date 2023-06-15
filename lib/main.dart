import 'package:chatting_app/screens/authScreen/loginScreen.dart';
import 'package:chatting_app/screens/homescreen/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';


late Size size;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]).then((value) async{
    await Firebase.initializeApp();
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
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 1,
              titleTextStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.normal,color: Colors.black,),
      )),
      home: LoginScreen()
    );
  }
}




