import 'package:flutter/material.dart';
import '../provider/theme_provider.dart';

class NotasScreen extends StatefulWidget {
  final Map<String, dynamic> materia;
  final ThemeProvider themeProvider;

  const NotasScreen({
    super.key,
    required this.materia,
    required this.themeProvider,
  });

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  List<Map<String, dynamic>> notas = [];
  double promedio = 0.0;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _porcentajeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    notas = List<Map<String, dynamic>>.from(widget.materia['notas'] ?? []);
    calcularPromedio();
  }

  void calcularPromedio() {
    if (notas.isEmpty) {
      promedio = 0.0;
    } else {
      double suma = notas.fold(0, (acc, n) => acc + n['porcentaje']);
      promedio = suma / notas.length;
    }
    setState(() {});
  }

  void agregarNota() {
    final nombre = _nombreController.text.trim();
    final porcentaje = double.tryParse(_porcentajeController.text) ?? 0;

    if (nombre.isNotEmpty) {
      setState(() {
        notas.add({'nombre': nombre, 'porcentaje': porcentaje});
        _nombreController.clear();
        _porcentajeController.clear();
        calcularPromedio();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.themeProvider;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(
          widget.materia['nombre'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Nombre de materia
            Text(
              widget.materia['nombre'],
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: theme.textColor,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Lista de notas
            Expanded(
              child: notas.isEmpty
                  ? Center(
                      child: Text(
                        'Aún no tienes notas registradas',
                        style: TextStyle(
                          color: theme.textColor.withValues(alpha: 0.6),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: notas.length,
                      itemBuilder: (context, index) {
                        final nota = notas[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              nota['nombre'],
                              style: TextStyle(
                                color: theme.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: nota['porcentaje'] / 100,
                                    color: theme.primaryColor,
                                    minHeight: 8,
                                    backgroundColor: theme.textColor.withValues(
                                      alpha: 0.15,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${nota['porcentaje']}%',
                                  style: TextStyle(
                                    color: theme.textColor.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  notas.removeAt(index);
                                  calcularPromedio();
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),

            // 🔹 Promedio
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tu promedio:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  Text(
                    '${promedio.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // 🔹 Formulario para agregar nota
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _nombreController,
                    style: TextStyle(color: theme.textColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.cardColor,
                      labelText: 'Nombre de nota',
                      labelStyle: TextStyle(
                        color: theme.textColor.withValues(alpha: 0.6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _porcentajeController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: theme.textColor),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.cardColor,
                      labelText: '%',
                      labelStyle: TextStyle(
                        color: theme.textColor.withValues(alpha: 0.6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔹 Botón para agregar nota
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Agregar nota',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: agregarNota,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
