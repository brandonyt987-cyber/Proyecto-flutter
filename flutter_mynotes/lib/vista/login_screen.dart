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
    final isDark = theme.isDarkTheme;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF5B4B8A)
          : const Color(0xFFE3E9FF),
      body: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF4A3C73) : const Color(0xFFBBD3FF),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Encabezado con logo y cambio de tema
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_alt_rounded,
                    color: isDark ? Colors.white : Colors.black,
                    size: 28,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "MyNote.",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: theme.toggleTheme,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // 🔹 Ícono de usuario
              CircleAvatar(
                radius: 28,
                backgroundColor: isDark ? Colors.white24 : Colors.black26,
                child: Icon(Icons.person, size: 35, color: Colors.white),
              ),

              const SizedBox(height: 25),

              // 🔹 Título “Inicia sesión”
              Text(
                "Inicia sesión",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 25),

              // 🔹 Campo correo
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Correo",
                  filled: true,
                  fillColor: isDark ? Colors.deepPurple[800] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),

              const SizedBox(height: 15),

              // 🔹 Campo contraseña
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Contraseña",
                  filled: true,
                  fillColor: isDark ? Colors.deepPurple[800] : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),

              const SizedBox(height: 20),

              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),

              // 🔹 Botón iniciar sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.deepPurple[500]
                        : Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await auth.login(
                        _emailController.text,
                        _passwordController.text,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => MateriasScreen()),
                      );
                    } catch (e) {
                      setState(() => _error = e.toString());
                    }
                  },
                  child: const Text(
                    'Inicia sesión',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 🔹 Enlace de registro
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 14,
                  ),
                  children: [
                    const TextSpan(text: "¿No tienes cuenta? "),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        ),
                        child: Text(
                          "regístrate aquí.",
                          style: TextStyle(
                            color: isDark ? Colors.blue[200] : Colors.blue[700],
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
