import 'package:flutter/material.dart';
import 'vista/materias.dart';

void main() {
  runApp(
    MaterialApp(home: MainApp()),
  ); //El home mainapp tiene el contenido principal
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Color para el modo claro y oscuro
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          //stack permite poner un widget sobre
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .center, //Sirve para central horizontalmentey el otro vertical mente
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20), // Espacio
                  Text(
                    'MyNote.',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Bienvenido',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            //Imagen
            Positioned(
              top: 20,
              right: 20, //Se usa para poner la imagen en la esquina
              child: Image.asset('assets/images/lapiz.png', height: 80),
            ),

            //icono de home para la otra pagina
            Container(
              padding: const EdgeInsets.all(20), //espacio
              decoration: BoxDecoration(
                shape: BoxShape.circle, //Fondo redondo
                color: Colors.grey[300], //color del circulo
              ),
              //Icono
              child: const Icon(Icons.home, size: 40, color: Colors.black54),
            ),
          ],
        ),
      ),
      //barra del final xd
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // Primer

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notas'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
