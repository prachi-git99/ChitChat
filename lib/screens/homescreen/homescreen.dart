import 'dart:convert';
import 'dart:developer';
import 'dart:core';
import 'package:chatting_app/api/api.dart';
import 'package:chatting_app/models/chat_user.dart';
import 'package:chatting_app/screens/profileScreen/profile_screen.dart';
import 'package:chatting_app/widgets/chatUserCard.dart';
import 'package:chatting_app/widgets/floatingActionButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../main.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<ChatUser> list =[];
  final List<ChatUser> _searchlist =[];

  bool _isSearching = false ;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
    log("\n UserInfo: ${APIs.auth.currentUser}");

  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: Icon(_isSearching? null:Icons.home_outlined,),
        title: _isSearching
            ? TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search Here ...',
          ),
          autofocus: true,
          onChanged: (value){
            //search logic
            _searchlist.clear();
            for(var i in list){
              if(i.name.toLowerCase().contains(value.toLowerCase()) || i.email.toLowerCase().contains(value.toLowerCase())){
                _searchlist.add(i);
              }
              setState(() {
                _searchlist;
              });
            }
          },
        )
            :Text("Chit Chat",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 21,color: Colors.blue.shade700),),
        actions: [
          IconButton(onPressed: (){
            setState(() {
              _isSearching = !_isSearching;
            });
          }, icon:Icon(_isSearching? CupertinoIcons.clear_circled_solid:Icons.search)),
          IconButton(onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (_) => ProfileScreen(user:APIs.me)));
          }, icon:Icon(Icons.more_vert)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0,0,0,10),
        child: FloatingActionButton(
          elevation:15,
          onPressed: ()async {
            await APIs.auth.signOut();
            await GoogleSignIn().signOut();
          },
          child: MyFloatingActionButton(),
        ),
      ),
      body: StreamBuilder(
        stream: APIs.getAllUsers(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            //data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
              if(list.isNotEmpty){
                return ListView.builder(
                    padding: EdgeInsets.only(top:size.height* 0.02),
                    physics: BouncingScrollPhysics(),
                    itemCount:_isSearching? _searchlist.length :list.length,
                    itemBuilder: (context,index){
                      return ChatUserCard(user:_isSearching? _searchlist[index] : list[index],);
                    }
                );
              }
              else{
                return Center(child: Text('No Connections Found !'),);
              }
          }



        }
      ),
    );
  }
}
