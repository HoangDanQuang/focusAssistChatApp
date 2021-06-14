import 'package:focus_assist_chat_app/pages/home_screen.dart';
import 'package:focus_assist_chat_app/pages/login_screen.dart';
import 'package:flutter/material.dart';

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
