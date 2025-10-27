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