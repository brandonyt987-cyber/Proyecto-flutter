import 'package:flutter/material.dart';
import 'vista/crear_nota.dart';
import 'vista/theme_provider.dart';


// Clase principal
class MaterialScreen extends StatefulWidget {
  const MaterialScreen({Key? key}) : super(key: key);

  @override
  _MaterialScreenState createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();
  final List<map<String, dynamic>> _materias = [];

  void _AgregarMateria(String nombre) {
    setState(() {
      _materias.add({
        'nombre': nombre,
        'notas': [],
        'promedio': 0.0,
    });
  });
}

@override
 Widget build(BuildContext context) {
  return ListenableBuilder(
    listenable: _themeProvider,
    builder: (context, child) {
      return Scaffold(
        backgroundColor: _themeProvider.backgroundColor,
        appBar: AppBar(
          backgroundColor: _themeProvider.primaryColor,
          elevation: 0,
          title: Row(
            children: [
              const Text(
                'MyNote. ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Icon(
                _themeProvider.isDarkTheme ? Icons.nights_stay : Icons.wb_sunny,
                color: Colors.yellow,
                size: 24,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                _themeProvider.isDarkTheme ? Icons.wb_sunny : Icons.nights_stay,
                color: Colors.white,
              ),
              onPressed: (){
                _themeProvider.toggleTheme();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const edgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Materias',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _themeProvider.textColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buiildMenuCard(
                      context,
                      Icons. Icons.edit,
                      title: 'Nueva Materia',
                      onTap: ()
                    ),
                    ),
                ],
              ),
            ]
          )
        ),
      );
    }
  )
}
}