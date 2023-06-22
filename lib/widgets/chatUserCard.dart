import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/api/api.dart';
import 'package:chatting_app/main.dart';
import 'package:chatting_app/models/chat_user.dart';
import 'package:chatting_app/models/message.dart';
import 'package:chatting_app/screens/chatscreen/chatScreen.dart';
import 'package:chatting_app/widgets/my_date_time.dart';
import 'package:chatting_app/widgets/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({Key? key,required this.user}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  Message? _message ;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: size.width * .04, vertical:5),
      // color: Colors.blue.shade50,
      elevation:0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: (){
          Navigator.push(context,MaterialPageRoute(builder:(_) => ChatScreen(user:widget.user)));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs; //data ko docs k andr save
            final list = data ?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if(list.isNotEmpty){
              _message =list[0];
            }
            return ListTile(
              leading: InkWell(
                onTap: (){
                  showDialog(context: context, builder: (_)=> ProfileDialog(user: widget.user));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    width: size.height * 0.055,
                    height: size.height * 0.055,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) => CircleAvatar(
                      child: Icon(CupertinoIcons.person),

                    ),
                  ),
                ),
              ),
              title: Text(widget.user.name),
              subtitle: Text(_message != null ? _message!.type == Type.image ? 'image' : _message!.msg:widget.user.about,maxLines: 1,),
              trailing:_message ==null
                  ? null
                  : _message!.read.isEmpty && _message!.fromId != APIs.user.uid ?
                  Container(
                    width: 10,height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color:Colors.green.shade700,
                    ),
                  ) : Text(MyDateTime.getLastMessageTime(context: context,time:_message!.sent),style: TextStyle(color: Colors.black54),),


            );
          }
        ),
      ),
    );
  }
}
