import 'package:flutter/material.dart';
import 'theme_provider.dart';

class CrearMateria extends StatefulWidget {
  final ThemeProvider themeProvider;
  
  const CrearMateriaScreen({
    Key? key,
    required this.themeProvider,
  }) : super(key: key);

  @override
  _CrearMateriaScreenState createState() => _CrearMateriaScreenState();
}