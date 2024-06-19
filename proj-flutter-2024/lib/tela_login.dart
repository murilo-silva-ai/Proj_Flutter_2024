import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebaseAuth = FirebaseAuth.instance;

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _chaveForm = GlobalKey<FormState>();
  var _email = '';
  var _senha = '';
  var _nomeUsuario = '';
  var _modoLogin = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 30, 100, 32),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    width: 200,
                    child: const Icon(
                      Icons.message,
                      size: 200,
                      color: Colors.white,
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _chaveForm,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Endereço de Email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (valor) {
                                if (valor == null ||
                                    valor.trim().isEmpty ||
                                    !valor.contains('@')) {
                                  return 'Por favor, insira um endereço de email válido!';
                                }
                                return null;
                              },
                              onSaved: (valorDigitado) {
                                if (valorDigitado != null) {
                                  _email = valorDigitado;
                                }
                              },
                            ),
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Senha'),
                              obscureText: true,
                              validator: (valor) {
                                if (valor == null || valor.trim().length < 6) {
                                  return 'A senha deve ter pelo menos 6 caracteres.';
                                }
                                return null;
                              },
                              onSaved: (valor) {
                                if (valor != null) {
                                  _senha = valor;
                                }
                              },
                            ),
                            if (!_modoLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Nome de Usuário'),
                                validator: (valor) {
                                  if (valor == null ||
                                      valor.trim().length < 4) {
                                    return 'O nome de usuário deve ter pelo menos 4 caracteres.';
                                  }
                                  return null;
                                },
                                onSaved: (valor) {
                                  if (valor != null) {
                                    _nomeUsuario = valor;
                                  }
                                },
                              ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    if (!_chaveForm.currentState!.validate()) {
                                      return;
                                    }
                                    _chaveForm.currentState!.save();

                                    try {
                                      if (_modoLogin) {
                                        //logar usuário
                                        print(
                                            'Usuario com email $_email e senha $_senha Logado!');
                                        await _firebaseAuth
                                            .signInWithEmailAndPassword(
                                                email: _email,
                                                password: _senha);
                                      } else {
                                        //criar usuário
                                        print(
                                            'Usuario $_nomeUsuario criado com email $_email e senha $_senha');
                                        final credenciaisUsuario =
                                            await _firebaseAuth
                                                .createUserWithEmailAndPassword(
                                                    email: _email,
                                                    password: _senha);

                                        await FirebaseFirestore.instance
                                            .collection('usuarios')
                                            .doc(credenciaisUsuario.user!.uid)
                                            .set({
                                          'email': _email,
                                          'isAdmin': false,
                                          'usuario': _nomeUsuario,
                                        });
                                      }
                                    } on FirebaseAuthException catch (error) {
                                      String mensagem =
                                          'Falha no Registro de novo Usuário';
                                      if (error.code ==
                                          'email-already-in-use') {
                                        mensagem = 'Email já utilizado';
                                      }
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: _modoLogin
                                              ? const Text('Falha no Login')
                                              : Text(mensagem),
                                        ),
                                      );
                                    }
                                  },
                                  child: _modoLogin
                                      ? const Text('Entrar')
                                      : const Text('Salvar'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _modoLogin = !_modoLogin;
                                    });
                                  },
                                  child: _modoLogin
                                      ? const Text('Criar uma conta')
                                      : const Text('Já tenho uma conta'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
