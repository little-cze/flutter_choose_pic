import 'package:choosepic/page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text("Image Choose"),
          ),
          body: MyHome()),
    );
  }
}

class MyHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
          child: Text("Image Choose"),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => PageDemo()))),
    );
  }
}
