import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'materias.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
        child: SingleChildScrollView(
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
                // 🔹 Encabezado con logo y botón de tema
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.note_alt_rounded,
                      size: 28,
                      color: Colors.white,
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
                  child: const Icon(
                    Icons.person,
                    size: 35,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 25),

                // 🔹 Título
                Text(
                  "Regístrate",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),

                const SizedBox(height: 25),

                // 🔹 Campos de texto
                _buildField("Nombre", _nombreController, isDark),
                const SizedBox(height: 10),
                _buildField("Apellido", _apellidoController, isDark),
                const SizedBox(height: 10),
                _buildField("Correo", _emailController, isDark, email: true),
                const SizedBox(height: 10),
                _buildField(
                  "Contraseña",
                  _passwordController,
                  isDark,
                  obscure: true,
                ),
                const SizedBox(height: 10),
                _buildField(
                  "Confirmar contraseña",
                  _confirmPasswordController,
                  isDark,
                  obscure: true,
                ),

                const SizedBox(height: 15),

                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),

                // 🔹 Botón de registro
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
                        await auth.register(
                          nombre: _nombreController.text,
                          apellido: _apellidoController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                          confirmPassword: _confirmPasswordController.text,
                          curso: null,
                          area: null,
                          cursosAsignados: [],
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
                      'Registrarte',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // 🔹 Enlace de regreso a login
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: "¿Ya tienes cuenta? "),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          ),
                          child: Text(
                            "inicia sesión aquí.",
                            style: TextStyle(
                              color: isDark
                                  ? Colors.blue[200]
                                  : Colors.blue[700],
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

  Widget _buildField(
    String hint,
    TextEditingController controller,
    bool isDark, {
    bool obscure = false,
    bool email = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? Colors.deepPurple[800] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
    );
  }
}
