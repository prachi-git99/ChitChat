import 'dart:convert';
import 'dart:developer';
import 'dart:core';
import 'package:chatting_app/api/api.dart';
import 'package:chatting_app/models/chat_user.dart';
import 'package:chatting_app/screens/profileScreen/profile_screen.dart';
import 'package:chatting_app/widgets/chatUserCard.dart';
import 'package:chatting_app/widgets/dialogs.dart';
import 'package:chatting_app/widgets/floatingActionButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    SystemChannels.lifecycle.setMessageHandler((message){
      log("\n message: $message");

      if(APIs.auth.currentUser != null ){
        if(message.toString().contains('paused')){
          APIs.updateActiveStatus(false);
        }
        if(message.toString().contains('resumed')){
          APIs.updateActiveStatus(true);
        }
      }
      return Future.value(message);
    });

  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: (){
          if(_isSearching){
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          }
          else{
            return Future.value(true);
          }

        },
        child: Scaffold(
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
              onPressed: (){
                _addChatUserDialog();
              },
              child: MyFloatingActionButton(),
            ),
          ),
          body: StreamBuilder(
              stream: APIs.getMyUsersId(),
              builder: (context,snapshot){
                switch(snapshot.connectionState){
                //data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    // return Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                  return StreamBuilder(
                      stream: APIs.getAllUsers(snapshot.data?.docs.map((e) => e.id).toList() ?? []),
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
                                    Center(child: CircularProgressIndicator());
                                    return ChatUserCard(user:_isSearching? _searchlist[index] : list[index],);
                                  }
                              );
                            }
                            else{
                              Center(child: CircularProgressIndicator());
                              return Center(child: Text('No Connections Found !'),);
                            }
                        }



                      }
                  );
                }
              }
          )
        ),
      ),
    );
  }


  void _addChatUserDialog(){
    String email = '';
    showDialog(context: context, builder:(_)=>AlertDialog(
      contentPadding: EdgeInsets.only(left: 24,right: 24,bottom: 20,top: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.person_add,color: Colors.blue,size: 28,),
          Text("  Add User",)
        ],
      ),
      content: TextFormField(
        initialValue: null,
        maxLines: null,
        onChanged: (value)=>email = value,
        decoration: InputDecoration(
            hintText: 'Email id',
            prefixIcon: Icon(Icons.mail,color: Colors.blue,),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)
            )),
      ),
      actions: [
        MaterialButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: Text("Cancel",style: TextStyle(color: Colors.blue,fontSize:16)),
        ),
        MaterialButton(
          onPressed: ()async{
            Navigator.pop(context);
            if(email.isNotEmpty){
              await APIs.addChatUser(email).then((value){
                if(!value){
                  Dialogs.showSnackbar(context,'User doew not exists');
                }
              });
            }
            else{

            }


          },
          child: Text("Add",style: TextStyle(color: Colors.blue,fontSize:16)),
        ),
      ],
    ));
  }

}
