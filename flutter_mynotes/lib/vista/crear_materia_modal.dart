import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/materia_provider.dart';
import '../providers/theme_provider.dart';

class CrearMateriaModal extends StatefulWidget {
  @override
  _CrearMateriaModalState createState() => _CrearMateriaModalState();
}

class _CrearMateriaModalState extends State<CrearMateriaModal> {
  final _descripcionController = TextEditingController();
  
  String? _nombreMateria;
  List<String> _diasSeleccionados = [];
  int? _salonSeleccionado;
  List<String> _cursosAsignados = [];
  String? _error;
  bool _isLoading = false;

  TimeOfDay? _horarioInicio;
  TimeOfDay? _horarioFin;

  final List<String> _materiasDisponibles = [
    'Matemáticas',
    'Sociales',
    'Inglés',
    'Ciencias Naturales',
    'Español',
    'Educación Física',
    'Artes',
    'Tecnología',
  ];

  final List<String> _diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
  ];

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  // Función para seleccionar hora
  Future<void> _seleccionarHora(BuildContext context, bool esInicio) async {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(primary: theme.primaryColor),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: theme.cardColor,
              hourMinuteTextColor: theme.textColor,
              dayPeriodTextColor: theme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (esInicio) {
          _horarioInicio = picked;
        } else {
          _horarioFin = picked;
        }
        _error = null;
      });
    }
  }

  String _timeToString(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _validarFormulario() {
    if (_nombreMateria == null || _nombreMateria!.isEmpty) {
      setState(() => _error = 'Selecciona el nombre de la materia');
      return false;
    }
    if (_diasSeleccionados.isEmpty) {
      setState(() => _error = 'Selecciona al menos un día');
      return false;
    }
    if (_horarioInicio == null) {
      setState(() => _error = 'Selecciona el horario de inicio');
      return false;
    }
    if (_horarioFin == null) {
      setState(() => _error = 'Selecciona el horario de fin');
      return false;
    }
    final inicioMinutos = _horarioInicio!.hour * 60 + _horarioInicio!.minute;
    final finMinutos = _horarioFin!.hour * 60 + _horarioFin!.minute;
    if (finMinutos <= inicioMinutos) {
      setState(() => _error = 'El horario de fin debe ser posterior al inicio');
      return false;
    }
    if (_salonSeleccionado == null) {
      setState(() => _error = 'Selecciona un salón');
      return false;
    }
    if (_cursosAsignados.isEmpty) {
      setState(() => _error = 'Selecciona al menos un curso');
      return false;
    }
    return true;
  }

  Future<void> _guardarMateria() async {
    if (!_validarFormulario()) return;

    setState(() {
      _error = null;
      _isLoading = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final materiasProv = Provider.of<MateriasProvider>(context, listen: false);
    final profesor = auth.profesorActual!;

    try {
      await materiasProv.crearMateria(
        nombre: _nombreMateria!,
        profesorId: profesor.id,
        dias: _diasSeleccionados,
        horarioInicio: _timeToString(_horarioInicio),
        horarioFin: _timeToString(_horarioFin),
        salon: _salonSeleccionado!,
        cursosAsignados: _cursosAsignados,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Materia creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final profesor = auth.profesorActual!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Título
                Row(
                  children: [
                    Icon(Icons.book, color: theme.primaryColor, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'Nueva materia',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // 🔹 Nombre de la materia
                _buildCampoConIcono(
                  icon: Icons.school,
                  hint: 'Nombre de la materia',
                  theme: theme,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    hint: Text(
                      'Seleccionar materia',
                      style: TextStyle(
                        color: theme.textColor.withOpacity(0.5),
                      ),
                    ),
                    value: _nombreMateria,
                    dropdownColor: theme.cardColor,
                    items: _materiasDisponibles.map((materia) {
                      return DropdownMenuItem(
                        value: materia,
                        child: Row(
                          children: [
                            if (materia == 'Matemáticas')
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Icon(
                                  Icons.calculate,
                                  size: 18,
                                  color: theme.primaryColor,
                                ),
                              ),
                            Text(
                              materia,
                              style: TextStyle(
                                color: theme.textColor,
                                fontWeight: materia == 'Matemáticas'
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _nombreMateria = value;
                        _error = null;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // 🔹 Profesor/a (solo lectura)
                _buildCampoConIcono(
                  icon: Icons.person,
                  hint: 'Profesor/a',
                  theme: theme,
                  child: TextFormField(
                    initialValue:
                        '${auth.usuarioActual!.nombre} ${auth.usuarioActual!.apellido}',
                    enabled: false,
                    style: TextStyle(
                      color: theme.textColor.withOpacity(0.7),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // 🔹 Horario Inicio
                GestureDetector(
                  onTap: () => _seleccionarHora(context, true),
                  child: _buildCampoConIcono(
                    icon: Icons.access_time,
                    hint: 'Horario inicio',
                    theme: theme,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _horarioInicio != null
                            ? _timeToString(_horarioInicio)
                            : 'Seleccionar hora de inicio',
                        style: TextStyle(
                          color: _horarioInicio != null
                              ? theme.textColor
                              : theme.textColor.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // 🔹 Horario Fin
                GestureDetector(
                  onTap: () => _seleccionarHora(context, false),
                  child: _buildCampoConIcono(
                    icon: Icons.access_time_filled,
                    hint: 'Horario fin',
                    theme: theme,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _horarioFin != null
                            ? _timeToString(_horarioFin)
                            : 'Seleccionar hora de fin',
                        style: TextStyle(
                          color: _horarioFin != null
                              ? theme.textColor
                              : theme.textColor.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                // 🔹 Rango de horario completo
                if (_horarioInicio != null && _horarioFin != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.schedule,
                            color: theme.primaryColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Horario: ${_timeToString(_horarioInicio)} - ${_timeToString(_horarioFin)}',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // 🔹 Días de la semana
                Text(
                  'Días de clase:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _diasSemana.map((dia) {
                    final isSelected = _diasSeleccionados.contains(dia);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _diasSeleccionados.remove(dia);
                          } else {
                            _diasSeleccionados.add(dia);
                          }
                          _error = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.primaryColor.withOpacity(0.8)
                              : theme.backgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? theme.primaryColor
                                : theme.textColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          dia,
                          style: TextStyle(
                            color: isSelected ? Colors.white : theme.textColor,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 🔹 Salón
                Text(
                  'Salón:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.textColor.withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(border: InputBorder.none),
                    hint: Text(
                      'Seleccionar salón (1-7)',
                      style: TextStyle(
                        color: theme.textColor.withOpacity(0.5),
                      ),
                    ),
                    value: _salonSeleccionado,
                    dropdownColor: theme.cardColor,
                    items: List.generate(7, (index) {
                      final salon = index + 1;
                      return DropdownMenuItem(
                        value: salon,
                        child: Text(
                          'Salón $salon',
                          style: TextStyle(color: theme.textColor),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _salonSeleccionado = value;
                        _error = null;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Cursos asignados
                Text(
                  'Cursos asignados:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profesor.cursosAsignados.map((curso) {
                    final isSelected = _cursosAsignados.contains(curso);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _cursosAsignados.remove(curso);
                          } else {
                            _cursosAsignados.add(curso);
                          }
                          _error = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.primaryColor.withOpacity(0.8)
                              : theme.backgroundColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? theme.primaryColor
                                : theme.textColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          curso,
                          style: TextStyle(
                            color: isSelected ? Colors.white : theme.textColor,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 🔹 Descripción / Notas (opcional)
                _buildCampoConIcono(
                  icon: Icons.edit_note,
                  hint: 'Descripción / Notas',
                  theme: theme,
                  child: TextFormField(
                    controller: _descripcionController,
                    maxLines: 3,
                    style: TextStyle(color: theme.textColor),
                    decoration: InputDecoration(
                      hintText: 'Información adicional...',
                      hintStyle: TextStyle(
                        color: theme.textColor.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Mensaje de error
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 🔹 Botón guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _guardarMateria,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                'Guardar materia',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCampoConIcono({
    required IconData icon,
    required String hint,
    required ThemeProvider theme,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.textColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}