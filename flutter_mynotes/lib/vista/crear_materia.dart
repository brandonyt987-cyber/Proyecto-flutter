import 'package:flutter/material.dart';
import '../provider/theme_provider.dart';

class CrearMateriaFlotante extends StatefulWidget {
  final ThemeProvider themeProvider;
  final Function(String) onGuardar;

  const CrearMateriaFlotante({
    super.key,
    required this.themeProvider,
    required this.onGuardar,
  });

  @override
  State<CrearMateriaFlotante> createState() => _CrearMateriaFlotanteState();
}

class _CrearMateriaFlotanteState extends State<CrearMateriaFlotante> {
  final TextEditingController _nombreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.themeProvider.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit, color: widget.themeProvider.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Nueva materia',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.themeProvider.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _nombreController,
                style: TextStyle(color: widget.themeProvider.textColor),
                decoration: InputDecoration(
                  hintText: 'Nombre de la materia',
                  hintStyle: TextStyle(
                    color: widget.themeProvider.textColor.withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: widget.themeProvider.backgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeProvider.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final nombre = _nombreController.text.trim();
                    if (nombre.isNotEmpty) {
                      widget.onGuardar(nombre);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
