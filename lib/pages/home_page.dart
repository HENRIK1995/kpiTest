import 'dart:async';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _wsUrl = 'ws://echo.websocket.events/';
  IOWebSocketChannel? _wsChannel;
  StreamSubscription? _wsListener;
  final _socketMessageController = TextEditingController();
  final _textControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    _wsChannel = IOWebSocketChannel.connect(_wsUrl);
    _wsListener = _wsChannel?.stream.listen((message) {
      setState(() {
        for (var element in _textControllers) {
          element.text = '$message at cell${_textControllers.indexOf(element) + 1}';
        }
      });
    });
  }

  @override
  void dispose(){
    for (var element in _textControllers) {element.dispose();}
    _socketMessageController.dispose();
    _wsListener?.cancel();
    _wsChannel?.sink.close(status.goingAway);
    super.dispose();
  }

  void _echoSocket() {
    _wsChannel?.sink.add(_socketMessageController.text);
    setState(() {
      _socketMessageController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _echoSocket,
        child: const Icon(Icons.send),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              children: List.generate(9, (index) => Container(
                key: Key('$index'),
                decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black87)),
                child: Center(
                  child: TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.done,
                    maxLines: null,
                    controller: _textControllers[index],
                  ),
                ),
              )),
            ),
            const SizedBox(height: 10,),
            const Center(
              child: Text('Send message via socket'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Type your text here'
                ),
                controller: _socketMessageController,
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}