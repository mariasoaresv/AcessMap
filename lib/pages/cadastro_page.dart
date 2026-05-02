import 'package:flutter/material.dart';
import 'dados_page.dart';
import '../utils.dart';

class CadastroPage extends StatelessWidget {
  final email = TextEditingController();
  final senha = TextEditingController();
  final confirmar = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarPadrao('Criar Conta'),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            campoTexto('E-mail', email, false),
            SizedBox(height: 10),
            campoTexto('Senha', senha, true),
            SizedBox(height: 10),
            campoTexto('Confirmar senha', confirmar, true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (email.text.isEmpty ||
                    senha.text.isEmpty ||
                    confirmar.text.isEmpty) {
                  mensagem(context, 'Preencha todos os campos');
                  return;
                }

                if (senha.text != confirmar.text) {
                  mensagem(context, 'Senhas não conferem');
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DadosPage()),
                );
              },
              style: botaoBranco(),
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}