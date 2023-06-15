import 'package:chatting_app/widgets/floatingActionButton.dart';
import 'package:flutter/material.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.home_outlined),
        title: Text("Chit Chat",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18),),
        actions: [
          IconButton(onPressed: (){}, icon:Icon(Icons.search)),
          IconButton(onPressed: (){}, icon:Icon(Icons.more_vert)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0,0,0,10),
        child: FloatingActionButton(
          onPressed: (){},
          child: MyFloatingActionButton(),
        ),
      ),
    );
  }
}
