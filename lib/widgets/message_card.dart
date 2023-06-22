import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/api/api.dart';
import 'package:chatting_app/main.dart';
import 'package:chatting_app/models/message.dart';
import 'package:chatting_app/widgets/dialogs.dart';
import 'package:chatting_app/widgets/my_date_time.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({Key? key, required this.message}) : super(key: key);

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: (){
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }


  //sender message
  Widget _blueMessage() {

    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
      log('meassage read update');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(size.width * 0.04),
            margin: EdgeInsets.symmetric(horizontal: size.width * .04 ,vertical: size.height * 0.01),
            decoration: BoxDecoration(
              border: Border.all(color:Colors.black,),
              borderRadius: BorderRadius.only(topLeft:Radius.circular(30),topRight:Radius.circular(30),bottomRight:Radius.circular(30)),
              gradient: LinearGradient(colors: [Colors.grey.shade700,Colors.grey.shade500])
            ),
            child:widget.message.type == Type.text
                ? Text(widget.message.msg,style: TextStyle(fontSize: 15,color: Colors.white),)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => CircleAvatar(
                        child: Icon(Icons.image,size: 70,),
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding:EdgeInsets.only(right: size.width * 0.04),
          child: Text(MyDateTime.getFormatedTime(context: context,time:widget.message.sent),
            style: TextStyle(fontSize: 13,color: Colors.black54),),
        ),
      ],
    );
  }

  //our message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: size.width * 0.04,),
              Icon(Icons.done_all_rounded,color: widget.message.read.isNotEmpty ? Colors.blue : Colors.grey ,size: 20,),
            SizedBox(width: size.width * 0.01,),
            Text(MyDateTime.getFormatedTime(context: context, time:widget.message.sent),style: TextStyle(fontSize: 13,color: Colors.black54),),
          ],
        ),

        Flexible(
          child: Container(
              padding: EdgeInsets.all(size.width * 0.04),
              margin: EdgeInsets.symmetric(horizontal: size.width * .04 ,vertical: size.height * 0.01),
              decoration: BoxDecoration(
                  border: Border.all(color:Colors.blue.shade900,),
                  borderRadius: BorderRadius.only(topLeft:Radius.circular(30),topRight:Radius.circular(30),bottomLeft:Radius.circular(30)),
                  gradient: LinearGradient(colors: [Colors.blue.shade900,Colors.lightBlueAccent.shade400])
              ),
              child: widget.message.type == Type.text
                  ? Text(widget.message.msg,style: TextStyle(fontSize: 15,color: Colors.white),)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context,url)=>CircularProgressIndicator(),
                        errorWidget: (context, url, error) => CircleAvatar(
                          child: Icon(Icons.image,size: 70,),
                        ),
                      ),
                  ),
          ),
        ),

      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(vertical: size.height* 0.015 , horizontal: size.width * 0.4),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8)
                ),
              ),

              widget.message.type == Type.text ?
              _OptionItem(
                icon: Icon(Icons.copy_all_rounded,color: Colors.blue,size: 26,),
                name: "Copy Text",
                onTap: ()async{
                  await Clipboard.setData(ClipboardData(text:widget.message.msg)).then((value){
                    Navigator.pop(context);
                    Dialogs.showSnackbar(context,'Text Copied');
                  });
                },
              ) :  _OptionItem(
                icon: Icon(Icons.download,color: Colors.blue,size: 26,),
                name: "Save Image",
                onTap: ()async{
                  try{
                    await GallerySaver.saveImage(widget.message.msg,albumName: 'ChitChat').then((success) {
                      Navigator.pop(context);
                      if(success !=null && success){
                        Dialogs.showSnackbar(context,'Image Saved Successfully');
                      }
                    });
                  } catch(e){
                    log("Error image save : $e");
                  }
                },
              ) ,
              if(isMe)
              Divider(color: Colors.black54,endIndent: size.width * 0.04,indent: size.width * 0.04,),
              if(widget.message.type == Type.text && isMe)
              _OptionItem(
                icon: Icon(Icons.edit,color: Colors.blue,size: 26,),
                name: "Edit Message",
                onTap: (){
                  Navigator.pop(context);
                  _showMessageUpdateDialog();
                },
              ),
              if(isMe)
              _OptionItem(
                icon: Icon(Icons.delete_forever,color: Colors.red,size: 26,),
                name: "Delete Message",
                onTap: ()async {
                  await APIs.deleteMessage(widget.message);
                  Navigator.pop(context);
                  Dialogs.showSnackbar(context,'Message Deleted');
                  },
              ),
              Divider(color: Colors.black54,endIndent: size.width * 0.04,indent: size.width * 0.04,),
              _OptionItem(
                icon: Icon(Icons.remove_red_eye,color: Colors.blue,size: 26,),
                name: "Sent At: ${MyDateTime.getLastMessageTime(context: context, time: widget.message.sent ,)}",
                onTap: (){},
              ),
              _OptionItem(
                icon: Icon(Icons.remove_red_eye,color: Colors.green,size: 26,),
                name: widget.message.read.isEmpty ? 'Read At : Not Seen Yet'
                    :'Read At : ${MyDateTime.getLastMessageTime(context: context, time: widget.message.read)}',
                onTap: (){},
              ),


            ],
          );
        });
  }

  void _showMessageUpdateDialog(){
    String updatedMsg = widget.message.msg;
    showDialog(context: context, builder:(_)=>AlertDialog(
      contentPadding: EdgeInsets.only(left: 24,right: 24,bottom: 20,top: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.message,color: Colors.blue,size: 28,),
          Text(" Update Message")
        ],
      ),
      content: TextFormField(
        initialValue: updatedMsg,
        maxLines: null,
        onChanged: (value)=>updatedMsg = value,
        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      ),
      actions: [
        MaterialButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: Text("Cancel",style: TextStyle(color: Colors.blue,fontSize:16)),
        ),
        MaterialButton(
          onPressed: (){
            Navigator.pop(context);
            APIs.updateMessage(widget.message, updatedMsg);
          },
          child: Text("Update",style: TextStyle(color: Colors.blue,fontSize:16)),
        ),
      ],
    ));
  }


}

class _OptionItem extends StatelessWidget {
  final Icon icon ;
  final String name;
   final VoidCallback onTap;
  const _OptionItem({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()=>onTap(),
      child: Padding(
        padding:  EdgeInsets.only(left: size.width * 0.05,top: size.height* 0.015 , bottom: size.height*.025),
        child: Row(
          children: [
            icon,
            Flexible(child: Text('   $name',style: TextStyle(fontSize: 15,color: Colors.black54,letterSpacing: 0.5),)),
          ],
        ),
      ),
    );
  }
}
