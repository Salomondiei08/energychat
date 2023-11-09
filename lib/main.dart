import 'package:energychat/chat_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const GPTChatApp());
}

class GPTChatApp extends StatelessWidget {
  const GPTChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPT Chat Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ChatScreen(),
    );
  }
}
