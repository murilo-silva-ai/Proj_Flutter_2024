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
  String _tipoUsuarioSelecionado = 'Aluno';
  static const List<String> _tipoUsuario = <String>[
    'Aluno',
    'Professor',
    'Coordenador'
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: Center(
            child: Column(
              children: [
                Image.network(
                    'https://unicv.edu.br/wp-content/uploads/2020/12/logo-verde-280X100.png',
                    width: 200,
                    height: 200),
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _chaveForm,
                    child: Column(
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 10)),
                        if (!_modoLogin) ...[
                          Row(
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: 165,
                                    child: TextFormField(
                                      obscureText: false,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Usuário',
                                      ),
                                      onSaved: (valor) {
                                        if (valor != null) {
                                          _nomeUsuario = valor;
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const Column(
                                children: [
                                  Padding(
                                      padding:
                                          EdgeInsets.only(left: 5, right: 2))
                                ],
                              ),
                              const Column(
                                children: [
                                  SizedBox(
                                    width: 150,
                                    child: DropdownMenuExample(
                                        tipoUsuario: _tipoUsuario),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.only(top: 10)),
                        ],
                        Column(
                          children: [
                            SizedBox(
                              width: 500,
                              child: TextFormField(
                                obscureText: false,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'E-mail',
                                ),
                                onSaved: (valorDigitado) {
                                  if (valorDigitado != null) {
                                    _email = valorDigitado;
                                  }
                                },
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(top: 10)),
                            SizedBox(
                              width: 500,
                              child: TextFormField(
                                obscureText: true,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Senha',
                                ),
                                onSaved: (valor) {
                                  if (valor != null) {
                                    _senha = valor;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 5)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 165,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!_chaveForm.currentState!.validate()) {
                                    return;
                                  }
                                  _chaveForm.currentState!.save();

                                  try {
                                    if (_modoLogin) {
                                      // Logar usuário
                                      print(
                                          'Usuario com email $_email e senha $_senha Logado!');
                                      await _firebaseAuth
                                          .signInWithEmailAndPassword(
                                              email: _email, password: _senha);
                                    } else {
                                      print(
                                          'Usuario $_nomeUsuario criado com email $_email e senha $_senha. Tipo de usuario: $_tipoUsuarioSelecionado');
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
                                        'senha': _senha,
                                        'usuario': _nomeUsuario,
                                        'tipoUsuario': _tipoUsuarioSelecionado
                                      });
                                    }
                                  } on FirebaseAuthException catch (error) {
                                    String mensagem =
                                        'Falha no Registro de novo Usuário';
                                    if (error.code == 'email-already-in-use') {
                                      mensagem = 'Email já utilizado';
                                    }
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: _modoLogin
                                            ? const Text('Falha no Login')
                                            : Text(mensagem),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor:
                                      const Color.fromARGB(255, 0, 0, 0),
                                  backgroundColor:
                                      const Color.fromRGBO(217, 148, 38, 1),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                child: _modoLogin
                                    ? const Text('Entrar')
                                    : const Text('Salvar'),
                              ),
                            ),
                            const Column(
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(left: 5, right: 2))
                              ],
                            ),
                            SizedBox(
                              width: 170,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _modoLogin = !_modoLogin;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor:
                                      const Color.fromARGB(255, 0, 0, 0),
                                  backgroundColor:
                                      const Color.fromRGBO(217, 148, 38, 1),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                child: _modoLogin
                                    ? const Text('Criar uma conta')
                                    : const Text('Já tenho uma conta'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class DropdownMenuExample extends StatefulWidget {
  final List<String> tipoUsuario;

  const DropdownMenuExample({super.key, required this.tipoUsuario});

  @override
  State<DropdownMenuExample> createState() => _DropdownMenuExampleState();
}

class _DropdownMenuExampleState extends State<DropdownMenuExample> {
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.tipoUsuario.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: widget.tipoUsuario.first,
      onSelected: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
      },
      dropdownMenuEntries:
          widget.tipoUsuario.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );
  }
}
