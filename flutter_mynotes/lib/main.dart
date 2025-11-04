import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'providers/auth_provider.dart';
import 'providers/materia_provider.dart';
import 'providers/notas_provider.dart';
import 'providers/theme_provider.dart';
import 'vista/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🧩 Inicializar sqflite_common_ffi para escritorio
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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
            theme: themeProvider.isDarkTheme
                ? ThemeData.dark()
                : ThemeData.light(),
            home: LoginScreen(), // Pantalla inicial
          );
        },
      ),
    );
  }
}
