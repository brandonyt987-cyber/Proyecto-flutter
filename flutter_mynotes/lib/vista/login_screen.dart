// vistas/login_screen.dart: Nueva pantalla de login, integrada con AuthProvider y ThemeProvider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'materias.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text('Login', style: TextStyle(color: theme.textColor)),
        actions: [
          IconButton(
            icon: Icon(theme.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            onPressed: theme.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                labelStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
                filled: true,
                fillColor: theme.cardColor,
              ),
              style: TextStyle(color: theme.textColor),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
                filled: true,
                fillColor: theme.cardColor,
              ),
              style: TextStyle(color: theme.textColor),
            ),
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
              onPressed: () async {
                try {
                  await auth.login(_emailController.text, _passwordController.text);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MateriasScreen()));
                } catch (e) {
                  setState(() => _error = e.toString());
                }
              },
              child: Text('Iniciar Sesión', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
              child: Text('Registrarse', style: TextStyle(color: theme.primaryColor)),
            ),
          ],
        ),
      ),
    );
  }
}