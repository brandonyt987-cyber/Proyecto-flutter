import 'package:email_validator/email_validator.dart';
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
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false); // ✅ listen: false
    final isDark = theme.isDarkTheme;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF5B4B8A)
          : const Color(0xFFE3E9FF),
      body: Center(
        child: SingleChildScrollView( // ✅ Agregado para evitar overflow
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF4A3C73) : const Color(0xFFBBD3FF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
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
                      color: Colors.white, // ✅ Siempre blanco para contraste
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
                  child: const Icon(Icons.person, size: 35, color: Colors.white),
                ),

                const SizedBox(height: 25),

                // 🔹 Título "Inicia sesión"
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
                  keyboardType: TextInputType.emailAddress, // ✅ Agregado
                  decoration: InputDecoration(
                    hintText: "Correo",
                    hintStyle: TextStyle( // ✅ Agregado para mejor visibilidad
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.deepPurple[800] : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16, // ✅ Agregado padding vertical
                    ),
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
                    hintStyle: TextStyle( // ✅ Agregado
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.deepPurple[800] : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16, // ✅ Agregado
                    ),
                  ),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),

                const SizedBox(height: 15),

                // 🔹 Mensaje de error
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

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
                    onPressed: _isLoading // ✅ Deshabilitar mientras carga
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                              _error = null;
                            });

                            try {
                              final email = _emailController.text.trim(); // ✅ trim
                              final password = _passwordController.text;

                              // ✅ Validaciones básicas
                              if (email.isEmpty || password.isEmpty) {
                                throw Exception('Por favor completa todos los campos');
                              }

                              if (!EmailValidator.validate(email)) {
                                throw Exception('Email inválido');
                              }

                              // Intentar login
                              print('🔐 Intentando login con: $email');
                              await auth.login(email, password);
                              print('✅ Login exitoso');

                              if (mounted) { // ✅ Verificar si el widget sigue montado
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MateriasScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              print('❌ Error en login: $e');
                              setState(() {
                                _error = e.toString().replaceAll('Exception: ', '');
                                _isLoading = false;
                              });
                            }
                          },
                    child: _isLoading // ✅ Mostrar indicador de carga
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
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
                          onTap: () => Navigator.pushReplacement( // ✅ pushReplacement
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
      ),
    );
  }
}