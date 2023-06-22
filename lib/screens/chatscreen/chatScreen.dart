import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/api/api.dart';
import 'package:chatting_app/models/chat_user.dart';
import 'package:chatting_app/models/message.dart';
import 'package:chatting_app/screens/chatscreen/view_profile_screen.dart';
import 'package:chatting_app/widgets/message_card.dart';
import 'package:chatting_app/widgets/my_date_time.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user ;
  const ChatScreen({Key? key,required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  List<Message> _list = [] ;

  bool _showEmoji = false , _isUploading =false;


  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: (){
            if(_showEmoji){
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            }
            else{
              return Future.value(true);
            }

          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace:_appbar() ,
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch(snapshot.connectionState){
                        //data is loading
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return SizedBox();
                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs; //data ko docs k andr save
                            log('Message data: ${jsonEncode(data![0].data())}'); //json data mil gya to create an object /model file
                            _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ?? [];

                            if(_list.isNotEmpty){
                              Center(child: CircularProgressIndicator(strokeWidth: 2,));
                              return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                  padding: EdgeInsets.only(top:size.height* 0.02),
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context,index){
                                    return MessageCard(message:_list[index],);
                                  }
                              );
                            }else{
                              return Center(child: Text('Say Hii !! 👋',style: TextStyle(fontSize: 16),),);
                            }

                        }
                      }
                  ),
                ),
                if(_isUploading) const Align(child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2,)),
                ),alignment: Alignment.centerRight,),

                _chatInput(),
                //show emojis on keyboard emoji button click & vice versa
                if (_showEmoji)
                  SizedBox(
                    height: size.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 30 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _appbar(){
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(
        stream: APIs.getUsersInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs; //data ko docs k andr save
          final list = data ?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back,color: Colors.black45,),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    width: size.height * 0.055,
                    height: size.height * 0.055,
                    imageUrl:list.isNotEmpty ? widget.user.image : list[0].image,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty ? widget.user.name : list[0].name,
                    style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height:2,),
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline ?'Online'
                        : MyDateTime.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                        : MyDateTime.getLastActiveTime(context: context, lastActive: widget.user.lastActive) ,
                    style: TextStyle(fontSize: 12,color: Colors.black45,fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _chatInput(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01,horizontal: size.width * 0.03),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: (){
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });

                    },
                    icon: Icon(Icons.emoji_emotions,color: Colors.blueAccent,),
                  ),
                  Expanded(
                      child:TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onTap: (){
                          if(_showEmoji){
                            setState(() {_showEmoji = !_showEmoji;});
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Message',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.blue.shade200,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,

                          )
                        ),
                      ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image
                      final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
                      for(var i in images){
                        if (images.isNotEmpty) {
                          setState(()=> _isUploading = true );
                          await APIs.sendChatImage(widget.user,File(i.path));
                          setState(()=> _isUploading = false );
                        }
                      }

                    },
                    icon: Icon(Icons.image,color: Colors.blueAccent,),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(()=> _isUploading = true );
                        await APIs.sendChatImage(widget.user,File(image.path));
                        setState(()=> _isUploading = false );
                      }
                    },
                    icon: Icon(Icons.camera_alt,color: Colors.blueAccent,),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
              onPressed: (){
                if(_textController.text.isNotEmpty){
                  if(_list.isEmpty){
                    APIs.sendFirstMessage(widget.user,_textController.text,Type.text);
                  }
                  else{
                    APIs.sendMessage(widget.user,_textController.text,Type.text);
                  }
                  _textController.text ='';
                }
              },
            padding: EdgeInsets.only(top: 10,bottom: 10,right: 5,left: 10),
            minWidth: 0,
            shape: CircleBorder(),
            color: Colors.green,
            child: Icon(Icons.send,color: Colors.white,size: 28,),
          )
        ],
      ),
    );
  }
}
