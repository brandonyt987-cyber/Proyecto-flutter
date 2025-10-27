import 'package:flutter/material.dart';


void main(List<String> args) {
  runApp(const MaterialApp(
    home: MateriasScreen(),
  ));
}

class MateriasScreen extends StatefulWidget {
  const MateriasScreen({Key? key}) : super(key: key);
  
  @override
  _MateriasScreenState createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
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