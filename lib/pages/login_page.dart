import 'package:flutter/material.dart';
import 'cadastro_page.dart';
import 'dados_page.dart';
import '../utils.dart';

class LoginPage extends StatelessWidget {
  final email = TextEditingController();
  final senha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarPadrao('Login'),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            campoTexto('E-mail', email, false),
            SizedBox(height: 10),
            campoTexto('Senha', senha, true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (email.text.isEmpty || senha.text.isEmpty) {
                  mensagem(context, 'Preencha todos os campos');
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DadosPage()),
                );
              },
              style: botaoBranco(),
              child: Text('Acessar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CadastroPage()),
                );
              },
              child: Text('Criar nova conta'),
            ),
          ],
        ),
      ),
    );
  }
}