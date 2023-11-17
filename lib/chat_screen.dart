import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:energychat/chat_message.dart';
import 'package:flutter/material.dart';
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

  final openAI = OpenAI.instance.build(
      token: "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",
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true);

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';

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
      );
      messageHistory.add(Messages(role: Role.user, content: text));
      setState(() {
        messageList.insert(0, message);
      });
      message.animationController.forward();
      // await _sendMessageText();
      final response = await chatCompleteWith();
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
    );
    messageHistory.add(Messages(role: Role.system, content: text));
    setState(() {
      messageList.insert(0, message);
    });
    message.animationController.forward();
  }

  Future<String> chatCompleteWith() async {
    final request = ChatCompleteText(
      messages: messageHistory,
      maxToken: 200,
      model: GptTurboChatModel(),
    );
    String result = '';

    final response = await openAI.onChatCompletion(request: request);

    for (var element in response!.choices) {
      result = result + element.message!.content;
    }
    return result;
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if (val == 'done') {
            setState(() {
              _isListening = false;
            });
            _handleSubmit(_text, true);
          }
        },
        onError: (val) => print('onError: ${val.errorMsg}'),
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
              print(_text);
            },
          ),
        );
      }
    } else {
      setState(() => _isListening = false);
      _handleSubmit(_text, true);
      print('Debug text :$_text');
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Bot'),
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
