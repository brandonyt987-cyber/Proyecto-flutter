import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../providers/notas_provider.dart';
import '../providers/theme_provider.dart';
import '../services/database_services.dart';

class NotasScreen extends StatefulWidget {
  final int materiaId;

  const NotasScreen({super.key, required this.materiaId});

  @override
  _NotasScreenState createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Map<String, dynamic>> _estudiantes = [];
  List<String> _notasCreadas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    if (auth.usuarioActual!.rol == 2) {
      // Profesor: 3 pestañas
      _tabController = TabController(length: 3, vsync: this);
      _cargarDatosProfesor();
    } else {
      // Estudiante: cargar sus notas
      final notasProv = Provider.of<NotasProvider>(context, listen: false);
      notasProv.loadNotasForEstudiante(widget.materiaId, auth.estudianteActual!.id);
      _isLoading = false;
    }
  }

  Future<void> _cargarDatosProfesor() async {
    setState(() => _isLoading = true);
    try {
      _estudiantes = await _getEstudiantesParaMateria();
      _notasCreadas = await _getNotasCreadas();
    } catch (e) {
      print('Error cargando datos: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<List<Map<String, dynamic>>> _getEstudiantesParaMateria() async {
    final db = await DatabaseService.instance.database;
    final materiaMap = await db.query('materias', where: 'id = ?', whereArgs: [widget.materiaId]);
    
    if (materiaMap.isEmpty) throw Exception('Materia no encontrada');
    
    final jsonString = materiaMap.first['cursos_asignados'] as String?;
    if (jsonString == null) throw Exception('No hay cursos asignados');
    
    final cursos = List<String>.from(jsonDecode(jsonString));
    
    // Obtener estudiantes de esos cursos
    final estudiantesMaps = await db.query('estudiantes', where: cursos.map((c) => "curso = '$c'").join(' OR '));
    
    // Obtener info completa de usuarios
    List<Map<String, dynamic>> estudiantesCompletos = [];
    for (var est in estudiantesMaps) {
      final usuarioMap = await db.query('usuarios_notes', where: 'id = ?', whereArgs: [est['usuario_id']]);
      if (usuarioMap.isNotEmpty) {
        estudiantesCompletos.add({
          'estudiante_id': est['id'],
          'usuario_id': est['usuario_id'],
          'curso': est['curso'],
          'nombre': usuarioMap.first['nombre'],
          'apellido': usuarioMap.first['apellido'],
        });
      }
    }
    
    return estudiantesCompletos;
  }

  Future<List<String>> _getNotasCreadas() async {
    final db = await DatabaseService.instance.database;
    final result = await db.query(
      'notas',
      where: 'materia_id = ?',
      whereArgs: [widget.materiaId],
      distinct: true,
      columns: ['nombre_nota'],
    );
    return result.map((e) => e['nombre_nota'] as String).toSet().toList();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final esProfesor = auth.usuarioActual!.rol == 2;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          esProfesor ? 'Gestión de Notas' : 'Mis Notas',
          style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold),
        ),
        bottom: esProfesor && _tabController != null
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(icon: Icon(Icons.note_add), text: 'Notas'),
                  Tab(icon: Icon(Icons.people), text: 'Estudiantes'),
                  Tab(icon: Icon(Icons.edit), text: 'Calificar'),
                ],
              )
            : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : esProfesor
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabNotas(theme),
                    _buildTabEstudiantes(theme),
                    _buildTabCalificar(theme),
                  ],
                )
              : _buildEstudianteView(theme),
    );
  }

  // ============ PESTAÑA 1: CREAR NOTAS ============
  // ============ PESTAÑA 1: CREAR NOTAS (CON OPCIÓN DE ELIMINAR) ============
