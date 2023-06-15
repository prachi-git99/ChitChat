import 'dart:developer';

import 'package:chatting_app/main.dart';
import 'package:chatting_app/screens/homescreen/homescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false ;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(milliseconds: 500),(){
      setState(() {
        _isAnimate = true ;

      });
    });
  }

  _handleGoogleSignIn(){
    _signInWithGoogle().then((user) {
      log("\n UserInfo: ${user.user}");
      log("\n UserAdditionalInfo: ${user.additionalUserInfo}");
      Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>HomeScreen()));
    });
  }
  Future<UserCredential> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(" Welcome to Chit Chat",),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: Duration(seconds:1),
            top: size.height * 0.15,
            width: size.width * 0.5,
            right: _isAnimate? size.width * 0.25 : -size.width * 0.5 ,
            child: Image.asset('assets/images/icon.png'),
          ),

          Positioned(
            bottom: size.height * 0.10,
            width: size.width * 0.9,
            height:size.height * 0.07 ,
            left: size.width * 0.05,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
                shape: StadiumBorder(),
                elevation: 1
              ),
                onPressed:(){
                  _handleGoogleSignIn();
                },
                icon:Image.asset('assets/images/google.png',height: size.height*0.04,),
                label:RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 16
                    ),
                    children: [
                      TextSpan(text: "Login with "),
                      TextSpan(text: "Google",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    ]
                  ),
                )
            )
          ),
        ],
      ),
    );
  }
}
