import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/materia_provider.dart';
import '../providers/theme_provider.dart';
import 'notas_screen.dart';
import 'crear_materia_modal.dart';
import 'login_screen.dart'; // ✅ Importar LoginScreen

class MateriasScreen extends StatefulWidget {
  @override
  _MateriasScreenState createState() => _MateriasScreenState();
}

class _MateriasScreenState extends State<MateriasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarMaterias();
    });
  }

  void _cargarMaterias() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final materiasProv = Provider.of<MateriasProvider>(context, listen: false);
    
    if (auth.usuarioActual!.rol == 2) {
      // Profesor: cargar sus materias
      materiasProv.loadMateriasForProfesor(auth.profesorActual!.id);
    } else {
      // Estudiante: cargar materias de su curso
      materiasProv.loadMateriasForEstudiante(auth.estudianteActual!.curso);
    }
  }

  // ✅ FUNCIÓN PARA CERRAR SESIÓN
  void _cerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // Cerrar el diálogo primero
              Navigator.of(dialogContext).pop();
              
              // Hacer logout
              final auth = Provider.of<AuthProvider>(context, listen: false);
              auth.logout();
              
              // Navegar al login
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false, // Eliminar todas las rutas anteriores
              );
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final materiasProv = Provider.of<MateriasProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final usuario = auth.usuarioActual!;
    final esProfesor = usuario.rol == 2;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        title: Text(
          'Mis Materias',
          style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              theme.isDarkTheme ? Icons.light_mode : Icons.dark_mode,
              color: theme.textColor,
            ),
            onPressed: theme.toggleTheme,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: theme.textColor),
            onPressed: () => _cerrarSesion(context), // ✅ Usar la nueva función
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Encabezado con nombre de usuario
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, ${usuario.nombre}!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    Text(
                      esProfesor
                          ? 'Profesor'
                          : 'Estudiante - ${auth.estudianteActual!.curso}',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                if (esProfesor)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final resultado = await showDialog(
                        context: context,
                        builder: (context) => CrearMateriaModal(),
                      );
                      if (resultado == true) {
                        _cargarMaterias(); // Recargar materias después de crear
                      }
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Crear Materia',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 30),
            // 🔹 Lista de materias
            Expanded(
              child: materiasProv.materias.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 80,
                            color: theme.textColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            esProfesor
                                ? 'No has creado materias aún'
                                : 'No tienes materias asignadas',
                            style: TextStyle(
                              color: theme.textColor.withOpacity(0.6),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: materiasProv.materias.length,
                      itemBuilder: (_, i) {
                        final materia = materiasProv.materias[i];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    NotasScreen(materiaId: materia.id!),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Ícono de materia
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color:
                                        theme.primaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    color: theme.primaryColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                // Info de la materia
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        materia.nombre,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: theme.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${materia.horarioInicio} - ${materia.horarioFin}',
                                        style: TextStyle(
                                          color: theme.textColor
                                              .withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Salón ${materia.salon} • ${materia.dias.join(', ')}',
                                        style: TextStyle(
                                          color: theme.textColor
                                              .withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (esProfesor)
                                        Text(
                                          'Cursos: ${materia.cursosAsignados.join(', ')}',
                                          style: TextStyle(
                                            color: theme.textColor
                                                .withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: theme.textColor.withOpacity(0.5),
                                  size: 18,
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
}