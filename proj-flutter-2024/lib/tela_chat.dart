import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'widgets/mensagens.dart';

class TelaChat extends StatefulWidget {
  final String chatId;
  const TelaChat({super.key, required this.chatId});

  @override
  State<TelaChat> createState() => _PaginaChatState();
}

class _PaginaChatState extends State<TelaChat> {
  final emailUsuario = FirebaseAuth.instance.currentUser!.email;
  TextEditingController _controladorInput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('salas')
            .doc(widget.chatId)
            .collection('mensagens')
            .orderBy('criadoEm', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum chat foi encontrado!'),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar os chats!'),
            );
          }

          final mensagens = snapshot.data!.docs;

          print(mensagens.first.data());

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Color.fromRGBO(70, 103, 48, 1),
              title: const Text(
                'Unicv app',
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: mensagens.length,
                    itemBuilder: (context, index) {
                      return Mensagens(
                        nomeUsuario: mensagens[index].data()['email'],
                        conteudoMensagem: mensagens[index].data()['conteudo'],
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: TextField(
                        controller: _controladorInput,
                      )),
                      IconButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('salas')
                              .doc(widget.chatId)
                              .collection('mensagens')
                              .add({
                            'conteudo': _controladorInput.text,
                            'email': emailUsuario,
                            'criadoEm': Timestamp.now(),
                          });
                          _controladorInput.clear();
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
