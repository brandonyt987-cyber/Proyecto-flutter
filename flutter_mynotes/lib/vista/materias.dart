// Modificación a vistas/materias.dart: Renombrar a materias_screen.dart para consistencia. Integrar con providers (Auth, Materias, Theme). Diferenciar por rol. Usar BD en vez de lista local. Incluir formulario para crear materia en lugar de dialog (modificar crear_materia.dart a widget inline o integrarlo).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/profesor.dart';
import '../providers/materia_provider.dart';  // Corregido: Plural 'materias_provider.dart'
import '../providers/theme_provider.dart';
import 'notas_screen.dart';

class MateriasScreen extends StatefulWidget {
  @override
  _MateriasScreenState createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final materiasProv = Provider.of<MateriasProvider>(context, listen: false);
    if (auth.usuarioActual!.rol == 2) {
      materiasProv.loadMateriasForProfesor(auth.profesorActual!.id);  // Usar profesorActual.id
    } else {
      materiasProv.loadMateriasForEstudiante(auth.estudianteActual!.curso);  // Usar estudianteActual.curso
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final materiasProv = Provider.of<MateriasProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final usuario = auth.usuarioActual!;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text('Materias', style: TextStyle(color: theme.textColor)),
        actions: [
          IconButton(
            icon: Icon(theme.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            onPressed: theme.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: auth.logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Materias',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 20),
            if (usuario.rol == 2) _buildFormularioCrearMateria(context, auth.profesorActual!, theme, materiasProv),
            Expanded(
              child: materiasProv.materias.isEmpty
                  ? Center(
                      child: Text(
                        'No hay materias',
                        style: TextStyle(color: theme.textColor.withOpacity(0.6), fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: materiasProv.materias.length,
                      itemBuilder: (_, i) {
                        final materia = materiasProv.materias[i];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotasScreen(materiaId: materia.id!),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  materia.nombre,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.textColor,
                                  ),
                                ),
                                Text(
                                  'Profesor: ${usuario.nombre} ${usuario.apellido}',
                                  style: TextStyle(color: theme.textColor),
                                ),
                                Text(
                                  'Horario: ${materia.horarioInicio} - ${materia.horarioFin}',
                                  style: TextStyle(color: theme.textColor),
                                ),
                                Text(
                                  'Días: ${materia.dias.join(', ')}',
                                  style: TextStyle(color: theme.textColor),
                                ),
                                Text(
                                  'Salón: ${materia.salon}',
                                  style: TextStyle(color: theme.textColor),
                                ),
                                Text(
                                  'Cursos: ${materia.cursosAsignados.join(', ')}',
                                  style: TextStyle(color: theme.textColor),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioCrearMateria(BuildContext context, Profesor profesor, ThemeProvider theme, MateriasProvider materiasProv) {
    final _nombreController = TextEditingController();
    List<String> _diasSeleccionados = [];
    final _horarioInicioController = TextEditingController();
    final _horarioFinController = TextEditingController();
    int? _salon;
    List<String> _cursosAsignados = [];
    String? _error;

    final materiasDisponibles = ['matemáticas', 'sociales', 'inglés', 'ciencias naturales'];

    return Column(
      children: [
        DropdownButton<String>(
          hint: Text('Nombre de la materia', style: TextStyle(color: theme.textColor)),
          items: materiasDisponibles.map((m) => DropdownMenuItem(value: m, child: Text(m, style: TextStyle(color: theme.textColor)))).toList(),
          onChanged: (v) => _nombreController.text = v!,
        ),
        Text('Días de clase:', style: TextStyle(color: theme.textColor)),
        ...['lunes', 'martes', 'miércoles', 'jueves', 'viernes'].map((d) => CheckboxListTile(
          title: Text(d, style: TextStyle(color: theme.textColor)),
          value: _diasSeleccionados.contains(d),
          onChanged: (val) {
            setState(() {
              if (val!) _diasSeleccionados.add(d);
              else _diasSeleccionados.remove(d);
            });
          },
        )),
        TextField(
          controller: _horarioInicioController,
          decoration: InputDecoration(
            labelText: 'Horario inicio (HH:MM)',
            filled: true,
            fillColor: theme.cardColor,
            labelStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
          ),
          style: TextStyle(color: theme.textColor),
        ),
        TextField(
          controller: _horarioFinController,
          decoration: InputDecoration(
            labelText: 'Horario fin (HH:MM)',
            filled: true,
            fillColor: theme.cardColor,
            labelStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
          ),
          style: TextStyle(color: theme.textColor),
        ),
        DropdownButton<int>(
          hint: Text('Salón (1-7)', style: TextStyle(color: theme.textColor)),
          items: List.generate(7, (i) => DropdownMenuItem(value: i+1, child: Text('${i+1}', style: TextStyle(color: theme.textColor)))),
          onChanged: (v) => _salon = v,
        ),
        Text('Cursos asignados:', style: TextStyle(color: theme.textColor)),
        ...profesor.cursosAsignados.map((c) => CheckboxListTile(  // Usar profesor.cursosAsignados
          title: Text(c, style: TextStyle(color: theme.textColor)),
          value: _cursosAsignados.contains(c),
          onChanged: (val) {
            setState(() {
              if (val!) _cursosAsignados.add(c);
              else _cursosAsignados.remove(c);
            });
          },
        )),
        if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
          onPressed: () async {
            try {
              await materiasProv.crearMateria(
                nombre: _nombreController.text,
                profesorId: profesor.id,  // Usar profesor.id
                dias: _diasSeleccionados,
                horarioInicio: _horarioInicioController.text,
                horarioFin: _horarioFinController.text,
                salon: _salon!,
                cursosAsignados: _cursosAsignados,
              );
              setState(() {});  // Recargar lista
            } catch (e) {
              setState(() => _error = e.toString());
            }
          },
          child: Text('Crear Materia', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}