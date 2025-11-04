import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class CrearMateria extends StatefulWidget {
  final Function(Map<String, dynamic>) onGuardar;
  final ThemeProvider themeProvider;

  const CrearMateria({
    super.key,
    required this.onGuardar,
    required this.themeProvider,
  });

  @override
  State<CrearMateria> createState() => _CrearMateriaState();
}

class _CrearMateriaState extends State<CrearMateria> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _profesorController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String? _diaSeleccionado;
  TimeOfDay? _horaSeleccionada;

  final List<String> _dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _profesorController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada ?? TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
      });
    }
  }

  void _guardarMateria() {
    if (_formKey.currentState!.validate()) {
      // Crear el objeto de materia con los datos del formulario
      final materia = {
        'nombre': _nombreController.text.trim(),
        'profesor': _profesorController.text.trim(),
        'horario': '$_diaSeleccionado ${_horaSeleccionada!.format(context)}',
        'descripcion': _descripcionController.text.trim(),
      };

      // Llamar al callback para guardar la materia
      widget.onGuardar(materia);

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Materia guardada correctamente"),
          backgroundColor: Colors.green,
        ),
      );

      // Cerrar el diálogo
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorPrimario = widget.themeProvider.primaryColor;

    return Dialog(
      backgroundColor: widget.themeProvider.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Header del diálogo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorPrimario,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nueva materia",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Contenido del formulario
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildCampoTexto(
                        icono: Icons.school,
                        etiqueta: "Nombre de la materia",
                        controller: _nombreController,
                        validador: (v) => v == null || v.trim().isEmpty
                            ? "Campo requerido"
                            : null,
                      ),
                      const SizedBox(height: 15),

                      _buildCampoTexto(
                        icono: Icons.person,
                        etiqueta: "Profesor/a",
                        controller: _profesorController,
                        validador: (v) => v == null || v.trim().isEmpty
                            ? "Campo requerido"
                            : null,
                      ),
                      const SizedBox(height: 15),

                      // Día de clase
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Día de clase",
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        dropdownColor: widget.themeProvider.cardColor,
                        style: TextStyle(color: widget.themeProvider.textColor),
                        initialValue: _diaSeleccionado,
                        items: _dias
                            .map(
                              (d) => DropdownMenuItem(value: d, child: Text(d)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _diaSeleccionado = v),
                        validator: (v) =>
                            v == null ? "Selecciona un día de la semana" : null,
                      ),
                      const SizedBox(height: 15),

                      // Hora
                      GestureDetector(
                        onTap: () => _seleccionarHora(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: "Horario",
                              prefixIcon: const Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            controller: TextEditingController(
                              text: _horaSeleccionada == null
                                  ? ""
                                  : _horaSeleccionada!.format(context),
                            ),
                            validator: (v) => _horaSeleccionada == null
                                ? "Selecciona una hora"
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      _buildCampoTexto(
                        icono: Icons.edit_note,
                        etiqueta: "Descripción / Notas",
                        controller: _descripcionController,
                        maxLineas: 3,
                        validador: (v) => v == null || v.trim().isEmpty
                            ? "Campo requerido"
                            : null,
                      ),
                      const SizedBox(height: 25),

                      ElevatedButton.icon(
                        onPressed: _guardarMateria,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          "Guardar materia",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimario,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoTexto({
    required IconData icono,
    required String etiqueta,
    required TextEditingController controller,
    required String? Function(String?) validador,
    int maxLineas = 1,
    TextInputType tipo = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validador,
      maxLines: maxLineas,
      keyboardType: tipo,
      style: TextStyle(color: widget.themeProvider.textColor),
      decoration: InputDecoration(
        labelText: etiqueta,
        prefixIcon: Icon(icono),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
