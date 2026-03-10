import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calificacion_provider.dart';
import '../models/calificacion.dart';

class DetalleScreen extends StatefulWidget {
  final Calificacion? calificacion;
  final bool soloVer;

  const DetalleScreen({
    super.key,
    required this.calificacion,
    required this.soloVer,
  });

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _materiaController;
  late TextEditingController _profesorController;
  late TextEditingController _notaController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
        text: widget.calificacion?.nombreEstudiante ?? '');
    _materiaController =
        TextEditingController(text: widget.calificacion?.materia ?? '');
    _profesorController =
        TextEditingController(text: widget.calificacion?.profesor ?? '');
    _notaController = TextEditingController(
        text: widget.calificacion?.notaFinal.toString() ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _materiaController.dispose();
    _profesorController.dispose();
    _notaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CalificacionProvider>();
    final nota = double.parse(_notaController.text);

    if (widget.calificacion == null) {
      await provider.crear(Calificacion(
        nombreEstudiante: _nombreController.text.trim(),
        materia: _materiaController.text.trim(),
        profesor: _profesorController.text.trim(),
        notaFinal: nota,
      ));
    } else {
      await provider.actualizar(widget.calificacion!.copyWith(
        nombreEstudiante: _nombreController.text.trim(),
        materia: _materiaController.text.trim(),
        profesor: _profesorController.text.trim(),
        notaFinal: nota,
      ));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.calificacion == null
              ? 'Calificación creada exitosamente'
              : 'Calificación actualizada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esNuevo = widget.calificacion == null;
    final titulo = widget.soloVer
        ? 'Ver Calificación'
        : esNuevo
            ? 'Nueva Calificación'
            : 'Editar Calificación';

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // Icono decorativo
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF1565C0).withOpacity(0.1),
                  child: const Icon(Icons.school,
                      size: 40, color: Color(0xFF1565C0)),
                ),
              ),
              const SizedBox(height: 24),

              // Nombre estudiante
              TextFormField(
                controller: _nombreController,
                enabled: !widget.soloVer,
                decoration: _inputDecoration('Nombre del Estudiante', Icons.person),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Materia
              TextFormField(
                controller: _materiaController,
                enabled: !widget.soloVer,
                decoration: _inputDecoration('Materia', Icons.book),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'La materia es obligatoria' : null,
              ),
              const SizedBox(height: 16),

              // Profesor
              TextFormField(
                controller: _profesorController,
                enabled: !widget.soloVer,
                decoration: _inputDecoration('Profesor', Icons.person_outline),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'El profesor es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              // Nota final
              TextFormField(
                controller: _notaController,
                enabled: !widget.soloVer,
                decoration: _inputDecoration('Nota Final (0 - 10)', Icons.grade),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'La nota es obligatoria';
                  final nota = double.tryParse(v);
                  if (nota == null) return 'Ingresa un número válido';
                  if (nota < 0 || nota > 10) return 'La nota debe estar entre 0 y 10';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Estado (solo visible en modo ver/editar)
              if (widget.calificacion != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estado',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          Text(
                            widget.calificacion!.estado == 'A'
                                ? 'Activo'
                                : 'Inactivo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: widget.calificacion!.estado == 'A'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              // Botón guardar
              if (!widget.soloVer)
                ElevatedButton.icon(
                  onPressed: _guardar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    esNuevo ? 'Guardar Calificación' : 'Actualizar Calificación',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }
}