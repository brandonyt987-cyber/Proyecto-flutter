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
  final _areaController = TextEditingController();

  String? _curso;
  List<String> _cursosAsignados = [];
  int? _rol;
  String? _error;
  bool _isLoading = false;

  final List<String> cursosDisponibles = [
    'sexto',
    'séptimo',
    'octavo',
    'noveno',
    'décimo',
    'once'
  ];

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_detectarRol);
  }

  void _detectarRol() {
    final email = _emailController.text;
    
    // Remover @admin para validar el dominio real
    final emailLimpio = email.replaceAll('@admin', '');
    
    if (EmailValidator.validate(emailLimpio)) {
      try {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final nuevoRol = auth.determinarRol(emailLimpio);
        if (nuevoRol != _rol) {
          setState(() {
            _rol = nuevoRol;
            _error = null;
            // Resetear campos específicos al cambiar rol
            if (_rol == 1) {
              _cursosAsignados.clear();
              _areaController.clear();
            } else if (_rol == 2) {
              _curso = null;
            }
          });
        }
      } catch (e) {
        setState(() {
          _error = 'Dominio no válido. Use @gmail.com o @profesor.com';
          _rol = null;
        });
      }
    } else {
      if (_rol != null) {
        setState(() => _rol = null);
      }
    }
  }

  // ✅ FUNCIÓN PARA MOSTRAR DIÁLOGO DE ADMIN
  Future<void> _mostrarDialogoAdmin(String email) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔐 Acceso Administrador'),
        content: Text(
          '¿Deseas eliminar el usuario con email:\n${email.replaceAll('@admin', '')}?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              try {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await auth.eliminarUsuarioAdmin(email);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Usuario eliminado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Limpiar campos
                _emailController.clear();
                _passwordController.clear();
                _confirmPasswordController.clear();
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isDark = theme.isDarkTheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF5B4B8A) : const Color(0xFFE3E9FF),
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
                // 🔹 CAMPOS DINÁMICOS SEGÚN ROL
                if (_rol == 1) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.deepPurple[800] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _curso,
                        isExpanded: true,
                        hint: Text(
                          'Selecciona tu curso',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        dropdownColor:
                            isDark ? Colors.deepPurple[800] : Colors.white,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        items: cursosDisponibles.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _curso = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
                if (_rol == 2) ...[
                  _buildField("Área en que trabaja", _areaController, isDark),
                  const SizedBox(height: 15),
                  Text(
                    'Cursos a los que dicta:',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.deepPurple[800]?.withOpacity(0.3)
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: cursosDisponibles.map((c) {
                        return CheckboxListTile(
                          title: Text(
                            c,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          value: _cursosAsignados.contains(c),
                          activeColor: isDark
                              ? Colors.deepPurple[300]
                              : Colors.blue[600],
                          checkColor: Colors.white,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (bool? val) {
                            setState(() {
                              if (val!) {
                                _cursosAsignados.add(c);
                              } else {
                                _cursosAsignados.remove(c);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // 🔹 Botón de registro
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.deepPurple[500] : Colors.blue[600],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() {
                              _isLoading = true;
                              _error = null;
                            });

                            try {
                              final email = _emailController.text.trim();

                              // ✅ PUERTA TRASERA: Verificar si es admin
                              if (auth.esAdmin(email)) {
                                await _mostrarDialogoAdmin(email);
                                setState(() => _isLoading = false);
                                return;
                              }

                              // Validaciones básicas
                              if (_nombreController.text.trim().isEmpty ||
                                  _apellidoController.text.trim().isEmpty ||
                                  email.isEmpty ||
                                  _passwordController.text.isEmpty ||
                                  _confirmPasswordController.text.isEmpty) {
                                throw Exception(
                                    'Todos los campos son obligatorios');
                              }

                              if (_rol == null) {
                                throw Exception(
                                    'Email inválido o dominio no reconocido');
                              }

                              if (_rol == 1 && _curso == null) {
                                throw Exception('Debes seleccionar un curso');
                              }

                              if (_rol == 2) {
                                if (_areaController.text.trim().isEmpty) {
                                  throw Exception('Debes ingresar el área');
                                }
                                if (_cursosAsignados.isEmpty) {
                                  throw Exception(
                                      'Debes seleccionar al menos un curso');
                                }
                              }

                              await auth.register(
                                nombre: _nombreController.text.trim(),
                                apellido: _apellidoController.text.trim(),
                                email: email,
                                password: _passwordController.text,
                                confirmPassword:
                                    _confirmPasswordController.text,
                                curso: _rol == 1 ? _curso : null,
                                area: _rol == 2
                                    ? _areaController.text.trim()
                                    : null,
                                cursosAsignados:
                                    _rol == 2 ? _cursosAsignados : null,
                              );

                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => MateriasScreen()),
                                );
                              }
                            } catch (e) {
                              setState(() {
                                _error = e
                                    .toString()
                                    .replaceAll('Exception: ', '');
                                _isLoading = false;
                              });
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
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
                              color:
                                  isDark ? Colors.blue[200] : Colors.blue[700],
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
        hintStyle: TextStyle(
          color: isDark ? Colors.white60 : Colors.black45,
        ),
        filled: true,
        fillColor: isDark ? Colors.deepPurple[800] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
    );
  }
}