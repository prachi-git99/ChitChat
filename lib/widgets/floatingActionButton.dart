import 'package:flutter/material.dart';

Widget MyFloatingActionButton(){
  return Container(
    width: 60,
    height: 60,
    child: Icon(
      Icons.add_comment_rounded,
    ),
    decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Colors.blue.shade900,Colors.lightBlueAccent.shade400])
    ),
  );
}