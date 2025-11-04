// Modificación a main.dart: Integrar MultiProvider para Auth, Materias, Notas y Theme. Cambiar home a LoginScreen. Mantener el tema oscuro/claro, pero usar ThemeProvider. Navegación inicial a login.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/materia_provider.dart';
import 'providers/notas_provider.dart';
import 'providers/theme_provider.dart';
import 'vista/login_screen.dart';

void main() {
  runApp(const MyNoteApp());
}

class MyNoteApp extends StatelessWidget {
  const MyNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MateriasProvider()),
        ChangeNotifierProvider(create: (_) => NotasProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
            home: LoginScreen(),  // Cambiado a pantalla de login
          );
        },
      ),
    );
  }
}