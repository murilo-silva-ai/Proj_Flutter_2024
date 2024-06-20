import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'widgets/mensagens.dart';

final _firebaseAuth = FirebaseAuth.instance;

class TelaChat extends StatefulWidget {
  final String chatId;
  const TelaChat({super.key, required this.chatId});

  @override
  State<TelaChat> createState() => _PaginaChatState();
}

class _PaginaChatState extends State<TelaChat> {
  final emailUsuario = FirebaseAuth.instance.currentUser!.email;
  TextEditingController _controladorInput = TextEditingController();
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserAdminStatus();
  }

  Future<void> _loadUserAdminStatus() async {
    final usuarioAutenticado = FirebaseAuth.instance.currentUser;
    if (usuarioAutenticado != null) {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuarioAutenticado.uid)
          .get();
      if (doc.exists) {
        setState(() {
          isAdmin = doc.data()?['isAdmin'] ?? false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(70, 103, 48, 1),
        title: const Text('Unicv app'),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('salas')
                  .doc(widget.chatId)
                  .collection('mensagens')
                  .orderBy('criadoEm', descending: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('Nenhum chat foi encontrado!'),
                  );
                }

                final mensagens = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    return Mensagens(
                      nomeUsuario: mensagens[index]['email'],
                      conteudoMensagem: mensagens[index]['conteudo'],
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: 60,
            child: isAdmin
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controladorInput,
                        ),
                      ),
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
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
