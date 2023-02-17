import 'dart:async';

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<ChatMessage> _messsages = [];

  String token = "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";
  // String token = "HV6pzjVEAK2i";

  late OpenAI openAI;
  

  StreamSubscription? _subscription;
  bool isTyping = false;

  @override
  void initState() {
    openAI = OpenAI.instance.build(
        token: token,
        baseOption: HttpSetup(receiveTimeout: 6000),
        isLogger: true);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  void _sendMessage() {
    ChatMessage message = ChatMessage(text: controller.text, sender: "user");

    setState(() {
      _messsages.insert(0, message);
      isTyping = true;
    });

    controller.clear();

    final request = CompleteText(
        prompt: message.text, model: kTranslateModelV3, maxTokens: 200);

    _subscription = openAI
        .onCompleteStream(request: request)
        .asBroadcastStream()
        .listen((res) {
      ChatMessage botMessage =
          ChatMessage(text: res!.choices[0].text, sender: "Bot");

      setState(() {
        isTyping = false;
        _messsages.insert(0, botMessage);
      });
    })
      ..onError((err) {
        print("$err");
      });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: controller,
          decoration:
              const InputDecoration.collapsed(hintText: "Send a message"),
        )),
        IconButton(
            onPressed: () {
              _sendMessage();
            },
            icon: const Icon(Icons.send))
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatGpt Demo"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(children: [
          Flexible(
              child: ListView.builder(
                  reverse: true,
                  itemCount: _messsages.length,
                  itemBuilder: (context, index) {
                    return _messsages[index];
                  })),
          if (isTyping) const CircularProgressIndicator(),
          const Divider(
            height: 1,
          ),
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
            ),
            child: _buildTextComposer(),
          )
        ]),
      ),
    );
  }
}
