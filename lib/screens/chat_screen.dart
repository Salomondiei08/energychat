import 'dart:convert';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:energychat/chat_message.dart';
import 'package:energychat/screens/pdf_view.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  List<Messages> messageHistory = [];

  final TextEditingController textEditingController = TextEditingController();
  final List<ChatMessage> messageList = <ChatMessage>[];

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';

  Future<void> displayFile(String text) async {
    final fileUrl = await downloadPdfFile(text);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((context) => PDFView(
              url: fileUrl!,
            )),
      ),
    );
  }

  Future<String?> downloadPdfFile(String text) async {
    try {
      final url = Uri.parse(
        "https://chatproject-4hh5r2wlaq-uc.a.run.app/pdf/$text",
      );
      var headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
      };

      var response = await post(
        url,
        headers: headers,
      );

      debugPrint("La requete a ete lance, voici le contenu : ${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.body.codeUnits));
        debugPrint(responseData.toString());

        debugPrint(
            "La requete a reussis, voici le contenu de la reponse : $responseData");
        return responseData;
      } else {
        var responseData = json.decode(response.body);
        debugPrint("La requete a echoue, voici le contenu : $responseData");
      }
    } catch (e) {}
    return null;
  }

  Future<String> chatAndAnwser() async {
    try {
      final url = Uri.parse(
        "https://chatproject-4hh5r2wlaq-uc.a.run.app/question/",
      );
      var headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        "Access-Control-Allow-Headers": "*"
      };

      var data = [];

      for (var element in messageHistory) {
        data.add(element.toJson());
      }

      var response = await post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      debugPrint("La requete a ete lance, voici le contenu : ${response.body}");
      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.body.codeUnits));
        debugPrint(responseData.toString());

        debugPrint(
            "La requete a reussis, voici le contenu de la reponse : $responseData");
        return responseData;
      } else {
        var responseData = json.decode(response.body);
        debugPrint("La requete a echoue, voici le contenu : $responseData");
        return 'Error';
      }
    } catch (e) {
      return " $e";
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _handleSubmit(String text, bool isUser) async {
    textEditingController.clear();

    if (text.isEmpty == false) {
      ChatMessage message = ChatMessage(
        isUser: true,
        text: text,
        animationController: AnimationController(
          duration: const Duration(milliseconds: 700),
          vsync: this,
        ),
        function: null,
      );
      messageHistory.add(Messages(role: Role.user, content: text));
      setState(() {
        messageList.insert(0, message);
      });
      message.animationController.forward();
      // await _sendMessageText();
      final response = await chatAndAnwser();

      createChatResponse(response);
    }
  }

  void createChatResponse(String text) {
    ChatMessage message = ChatMessage(
      text: text,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 700),
        vsync: this,
      ),
      function: () async {
        await displayFile(text);
      },
    );
    messageHistory.add(Messages(role: Role.system, content: text));
    setState(() {
      messageList.insert(0, message);
    });
    message.animationController.forward();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        debugLogging: true,
        onStatus: (val) {
          if (val == 'done') {
            setState(() {
              _isListening = false;
            });
            _handleSubmit(_text, true);
          }
        },
        onError: (val) => print('onError: ${val}'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          cancelOnError: true,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          localeId: "fr_FR",
          onResult: (val) => setState(
            () {
              _text = val.recognizedWords;
            },
          ),
        );
      }
    } else {
      setState(() => _isListening = false);
      _handleSubmit(_text, true);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Affiba',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
      ),
      body: SafeArea(
        child: Column(children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) => messageList[index],
              itemCount: messageList.length,
            ),
          ),
          const Divider(height: 1.0),
          Container(
            height: 50,
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ]),
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).secondaryHeaderColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: textEditingController,
                onSubmitted: (value) => _handleSubmit(value, true),
                decoration:
                    const InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.orange,
              ),
              onPressed: () => _handleSubmit(textEditingController.text, true),
            ),
            AvatarGlow(
              animate: _isListening,
              glowColor: Colors.orange,
              endRadius: 20,
              duration: const Duration(milliseconds: 2000),
              repeatPauseDuration: const Duration(milliseconds: 100),
              repeat: true,
              child: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.green,
                  ),
                  onPressed: () async => await _listen()),
            ),
          ],
        ),
      ),
    );
  }
}
