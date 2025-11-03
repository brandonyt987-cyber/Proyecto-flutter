import 'package:flutter/material.dart';
import 'vista/materias.dart'; // 👈 importa tu página de materias

void main() {
  runApp(const MyNoteApp());
}

class MyNoteApp extends StatefulWidget {
  const MyNoteApp({super.key});

  @override
  State<MyNoteApp> createState() => _MyNoteAppState();
}

class _MyNoteAppState extends State<MyNoteApp> {
  bool _isDark = false; // 👈 modo oscuro

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        backgroundColor: isDark ? const Color(0xFF6A4C9C) : Colors.white,
        body: Stack(
          children: [
            //circulo
            Positioned(
              bottom: -80, // lo mueve más abajo
              right: -60, // mueve hacia la izquierda para coincidir con Figma
              child: FractionalTranslation(
                translation: const Offset(
                  0.1,
                  0.1,
                ), // ajusta leve desplazamiento
                child: Container(
                  width: 320, // más grande para que sobresalga
                  height: 320,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF4B2C74)
                        : const Color(0xFF80B4FF),
                    borderRadius: BorderRadius.circular(250),
                  ),
                ),
              ),
            ),
            // 🌙 Interruptor modo oscuro/claro arriba a la derecha
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? Colors.white : Colors.black,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _isDark = !_isDark;
                      });
                    },
                  ),
                ),
              ),
            ),

            // 📋 Contenido central
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🧭 Encabezado
                    Text(
                      '📝 MyNote.',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bienvenido',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.grey[800],
                      ),
                    ),

                    const SizedBox(height: 80),

                    // 🏠 Botón circular de Home
                    Builder(
                      builder: (context) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.deepPurple[300]
                              : Colors.grey.shade200,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          iconSize: 40,
                          icon: Icon(
                            Icons.home,
                            color: isDark ? Colors.white : Colors.black54,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MaterialScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
