// lib/views/habits/widgets/edit_habit_modal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/habit_model.dart';
import '../../../providers/auth_provider.dart';

class EditHabitModal extends StatefulWidget {
  final Habit habit;
  const EditHabitModal({super.key, required this.habit});

  @override
  State<EditHabitModal> createState() => _EditHabitModalState();
}

class _EditHabitModalState extends State<EditHabitModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _goalController;
  late String _selectedType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-cargamos el formulario con los datos del hábito existente
    _nameController = TextEditingController(text: widget.habit.nombre);
    _descriptionController = TextEditingController(
      text: widget.habit.descripcion,
    );
    _goalController = TextEditingController(
      text: widget.habit.metaObjetivo?.toString() ?? '',
    );
    _selectedType = widget.habit.tipo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    final habitData = {
      'nombre': _nameController.text.trim(),
      'descripcion': _descriptionController.text.trim(),
      'tipo': _selectedType,
      if (_selectedType == 'MEDIBLE_NUMERICO')
        'meta_objetivo': double.tryParse(_goalController.text),
    };

    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.updateHabit(widget.habit.id, habitData);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Hábito actualizado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Editar Hábito',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Hábito',
                border: OutlineInputBorder(),
              ),
              validator:
                  (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (Opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            // Aquí podrías añadir la lógica para editar el tipo y la meta si es necesario
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isSaving
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                      : const Text('Guardar Cambios'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
