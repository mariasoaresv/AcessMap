import 'package:flutter/material.dart';
import 'menu_page.dart';
import '../utils.dart';

class DadosPage extends StatefulWidget {
  @override
  State<DadosPage> createState() => _DadosPageState();
}

class _DadosPageState extends State<DadosPage> {
  final nome = TextEditingController();
  final data = TextEditingController();

  int? idade;
  bool temDeficiencia = false;
  String? tipo;

  void calcularIdade(String texto) {
    try {
      var partes = texto.split('/');
      int ano = int.parse(partes[2]);

      setState(() {
        idade = DateTime.now().year - ano;
      });
    } catch (e) {
      idade = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarPadrao('Dados pessoais'),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            campoTexto('Nome', nome, false),
            SizedBox(height: 10),
            TextField(
              controller: data,
              onChanged: calcularIdade,
            ),
            SizedBox(height: 10),
            Text(
              idade == null ? 'Idade: -' : 'Idade: $idade',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Possui deficiência?'),
              value: temDeficiencia,
              onChanged: (valor) {
                setState(() {
                  temDeficiencia = valor;
                  if (!temDeficiencia) tipo = null;
                });
              },
            ),
            if (temDeficiencia)
              DropdownButtonFormField<String>(
                value: tipo,
                items: [
                  DropdownMenuItem(value: 'Visual', child: Text('Visual')),
                  DropdownMenuItem(value: 'Cadeirante', child: Text('Cadeirante')),
                  DropdownMenuItem(value: 'Baixa mobilidade', child: Text('Baixa mobilidade')),
                ],
                onChanged: (valor) {
                  setState(() {
                    tipo = valor;
                  });
                },
              ),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MenuPage(nomeUsuario: nome.text),
                  ),
                );
              },
              style: botaoBranco(),
              child: Text('Finalizar'),
            ),
          ],
        ),
      ),
    );
  }
}