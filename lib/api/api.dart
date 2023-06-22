import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatting_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import '../models/chat_user.dart';

class APIs{
  static FirebaseAuth auth = FirebaseAuth.instance;

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static FirebaseStorage storage = FirebaseStorage.instance;

  //create new user
  static User get user => auth.currentUser!;
  static late ChatUser me ;

  //for push noti.
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;


  static Future<void> getFirebaseMessagingToken() async{
    await fmessaging.requestPermission();
    await fmessaging.getToken().then((token){
      if(token != null){
        me.pushToken = token ;
        log('push_token : $token');
      }
    });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');
    //
    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  static Future<void> SendPushNotification( ChatUser chatUser, String msg)async{
    // var url = Uri.https('example.com', 'whatsit/create');
    try{
      final body = {
        "to":chatUser.pushToken,
        "notification":{
          "title":chatUser.name,
          "android_channel_id": "chats",
          "body":msg
        },
        "data": {
          "some_data" : "User Id : ${me.id}",
        },
      };
      var response = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
          headers: {HttpHeaders.contentTypeHeader:'application/json',
            HttpHeaders.authorizationHeader:'key=AAAAnOHNDDo:APA91bF3fowoKqhyw23vIrV4UNpMmCMpw8XPrJpONH0GwQ_rBYC13j9RgdVtOUuGfeZ6wMVmZrPT7CPHKEgJAQcCGSW-pEaQCA6dVnRCrxBOAWhjyRS9oVSmxFCUOfSlhJW5RqQZ2W0i'
          },
          body: jsonEncode(body) );
      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    }catch(e){
      log("\n SendPushNotification error is : $e");
    }
  }

  //user exists or not
  static Future<bool> userExists() async{
    return (await firestore.collection('users').doc(auth.currentUser!.uid).get()).exists ;
  }

  //for getting current user info
  static Future<void> getSelfInfo() async{
    await firestore.collection('users').doc(user.uid).get().then((user)async{
      if(user.exists){
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        APIs.updateActiveStatus(true);
      }else{
        await createUser().then((value) => getSelfInfo());
      }
    }) ;
  }

  //create a new user
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

  //for getting all users from db firstoeer
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(){
    return firestore.collection('users').where('id',isNotEqualTo: user.uid).snapshots();
  }

  //update user info
  static Future<void> updateUserInfo() async{
    await firestore.collection('users').doc(user.uid).update({'name':me.name , 'about':me.about});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUsersInfo(ChatUser chatUser){
    return firestore.collection('users').where('id',isNotEqualTo: chatUser.id).snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,

    });
  }

  //update profile pic
  static Future<void> updateProfilePicture(File file) async{
    final ext = file.path.split('.').last;
    log('Extension: $ext');
    final ref = storage.ref().child('profilePicture/${user.uid}.$ext');
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0){
      log('Data Transferred: ${p0.bytesTransferred /1000} kb');
    });
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({'image':me.image});
  }

  ///********************chatscreen API*********************/

  //chat(collection) --> conversation_id (doc) --> message(collection) --> message(doc)

  //get all messages from specific convo.

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode ? '${user.uid}_$id' : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user) {
    return firestore.collection('chats/${getConversationID(user.id)}/messages/').orderBy('sent',descending: true).snapshots();
  }

  // for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg,Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore.collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value)=> SendPushNotification(chatUser,type == Type.text ? msg : 'image'));
  }

  // update Message Read Status
  static Future<void> updateMessageReadStatus(Message message) async{
    await firestore.collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent).update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }
  
  //show last message of user
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user){
    return firestore.collection('chats/${getConversationID(user.id)}/messages/').orderBy('sent',descending: true).limit(1).snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser , File file) async{
    final ext = file.path.split('.').last;
    //storage file ref with path
    final ref = storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    //uploading iamge
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext')).then((p0){
      log('Data Transferred: ${p0.bytesTransferred /1000} kb');
    });
    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await APIs.sendMessage(chatUser, imageUrl, Type.image);
  }

  static Future<void> deleteMessage(Message message)async{
    await firestore.collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent).delete();
    if(message.type == Type.image){
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessage(Message message,String updatedMsg)async{
    await firestore.collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent).update({'msg':updatedMsg});
  }

}