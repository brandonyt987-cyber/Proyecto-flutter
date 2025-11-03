import 'package:flutter/material.dart';
import 'crear_materia.dart';
import '../provider/theme_provider.dart';
import 'notas.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();
  final List<Map<String, dynamic>> _materias = [];

  /// 🔹 Agregar materia a la lista
  void agregarMateria(Map<String, dynamic> materia) {
    setState(() {
      _materias.add({
        'nombre': materia['nombre'],
        'profesor': materia['profesor'],
        'horario': materia['horario'],
        'descripcion': materia['descripcion'],
        'notas': [],
        'promedio': 0.0,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeProvider,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _themeProvider.backgroundColor,
          appBar: AppBar(
            backgroundColor: _themeProvider.primaryColor,
            elevation: 0,
            title: Row(
              children: [
                const Text(
                  'MyNote.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Icon(
                  _themeProvider.isDarkTheme
                      ? Icons.nights_stay
                      : Icons.wb_sunny,
                  color: Colors.yellow,
                  size: 24,
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _themeProvider.isDarkTheme
                      ? Icons.wb_sunny
                      : Icons.nights_stay,
                  color: Colors.white,
                ),
                onPressed: _themeProvider.toggleTheme,
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
                    color: _themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 20),

                /// 🔹 Menú superior
                Row(
                  children: [
                    Expanded(
                      child: _buildMenuCard(
                        icon: Icons.edit,
                        title: 'Nueva Materia',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => CrearMateria(
                              onGuardar: agregarMateria,
                              themeProvider: _themeProvider,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildMenuCard(
                        icon: Icons.content_paste,
                        title: 'Ver materias',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                /// 🔹 Listado de materias
                Expanded(
                  child: _materias.isEmpty
                      ? Center(
                          child: Text(
                            'No hay materias creadas',
                            style: TextStyle(
                              fontSize: 18,
                              color: _themeProvider.textColor.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _materias.length,
                          itemBuilder: (context, index) {
                            final materia = _materias[index];
                            return GestureDetector(
                              onTap: () {
                                // ✅ Navega a la pantalla de notas.dart
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotasScreen(
                                      materia: materia,
                                      themeProvider: _themeProvider,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: _themeProvider.cardColor,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      materia['nombre'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _themeProvider.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Profesor: ${materia['profesor']}',
                                      style: TextStyle(
                                        color: _themeProvider.textColor,
                                      ),
                                    ),
                                    Text(
                                      'Horario: ${materia['horario']}',
                                      style: TextStyle(
                                        color: _themeProvider.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      materia['descripcion'] ?? '',
                                      style: TextStyle(
                                        color: _themeProvider.textColor
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _materias.removeAt(index);
                                          });
                                        },
                                      ),
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

          /// 🔹 Botón flotante
          floatingActionButton: FloatingActionButton(
            backgroundColor: _themeProvider.primaryColor,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => CrearMateria(
                  onGuardar: agregarMateria,
                  themeProvider: _themeProvider,
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  /// 🔹 Tarjetas del menú superior
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _themeProvider.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(icon, color: _themeProvider.primaryColor, size: 30),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _themeProvider.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
