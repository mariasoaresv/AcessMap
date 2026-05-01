import 'package:flutter/material.dart';

Widget campoTexto(String label, TextEditingController controller, bool senha) {
  return TextField(
    controller: controller,
    obscureText: senha,
    decoration: InputDecoration(labelText: label),
  );
}

PreferredSizeWidget appBarPadrao(String titulo) {
  return AppBar(title: Text(titulo));
}

ButtonStyle botaoBranco() {
  return ElevatedButton.styleFrom();
}

void mensagem(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(texto)));
}