import 'package:flutter/material.dart';


void main(List<String> args) {
  runApp(const MaterialApp(
    home: MateriasScreen(),
  ));
}

class MateriasScreen extends StatelessWidget {
  const MateriasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materias'),
      ),
      body: const Center(
        child: Text('Lista de Materias'),
      ),
    );
  }
}