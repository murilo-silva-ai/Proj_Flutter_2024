import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'tela_chat.dart';

final _firebaseAuth = FirebaseAuth.instance;
bool isAdmin = false;

class TelaListaDeChats extends StatefulWidget {
  const TelaListaDeChats({super.key});

  @override
  State<TelaListaDeChats> createState() => _TelaListaDeChatsState();
}

class _TelaListaDeChatsState extends State<TelaListaDeChats> {
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

  void _adicionarNovaSala() {
    final TextEditingController salaController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Nova Sala'),
          content: TextField(
            controller: salaController,
            decoration: const InputDecoration(hintText: 'Nome da Sala'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Adicionar'),
              onPressed: () async {
                final String nomeSala = salaController.text;
                if (nomeSala.isNotEmpty) {
                  final docRef = FirebaseFirestore.instance
                      .collection('salas-participantes')
                      .doc(nomeSala);
                  final docSnapshot = await docRef.get();

                  if (!docSnapshot.exists) {
                    docRef.set({
                      'nome': nomeSala,
                      'email': _firebaseAuth.currentUser!.email,
                    }).then((_) {
                      Navigator.of(context).pop();
                    });
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sala já existe!')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _excluirSala(String salaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: const Text('Deseja realmente excluir esta sala?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Excluir'),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('salas-participantes')
                    .doc(salaId)
                    .delete()
                    .then((_) {
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erro ao excluir sala')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('salas-participantes')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Nenhuma sala encontrada!'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Algum erro desconhecido ocorreu'),
          );
        }

        final chatsCarregados = snapshot.data!.docs;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 219, 219, 219),
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text(
              'Turmas',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: () => _firebaseAuth.signOut(),
                icon: const Icon(Icons.exit_to_app),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: chatsCarregados.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  title: Text(chatsCarregados[index].id),
                  trailing: isAdmin
                      ? IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              _excluirSala(chatsCarregados[index].id),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TelaChat(chatId: chatsCarregados[index].id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          floatingActionButton: isAdmin
              ? FloatingActionButton(
                  onPressed: _adicionarNovaSala,
                  backgroundColor: const Color.fromRGBO(217, 148, 38, 1),
                  tooltip: 'Adicionar Nova Sala',
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}
