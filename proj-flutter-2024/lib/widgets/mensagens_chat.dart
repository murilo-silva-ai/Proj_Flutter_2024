import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'mensagem.dart';

class MensagensChat extends StatelessWidget {
  final String chatId;
  const MensagensChat({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('salas')
          .doc(chatId)
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
            child: Text('Nenhuma mensagem enviada!'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Algum erro desconhecido ocorreu'),
          );
        }

        final mensagensCarregadas = snapshot.data!.docs;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: mensagensCarregadas.length,
              itemBuilder: (context, index) {
                return Mensagem(
                  conteudoMensagem: mensagensCarregadas[index]['conteudo'],
                  nomeUsuario: mensagensCarregadas[index]['email'],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
