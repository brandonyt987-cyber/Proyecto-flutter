import 'package:flutter/material.dart';
import 'vista/crear_materia.dart';
import 'vista/theme_provider.dart';


// Clase principal
class MaterialScreen extends StatefulWidget {
  const MaterialScreen({Key? key}) : super(key: key);

  @override
  _MaterialScreenState createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final ThemeProvider _themeProvider = ThemeProvider();
  final List<map<String, dynamic>> _materias = [];

  void _AgregarMateria(String nombre) {
    setState(() {
      _materias.add({
        'nombre': nombre,
        'notas': [],
        'promedio': 0.0,
    });
  });
}

@override
 Widget build(BuildContext context) {
  return ListenableBuilder(
    listenable: _themeProvider,
    builder: (context, child) {
      return Scaffold(
        backgroundColor: _themeProvider.backgroundColor,
        appBar: AppBar(
          backgroundColor: _themeProvider.primaryColor,
          elevation: 0,
          title: Row(
            children: [
              const Text(
                'MyNote. ',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Icon(
                _themeProvider.isDarkTheme ? Icons.nights_stay : Icons.wb_sunny,
                color: Colors.yellow,
                size: 24,
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                _themeProvider.isDarkTheme ? Icons.wb_sunny : Icons.nights_stay,
                color: Colors.white,
              ),
              onPressed: (){
                _themeProvider.toggleTheme();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const edgeInsets.all(20.0),
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
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      context,
                      Icon(Icons.edit),
                      title: 'Nueva Materia',
                      onTap: () async {
                        final resultado = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CrearMateriaScreen(
                              themeProvider: _themeProvider,
                            ),
                          ),
                        );
                        if (resultado != null) {
                          _AgregarMateria(resultado);
                        }
                      }
                    ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildMenuCard(
                        context, 
                        Icon. Icons.content_paste,
                        title: 'ver materias',
                        onTap: () {
                          //navegar por las listas de materias
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              if (_materias.isNotEmpty)
                Expanded( 
                  child: Center(
                    child: Text(
                      'No hay materias creadas',
                      style: TextStyle(
                        fontSize: 20,
                        color: _themeProvider.textColor.withOpacity(0.6),
                        ),
                    ),
                  ),
                )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _Materias.length,
                      itemBuilder: (context, index) {
                        final materia = _Materias[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _themeProvider.cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  materia['nombre'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: _themeProvider.textColor,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _materias.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: _themeProvider.cardColor,
          selectedItemColor: _themeProvider.primaryColor,
          unselectedIconTheme: IconThemeData(color: Colors.grey),
          currentIndex: 0,
          items: const[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.circle),
              label: '',
            ),
          ]
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _themeProvider.primaryColor,
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CrearMateriaScreen(),
            ),
          );
        }
        child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    },
  );
}
Widget _buildFloatingActionButton(BuildContext context), {
  required IconData icon,
  required String title,
  required VoidCallback onTap,
}
  return Container(
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(15),
      offset: const Offset(0, 5),
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
            Icon(
              icon,
              color: _themeProvider.primaryColor,
              size: 30,
              ),
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
            ),
          ],
        ),
      ),
    ),
  ),
}