Widget _buildTabNotas(ThemeProvider theme) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Crear nueva nota',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _mostrarDialogCrearNota(theme),
          icon: Icon(Icons.add, color: Colors.white),
          label: Text(
            'Agregar Nota',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'Notas creadas (${_notasCreadas.length})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: _notasCreadas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.note_outlined, size: 80, color: theme.textColor.withOpacity(0.3)),
                      const SizedBox(height: 15),
                      Text(
                        'No hay notas creadas',
                        style: TextStyle(
                          color: theme.textColor.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notasCreadas.length,
                  itemBuilder: (_, i) {
                    final nota = _notasCreadas[i];
                    return Dismissible(
                      key: Key(nota),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.delete, color: Colors.white, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await _confirmarEliminacionNota(nota, theme);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.assignment, color: theme.primaryColor),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                nota,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: theme.textColor,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () async {
                                final confirmar = await _confirmarEliminacionNota(nota, theme);
                                if (confirmar == true) {
                                  await _eliminarNota(nota);
                                }
                              },
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
  );
}

// ============ CONFIRMACIÓN DOBLE PARA ELIMINAR ============
Future<bool?> _confirmarEliminacionNota(String nombreNota, ThemeProvider theme) async {
  // Primera confirmación (suave)
  final primeraConfirmacion = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '¿Eliminar nota?',
              style: TextStyle(color: theme.textColor),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estás a punto de eliminar:',
            style: TextStyle(
              color: theme.textColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.assignment, color: Colors.orange),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nombreNota,
                    style: TextStyle(
                      color: theme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Esta acción afectará a todos los estudiantes que tienen esta nota asignada.',
            style: TextStyle(
              color: theme.textColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancelar',
            style: TextStyle(color: theme.textColor.withOpacity(0.7)),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text('Continuar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (primeraConfirmacion != true) return false;

  // Segunda confirmación (contundente)
  final segundaConfirmacion = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // No se puede cerrar tocando afuera
    builder: (context) => AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '⚠️ CONFIRMACIÓN FINAL',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Column(
              children: [
                Icon(Icons.delete_forever, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text(
                  '¡ESTA ACCIÓN ES IRREVERSIBLE!',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Se eliminará permanentemente:',
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'La nota "$nombreNota"',
                  style: TextStyle(color: theme.textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Todas las calificaciones asociadas',
                  style: TextStyle(color: theme.textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'El historial de todos los estudiantes',
                  style: TextStyle(color: theme.textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No podrás recuperar esta información',
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            'No, conservar nota',
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_forever, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'SÍ, ELIMINAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  return segundaConfirmacion ?? false;
}

// ============ FUNCIÓN PARA ELIMINAR NOTA ============
Future<void> _eliminarNota(String nombreNota) async {
  try {
    final db = await DatabaseService.instance.database;
    
    // Eliminar todas las notas con ese nombre de la materia
    await db.delete(
      'notas',
      where: 'materia_id = ? AND nombre_nota = ?',
      whereArgs: [widget.materiaId, nombreNota],
    );

    // Recargar datos
    await _cargarDatosProfesor();

    // Mostrar confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text('Nota "$nombreNota" eliminada correctamente'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text('Error al eliminar: $e')),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }
}

  void _mostrarDialogCrearNota(ThemeProvider theme) {
    final _nombreNotaController = TextEditingController();
    String? _error;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                Icon(Icons.note_add, color: theme.primaryColor),
                const SizedBox(width: 10),
                Text('Nueva Nota', style: TextStyle(color: theme.textColor)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nombreNotaController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la nota',
                    hintText: 'Ej: Parcial 1, Taller 2, Quiz...',
                    filled: true,
                    fillColor: theme.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: theme.textColor.withOpacity(0.7)),
                  ),
                  style: TextStyle(color: theme.textColor),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(_error!, style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar', style: TextStyle(color: theme.textColor.withOpacity(0.7))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  if (_nombreNotaController.text.trim().isEmpty) {
                    setStateDialog(() => _error = 'Ingresa un nombre para la nota');
                    return;
                  }

                  try {
                    final notasProv = Provider.of<NotasProvider>(context, listen: false);
                    final estudianteIds = _estudiantes.map((e) => e['estudiante_id'] as int).toList();
                    
                    await notasProv.crearNota(
                      widget.materiaId,
                      _nombreNotaController.text.trim(),
                      estudianteIds,
                    );

                    await _cargarDatosProfesor();
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Nota creada para ${estudianteIds.length} estudiantes'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    setStateDialog(() => _error = e.toString());
                  }
                },
                child: Text('Crear', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============ PESTAÑA 2: ESTUDIANTES ============
  Widget _buildTabEstudiantes(ThemeProvider theme) {
    // Agrupar estudiantes por curso
    Map<String, List<Map<String, dynamic>>> estudiantesPorCurso = {};
    for (var est in _estudiantes) {
      final curso = est['curso'] as String;
      if (!estudiantesPorCurso.containsKey(curso)) {
        estudiantesPorCurso[curso] = [];
      }
      estudiantesPorCurso[curso]!.add(est);
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estudiantes inscritos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView(
              children: estudiantesPorCurso.entries.map((entry) {
                final curso = entry.key;
                final estudiantes = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        curso.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    ...estudiantes.map((est) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: theme.primaryColor.withOpacity(0.2),
                              child: Icon(Icons.person, color: theme.primaryColor),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                '${est['nombre']} ${est['apellido']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: theme.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ============ PESTAÑA 3: CALIFICAR ============
  Widget _buildTabCalificar(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asignar calificaciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 15),
          if (_notasCreadas.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assignment_late, size: 80, color: theme.textColor.withOpacity(0.3)),
                    const SizedBox(height: 15),
                    Text(
                      'Crea una nota primero',
                      style: TextStyle(
                        color: theme.textColor.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _notasCreadas.length,
                itemBuilder: (_, notaIndex) {
                  final nombreNota = _notasCreadas[notaIndex];
                  return ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.assignment, color: theme.primaryColor),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              nombreNota,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    children: _estudiantes.map((est) {
                      return FutureBuilder<double?>(
                        future: _getCalificacionEstudiante(est['estudiante_id'], nombreNota),
                        builder: (context, snapshot) {
                          final calificacion = snapshot.data;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.primaryColor.withOpacity(0.2),
                              child: Icon(Icons.person, color: theme.primaryColor, size: 20),
                            ),
                            title: Text(
                              '${est['nombre']} ${est['apellido']}',
                              style: TextStyle(color: theme.textColor),
                            ),
                            subtitle: Text(
                              calificacion != null ? 'Calificación: $calificacion' : 'Sin calificar',
                              style: TextStyle(
                                color: calificacion != null
                                    ? (calificacion >= 70 ? Colors.green : Colors.red)
                                    : theme.textColor.withOpacity(0.5),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: theme.primaryColor),
                              onPressed: () => _mostrarDialogCalificar(
                                theme,
                                est['estudiante_id'],
                                nombreNota,
                                calificacion,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<double?> _getCalificacionEstudiante(int estudianteId, String nombreNota) async {
    final db = await DatabaseService.instance.database;
    final result = await db.query(
      'notas',
      where: 'materia_id = ? AND estudiante_id = ? AND nombre_nota = ?',
      whereArgs: [widget.materiaId, estudianteId, nombreNota],
    );
    if (result.isEmpty) return null;
    return result.first['calificacion'] as double?;
  }

  void _mostrarDialogCalificar(ThemeProvider theme, int estudianteId, String nombreNota, double? calificacionActual) {
    final _calificacionController = TextEditingController(
      text: calificacionActual?.toString() ?? '',
    );
    String? _error;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                Icon(Icons.grade, color: theme.primaryColor),
                const SizedBox(width: 10),
                Text('Calificar', style: TextStyle(color: theme.textColor)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreNota,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _calificacionController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Calificación (0-100)',
                    filled: true,
                    fillColor: theme.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    labelStyle: TextStyle(color: theme.textColor.withOpacity(0.7)),
                  ),
                  style: TextStyle(color: theme.textColor),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(_error!, style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar', style: TextStyle(color: theme.textColor.withOpacity(0.7))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final texto = _calificacionController.text.trim();
                  if (texto.isEmpty) {
                    setStateDialog(() => _error = 'Ingresa una calificación');
                    return;
                  }

                  final calificacion = double.tryParse(texto);
                  if (calificacion == null || calificacion < 0 || calificacion > 100) {
                    setStateDialog(() => _error = 'Calificación debe estar entre 0 y 100');
                    return;
                  }

                  try {
                    final notasProv = Provider.of<NotasProvider>(context, listen: false);
                    final db = await DatabaseService.instance.database;
                    
                    // Buscar el ID de la nota
                    final result = await db.query(
                      'notas',
                      where: 'materia_id = ? AND estudiante_id = ? AND nombre_nota = ?',
                      whereArgs: [widget.materiaId, estudianteId, nombreNota],
                    );

                    if (result.isNotEmpty) {
                      final notaId = result.first['id'] as int;
                      await notasProv.updateCalificacion(notaId, calificacion);
                      
                      Navigator.pop(context);
                      setState(() {}); // Refrescar la vista
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calificación guardada'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    setStateDialog(() => _error = e.toString());
                  }
                },
                child: Text('Guardar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============ VISTA ESTUDIANTE ============
  Widget _buildEstudianteView(ThemeProvider theme) {
    final notasProv = Provider.of<NotasProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis calificaciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: notasProv.notas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 80, color: theme.textColor.withOpacity(0.3)),
                        const SizedBox(height: 15),
                        Text(
                          'No tienes notas asignadas',
                          style: TextStyle(
                            color: theme.textColor.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: notasProv.notas.length,
                    itemBuilder: (_, i) {
                      final nota = notasProv.notas[i];
                      final tieneCalificacion = nota.calificacion != null;
                      final aprobado = tieneCalificacion && nota.calificacion! >= 70;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: tieneCalificacion
                                    ? (aprobado ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2))
                                    : theme.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                tieneCalificacion
                                    ? (aprobado ? Icons.check_circle : Icons.cancel)
                                    : Icons.pending,
                                color: tieneCalificacion
                                    ? (aprobado ? Colors.green : Colors.red)
                                    : theme.primaryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nota.nombreNota,
                                    style: TextStyle(
                                      color: theme.textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    tieneCalificacion
                                        ? 'Calificación: ${nota.calificacion}'
                                        : 'Pendiente de calificación',
                                    style: TextStyle(
                                      color: theme.textColor.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (tieneCalificacion)
                                    Text(
                                      aprobado ? 'Aprobado' : 'Reprobado',
                                      style: TextStyle(
                                        color: aprobado ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}