import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'escuela.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apellido TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        rol INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE estudiantes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        curso TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios_notes(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE profesores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        area TEXT NOT NULL,
        cursos_asignados TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios_notes(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE materias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        profesor_id INTEGER NOT NULL,
        dias TEXT NOT NULL,
        horario_inicio TEXT NOT NULL,
        horario_fin TEXT NOT NULL,
        salon INTEGER NOT NULL,
        cursos_asignados TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE notas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        materia_id INTEGER NOT NULL,
        nombre_nota TEXT NOT NULL,
        estudiante_id INTEGER NOT NULL,
        calificacion REAL
      )
    ''');
  }

  // ✅ INSERTAR USUARIO
  Future<int> insertUsuario(Map<String, dynamic> usuario) async {
    final db = await database;
    try {
      return await db.insert('usuarios_notes', usuario);
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('El email ya está registrado');
      }
      throw Exception('Error al insertar usuario: ${e.toString()}');
    }
  }

  // ✅ ELIMINAR USUARIO (Para puerta trasera de admin)
  Future<void> deleteUsuarioByEmail(String email) async {
    final db = await database;
    try {
      final usuario = await getUsuarioByEmail(email);
      if (usuario == null) {
        throw Exception('Usuario no encontrado');
      }
      // SQLite eliminará automáticamente los registros relacionados por CASCADE
      await db.delete('usuarios_notes', where: 'email = ?', whereArgs: [email]);
    } catch (e) {
      throw Exception('Error al eliminar usuario: ${e.toString()}');
    }
  }

  Future<int> insertEstudiante(Map<String, dynamic> estudiante) async {
    final db = await database;
    try {
      return await db.insert('estudiantes', estudiante);
    } catch (e) {
      throw Exception('Error al insertar estudiante: ${e.toString()}');
    }
  }

  Future<int> insertProfesor(Map<String, dynamic> profesor) async {
    final db = await database;
    try {
      return await db.insert('profesores', profesor);
    } catch (e) {
      throw Exception('Error al insertar profesor: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getUsuarioByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'usuarios_notes',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getEstudianteByUsuarioId(int usuarioId) async {
    final db = await database;
    final result = await db.query(
      'estudiantes',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getProfesorByUsuarioId(int usuarioId) async {
    final db = await database;
    final result = await db.query(
      'profesores',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> checkHorarioOcupado({
    required String dia,
    required String horarioInicio,
    required String horarioFin,
    required int salon,
    required String curso,
  }) async {
    final db = await database;
    final result = await db.query(
      'materias',
      where: '''
        salon = ? AND cursos_asignados LIKE ? AND dias LIKE ?
        AND ((horario_inicio <= ? AND horario_fin > ?) OR (horario_inicio < ? AND horario_fin >= ?))
      ''',
      whereArgs: [
        salon,
        '%$curso%',
        '%$dia%',
        horarioInicio,
        horarioInicio,
        horarioFin,
        horarioFin
      ],
    );
    return result.isNotEmpty;
  }

  Future<int> insertMateria(Map<String, dynamic> materia) async {
    final db = await database;
    try {
      final dias = jsonDecode(materia['dias']) as List;
      final cursos = jsonDecode(materia['cursos_asignados']) as List;

      for (var dia in dias) {
        for (var curso in cursos) {
          if (await checkHorarioOcupado(
            dia: dia,
            horarioInicio: materia['horario_inicio'],
            horarioFin: materia['horario_fin'],
            salon: materia['salon'],
            curso: curso,
          )) {
            throw Exception(
                'Horario ocupado en salón ${materia['salon']} para $curso en $dia');
          }
        }
      }
      return await db.insert('materias', materia);
    } catch (e) {
      throw Exception('Error al insertar materia: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getMateriasByProfesor(
      int profesorId) async {
    final db = await database;
    return await db.query(
      'materias',
      where: 'profesor_id = ?',
      whereArgs: [profesorId],
    );
  }

  Future<List<Map<String, dynamic>>> getMateriasForEstudiante(
      String curso) async {
    final db = await database;
    return await db.query(
      'materias',
      where: 'cursos_asignados LIKE ?',
      whereArgs: ['%$curso%'],
    );
  }

  Future<int> insertNota(Map<String, dynamic> nota) async {
    final db = await database;
    try {
      return await db.insert('notas', nota);
    } catch (e) {
      throw Exception('Error al insertar nota: ${e.toString()}');
    }
  }

  Future<void> asignarNotaAEstudiantes(
      int materiaId, String nombreNota, List<int> estudianteIds) async {
    final db = await database;
    for (var id in estudianteIds) {
      await insertNota({
        'materia_id': materiaId,
        'nombre_nota': nombreNota,
        'estudiante_id': id,
        'calificacion': null
      });
    }
  }

  Future<List<Map<String, dynamic>>> getNotasForEstudiante(
      int materiaId, int estudianteId) async {
    final db = await database;
    return await db.query(
      'notas',
      where: 'materia_id = ? AND estudiante_id = ?',
      whereArgs: [materiaId, estudianteId],
    );
  }

  Future<List<Map<String, dynamic>>> getEstudiantesByCursos(
      List<String> cursos) async {
    final db = await database;
    final where = cursos.map((c) => "curso = '$c'").join(' OR ');
    return await db.query('estudiantes', where: where);
  }

  Future<void> updateCalificacion(int notaId, double calificacion) async {
    final db = await database;
    await db.update(
      'notas',
      {'calificacion': calificacion},
      where: 'id = ?',
      whereArgs: [notaId],
    );
  }

  // ⚠️ SOLO PARA DESARROLLO - Eliminar base de datos
  // NO usar en ejecucion a menos que sea necesario
  ////Future<void> resetDatabase() async {
  ////  final databasesPath = await getDatabasesPath();
  ////  final path = join(databasesPath, 'escuela.db');
  ////  
  ////  // Cerrar la conexión actual
  ////  if (_db != null) {
  ////    await _db!.close();
  ////    _db = null;
  ////  }
  //  
  //  // Eliminar el archivo de la base de datos
  //  await databaseFactory.deleteDatabase(path);
  //  
  //  // Reinicializar
  //  _db = await _initDatabase();
  //}
//
  //// Cerrar la base de datos correctamente
  //Future<void> close() async {
  //  final db = _db;
  //  if (db != null) {
  //    await db.close();
  //    _db = null;
  //  }
  //}
}