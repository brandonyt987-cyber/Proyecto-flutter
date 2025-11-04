// vistas/register_screen.dart: Nueva pantalla de registro con validaciones paso a paso, roles por dominio, formularios condicionales.

import 'package:email_validator/email_validator.dart';  // Import para validar emails
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'materias.dart';

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

  final _nombreFocus = FocusNode();
  final _apellidoFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  String? _curso;
  String? _area;
  List<String> _cursosAsignados = [];
  int? _rol;
  String? _error;

  final List<String> cursosDisponibles = ['sexto', 'séptimo', 'octavo', 'noveno', 'décimo', 'once'];

  @override
  void initState() {
    super.initState();
    _nombreController.addListener(() => _validarYAvanzar(_nombreController, _apellidoFocus));
    _apellidoController.addListener(() => _validarYAvanzar(_apellidoController, _emailFocus));
    _emailController.addListener(() => _validarYAvanzar(_emailController, _passwordFocus));  // Validación gradual para email
    _passwordController.addListener(() => _validarYAvanzar(_passwordController, _confirmPasswordFocus));
  }

  void _validarYAvanzar(TextEditingController controller, FocusNode nextFocus) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      if (controller == _nombreController || controller == _apellidoController) {
        if (!auth.validarNombreApellido(controller.text)) throw Exception('Nombre/Apellido inválido: solo letras y espacios, min 3 chars');
      } else if (controller == _emailController) {
        final email = controller.text;
        if (email.isNotEmpty && !EmailValidator.validate(email)) {
          throw Exception('Correo electrónico inválido');
        } else if (EmailValidator.validate(email)) {  // Solo determina rol si es válido
          _rol = auth.determinarRol(email);
          setState(() {});
        }
      } else if (controller == _passwordController) {
        if (!auth.validarPassword(controller.text)) throw Exception('Contraseña débil: min 8 chars, mayús, minús, número, especial');
      }
      setState(() => _error = null);
      FocusScope.of(context).requestFocus(nextFocus);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text('Registro', style: TextStyle(color: theme.textColor)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              focusNode: _nombreFocus,
              decoration: InputDecoration(
                labelText: 'Nombre',
                filled: true,
                fillColor: theme.cardColor,
                labelStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
              ),
              style: TextStyle(color: theme.textColor),
            ),
            TextField(
              controller: _apellidoController,
              focusNode: _apellidoFocus,
              decoration: InputDecoration(
                labelText: 'Apellido',
                filled: true,
                fillColor: theme.cardColor,
                labelStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
              ),
              style: TextStyle(color: theme.textColor),
            ),
            TextField(
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,  // Corregido: Permite ingreso completo de emails con @, etc.
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                filled: true,
                fillColor: theme.cardColor,
                labelStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
              ),
              style: TextStyle(color: theme.textColor),
            ),
            TextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                filled: true,
                fillColor: theme.cardColor,
                labelStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
              ),
              style: TextStyle(color: theme.textColor),
            ),
            TextField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmar Contraseña',
                filled: true,
                fillColor: theme.cardColor,
                labelStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
              ),
              style: TextStyle(color: theme.textColor),
            ),
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
            if (_rol == 1)  // Estudiante
              DropdownButton<String>(
                value: _curso,
                hint: Text('Selecciona tu curso', style: TextStyle(color: theme.textColor)),
                items: cursosDisponibles.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: theme.textColor)))).toList(),
                onChanged: (v) => setState(() => _curso = v),
              ),
            if (_rol == 2)  // Profesor
              Column(
                children: [
                  TextField(
                    onChanged: (v) => _area = v,
                    decoration: InputDecoration(
                      labelText: 'Área en que trabaja',
                      filled: true,
                      fillColor: theme.cardColor,
                      labelStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
                    ),
                    style: TextStyle(color: theme.textColor),
                  ),
                  Text('Cursos a los que dicta:', style: TextStyle(color: theme.textColor)),
                  ...cursosDisponibles.map((c) => CheckboxListTile(
                    title: Text(c, style: TextStyle(color: theme.textColor)),
                    value: _cursosAsignados.contains(c),
                    onChanged: (bool? val) {
                      setState(() {
                        if (val!) _cursosAsignados.add(c);
                        else _cursosAsignados.remove(c);
                      });
                    },
                  )),
                ],
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
              onPressed: () async {
                try {
                  await Provider.of<AuthProvider>(context, listen: false).register(
                    nombre: _nombreController.text,
                    apellido: _apellidoController.text,
                    email: _emailController.text,
                    password: _passwordController.text,
                    confirmPassword: _confirmPasswordController.text,
                    curso: _curso,
                    area: _area,
                    cursosAsignados: _cursosAsignados,
                  );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MateriasScreen()));
                } catch (e) {
                  setState(() => _error = e.toString());
                }
              },
              child: Text('Registrarse', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}