import 'package:flutter/material.dart';
import '../provider/theme_provider.dart';

class CrearMateria extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  const CrearMateria({
    Key? key,
    required this.themeProvider,
  }) : super(key: key);

  @override
  _CrearMateriaState createState() => _CrearMateriaState();
}

class _CrearMateriaState extends State<CrearMateria> {
  final TextEditingController _nombreController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _guardarMateria() {
    if (_nombreController.text.isNotEmpty) {
      Navigator.pop(context, _nombreController.text.trim());
    } else {
      // Manejar el caso en que el nombre esté vacío
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('por favor ingresa un nombre para la materia'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}