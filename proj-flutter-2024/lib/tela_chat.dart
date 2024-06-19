import 'package:flutter/material.dart';

import 'widgets/mensagens_chat.dart';

class TelaChat extends StatefulWidget {
  final String chatId;
  const TelaChat({super.key, required this.chatId});

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.chatId,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.exit_to_app,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          MensagensChat(
            chatId: widget.chatId,
          ),
        ],
      ),
    );
  }
}
