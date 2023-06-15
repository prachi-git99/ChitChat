import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/main.dart';
import 'package:chatting_app/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({Key? key,required this.user}) : super(key: key);

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: size.width * .04, vertical:5),
      // color: Colors.blue.shade50,
      elevation:0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: (){},
        child: ListTile(
          // leading: CircleAvatar(
          //   child: Icon(CupertinoIcons.person),
          //   backgroundColor: Colors.blue.shade700,
          // ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              width: size.height * 0.055,
              height: size.height * 0.055,
              imageUrl: widget.user.image,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => CircleAvatar(
                child: Icon(CupertinoIcons.person),

              ),
            ),
          ),
          title: Text(widget.user.name),
          subtitle: Text(widget.user.about,maxLines: 1,),
          trailing: Container(width: 10,height: 10,decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),color:Colors.green.shade700,),),


        ),
      ),
    );
  }
}
