import 'package:flutter/material.dart';
import '../utils.dart';

class MenuPage extends StatelessWidget {
  final String nomeUsuario;

  MenuPage({required this.nomeUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarPadrao('Menu'),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Olá, $nomeUsuario',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}