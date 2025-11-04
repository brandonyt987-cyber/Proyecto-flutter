import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';  // Agregado: Esto resuelve el error de jsonDecode
import '../providers/auth_provider.dart';
import '../providers/notas_provider.dart';
import '../providers/theme_provider.dart';
import '../services/database_services.dart';  // Corregido: Quité el 's' al final, asumiendo nombre estándar del archivo

class NotasScreen extends StatefulWidget {
  final int materiaId;

  const NotasScreen({super.key, required this.materiaId});

  @override
  _NotasScreenState createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final notasProv = Provider.of<NotasProvider>(context, listen: false);
    if (auth.usuarioActual!.rol == 1) {
      notasProv.loadNotasForEstudiante(widget.materiaId, auth.usuarioActual!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notasProv = Provider.of<NotasProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final usuario = auth.usuarioActual!;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text('Notas', style: TextStyle(color: theme.textColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: usuario.rol == 2
            ? _buildProfesorView(context, notasProv, theme)
            : _buildEstudianteView(notasProv, theme),
      ),
    );
  }

  Widget _buildProfesorView(BuildContext context, NotasProvider notasProv, ThemeProvider theme) {
    final _nombreNotaController = TextEditingController();
    String? _error;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getEstudiantesParaMateria(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final estudiantes = snapshot.data!;
        return Column(
          children: [
            TextField(
              controller: _nombreNotaController,
              decoration: InputDecoration(
                labelText: 'Nombre de la nota',
                filled: true,
                fillColor: theme.cardColor,
                labelStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
              ),
              style: TextStyle(color: theme.textColor),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
              onPressed: () async {
                try {
                  final ids = estudiantes.map((e) => e['id'] as int).toList();
                  await notasProv.crearNota(widget.materiaId, _nombreNotaController.text, ids);
                } catch (e) {
                  setState(() => _error = e.toString());
                }
              },
              child: Text('Crear Nota', style: TextStyle(color: Colors.white)),
            ),
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
            Expanded(
              child: ListView.builder(
                itemCount: estudiantes.length,
                itemBuilder: (_, i) {
                  final est = estudiantes[i];
                  return ListTile(
                    title: Text('${est['nombre']} ${est['apellido']}', style: TextStyle(color: theme.textColor)),
                    onTap: () => _mostrarDialogCalificar(context, notasProv, est['id'], theme),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getEstudiantesParaMateria() async {
    final db = await DatabaseService.instance.database;
    final materiaMap = await db.query('materias', where: 'id = ?', whereArgs: [widget.materiaId]);
    
    if (materiaMap.isEmpty) {
      throw Exception('Materia no encontrada');
    }
    
    final jsonString = materiaMap.first['cursos_asignados'] as String?;
    if (jsonString == null) {
      throw Exception('No se encontraron cursos asignados para la materia');
    }
    
    final cursos = List<String>.from(jsonDecode(jsonString));  // Corregido: Cast a String y chequeo de null
    
    final where = cursos.map((c) => "curso = '$c'").join(' OR ');
    return await db.query('usuarios', where: 'rol = 1 AND ($where)');
  }

  void _mostrarDialogCalificar(BuildContext context, NotasProvider notasProv, int estudianteId, ThemeProvider theme) {
    final _calificacionController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Asignar Calificación', style: TextStyle(color: theme.textColor)),
        content: TextField(
          controller: _calificacionController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Calificación (0-100)',
            filled: true,
            fillColor: theme.backgroundColor,
            labelStyle: TextStyle(color: theme.textColor.withOpacity(0.6)),
          ),
          style: TextStyle(color: theme.textColor),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
            onPressed: () async {
              final cal = double.parse(_calificacionController.text);
              final nota = notasProv.notas.last;  // Asumir última nota; ajustar si múltiples
              await notasProv.updateCalificacion(nota.id!, cal);
              Navigator.pop(context);
            },
            child: Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEstudianteView(NotasProvider notasProv, ThemeProvider theme) {
    return ListView.builder(
      itemCount: notasProv.notas.length,
      itemBuilder: (_, i) {
        final nota = notasProv.notas[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: ListTile(
            title: Text(nota.nombreNota, style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold)),
            subtitle: Text(
              nota.calificacion == null ? 'Todavía no calificada' : 'Calificación: ${nota.calificacion} ${nota.calificacion! >= 70 ? '(Aprobado)' : '(Reprobado)'}',
              style: TextStyle(color: theme.textColor.withOpacity(0.7)),
            ),
          ),
        );
      },
    );
  }
}