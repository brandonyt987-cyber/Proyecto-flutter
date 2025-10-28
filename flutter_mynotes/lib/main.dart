import 'package:flutter/material.dart';

void main() {
  runApp(MainApp());
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .start, //Se hace una are para el codigo y se alinea a la izquierda
          children: [
            /* Align(
              alignment: Alignment.topRight,
              child: Image.asset(
                'assets/images/lapiz.png',
                height: 80, //Tamaño del lapiz
              ),
            ),

            */
            const SizedBox(height: 20), //Espacio del lapioz
            //MyNote
            Text(
              'MyNote.',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
