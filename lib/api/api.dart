import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_user.dart';

class APIs{
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //user exists or not
  static Future<bool> userExists() async{
    return (await firestore.collection('users').doc(auth.currentUser!.uid).get()).exists ;
  }
  //create new user

  static User get user => auth.currentUser!;
  static late ChatUser me ;

  static Future<void> getSelfInfo() async{
    await firestore.collection('users').doc(user.uid).get().then((user)async{
      if(user.exists){
        me = ChatUser.fromJson(user.data()!);
      }else{
        await createUser().then((value) => getSelfInfo());
      }
    }) ;
  }

  static Future<void> createUser() async{

    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        name: user.displayName.toString(),
        about: "Hey I'm using CHIT CHAT",
        createdAt:time,
        lastActive: time,
        isOnline: false,
        id:user.uid,
        email: user.email.toString(),
        pushToken: ''
    );
    return await firestore.collection('users').doc(user.uid).set(chatUser.toJson()) ;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(){
    return firestore.collection('users').where('id',isNotEqualTo: user.uid).snapshots();
  }

  static Future<void> updateUserInfo() async{
    await firestore.collection('users').doc(user.uid).update({'name':me.name , 'about':me.about});
  }
}