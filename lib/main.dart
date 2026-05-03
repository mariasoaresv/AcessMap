import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meuapp/pages/home_page.dart';

void main() async {
  await setup();
  runApp(const AcessMap());
}

Future<void> setup() async {
  await dotenv.load(fileName: '.env');
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
}

class AcessMap extends StatelessWidget {
  const AcessMap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.blue),
      initialRoute: '/homescreen',
      routes: {
        '/homescreen': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/cadastro': (context) => CriarContaScreen(),
        '/home': (context) => HomePage(),
        '/dados': (context) => DadosScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: Colors.white, size: 50),
            SizedBox(height: 10),
            Text(
              'AcessMap',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Mapa de acessibilidade urbana',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              style: botaoBranco(),
              child: Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

//---------------Login
class LoginScreen extends StatelessWidget {
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
                  MaterialPageRoute(builder: (_) => DadosScreen()),
                );
              },
              style: botaoBranco(),
              child: Text('Acessar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CriarContaScreen()),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: Text('Criar nova conta'),
            ),
          ],
        ),
      ),
    );
  }
}

// Senha , regras
class CriarContaScreen extends StatelessWidget {
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
                  MaterialPageRoute(builder: (_) => DadosScreen()),
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

class DadosScreen extends StatefulWidget {
  @override
  State<DadosScreen> createState() => _DadosScreenState();
}

class _DadosScreenState extends State<DadosScreen> {
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
      setState(() {
        idade = null;
      });
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
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Data (dd/mm/aaaa)',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text(
              idade == null ? 'Idade: -' : 'Idade: $idade',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text(
                'Possui deficiência?',
                style: TextStyle(color: Colors.white),
              ),
              value: temDeficiencia,
              onChanged: (valor) {
                setState(() {
                  temDeficiencia = valor;

                  if (!temDeficiencia) {
                    tipo = null;
                  }
                });
              },
            ),
            if (temDeficiencia)
              DropdownButtonFormField<String>(
                dropdownColor: Colors.blue,
                value:
                    ['Visual', 'Cadeirante', 'Baixa mobilidade'].contains(tipo)
                    ? tipo
                    : null,
                hint: Text('Selecione', style: TextStyle(color: Colors.white)),
                items: [
                  DropdownMenuItem(value: 'Visual', child: Text('Visual')),
                  DropdownMenuItem(
                    value: 'Cadeirante',
                    child: Text('Cadeirante'),
                  ),
                  DropdownMenuItem(
                    value: 'Baixa mobilidade',
                    child: Text('Baixa mobilidade'),
                  ),
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
                if (nome.text.isEmpty) {
                  mensagem(context, 'Digite seu nome');
                  return;
                }

                if (data.text.isEmpty || idade == null) {
                  mensagem(context, 'Digite uma data válida');
                  return;
                }

                if (temDeficiencia && tipo == null) {
                  mensagem(context, 'Selecione o tipo de deficiência');
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MenuScreen(nomeUsuario: nome.text),
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

class MenuScreen extends StatelessWidget {
  final String nomeUsuario;

  MenuScreen({required this.nomeUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarPadrao('Menu'),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Olá, $nomeUsuario',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            InkWell(
              onTap: () {
                mensagem(context, 'Abrindo mapa...');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(Icons.map, color: Colors.blue, size: 40),
                    SizedBox(width: 15),
                    Text(
                      'Acessar mapa',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget campoTexto(String label, TextEditingController controller, bool senha) {
  return TextField(
    controller: controller,
    obscureText: senha,
    style: TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      border: OutlineInputBorder(),
    ),
  );
}

PreferredSizeWidget appBarPadrao(String titulo) {
  return AppBar(
    title: Text(titulo),
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  );
}

ButtonStyle botaoBranco() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.blue,
  );
}

void mensagem(BuildContext context, String texto) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
}
