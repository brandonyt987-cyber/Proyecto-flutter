import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/materia_provider.dart';
import 'providers/notas_provider.dart';
import 'providers/theme_provider.dart';
import 'vista/login_screen.dart';
import 'services/database_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔥 SOLO PARA DESARROLLO: Borra la BD al iniciar
  //await DatabaseService.instance.deleteDatabase();
  
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
            home: LoginScreen(),
          );
        },
      ),
    );
  }
}