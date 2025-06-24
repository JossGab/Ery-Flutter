/*
================================================================================
 ARCHIVO: lib/views/habits/widgets/create_habit_modal.dart
 INSTRUCCIONES: Este widget contiene el formulario para añadir un nuevo hábito.
================================================================================
*/
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Ajusta la ruta de importación según tu estructura de carpetas
import '../../../providers/auth_provider.dart';

class CreateHabitModal extends StatefulWidget {
  const CreateHabitModal({super.key});

  @override
  State<CreateHabitModal> createState() => _CreateHabitModalState();
}

class _CreateHabitModalState extends State<CreateHabitModal> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  String _descripcion = '';
  String _tipo = 'SI_NO';
  double? _meta;
  bool _isSaving = false; // Estado para controlar el indicador de carga

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return; // Evita envíos múltiples

    _formKey.currentState!.save();
    setState(() => _isSaving = true);

    final habitData = {
      'nombre': _nombre,
      'descripcion': _descripcion,
      'tipo': _tipo,
      if (_tipo == 'MEDIBLE_NUMERICO') 'meta_objetivo': _meta,
    };

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await authProvider.createHabit(habitData);
      navigator.pop(); // Cierra el modal
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('¡Hábito creado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, stackTrace) {
      // <-- AÑADIMOS stackTrace
      // --- AÑADIMOS LOGS DETALLADOS EN EL CATCH ---
      debugPrint('===== ERROR AL CREAR HÁBITO =====');
      debugPrint('Datos enviados a la API: $habitData');
      debugPrint('Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      debugPrint('===================================');

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      // Nos aseguramos de que el estado de carga se desactive
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // Añadido para evitar overflow con el teclado
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Crear Nuevo Hábito',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre del Hábito',
                ),
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? 'El nombre es obligatorio'
                            : null,
                onSaved: (v) => _nombre = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Descripción (Opcional)',
                ),
                onSaved: (v) => _descripcion = v ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipo,
                decoration: const InputDecoration(labelText: 'Tipo de Hábito'),
                items: const [
                  DropdownMenuItem(value: 'SI_NO', child: Text('Sí / No')),
                  DropdownMenuItem(
                    value: 'MEDIBLE_NUMERICO',
                    child: Text('Numérico (ej: 500 ml de agua)'),
                  ),
                  DropdownMenuItem(
                    value: 'MAL_HABITO',
                    child: Text('Dejar un Mal Hábito (Recaídas)'),
                  ),
                ],
                onChanged: (v) => setState(() => _tipo = v!),
              ),
              if (_tipo == 'MEDIBLE_NUMERICO') ...[
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Meta Numérica'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator:
                      (v) =>
                          v == null || v.isEmpty
                              ? 'La meta es obligatoria'
                              : null,
                  onSaved: (v) => _meta = double.tryParse(v!),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child:
                    _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text('Crear Hábito'),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
