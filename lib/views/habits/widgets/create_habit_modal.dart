/*
================================================================================
 ARCHIVO: lib/views/habits/widgets/create_habit_modal.dart (Versión Final y Robusta)
 INSTRUCCIONES: Se reemplaza AnimatedVisibility por un `if` para máxima compatibilidad.
================================================================================
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class CreateHabitModal extends StatefulWidget {
  const CreateHabitModal({super.key});

  @override
  State<CreateHabitModal> createState() => _CreateHabitModalState();
}

class _CreateHabitModalState extends State<CreateHabitModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalController = TextEditingController();

  String _selectedType = 'SI_NO';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    _formKey.currentState!.save();
    setState(() => _isSaving = true);

    final habitData = {
      'nombre': _nameController.text.trim(),
      'descripcion': _descriptionController.text.trim(),
      'tipo': _selectedType,
      if (_selectedType == 'MEDIBLE_NUMERICO')
        'meta_objetivo': double.tryParse(_goalController.text),
    };

    try {
      await context.read<AuthProvider>().createHabit(habitData);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Hábito creado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString().replaceFirst("Exception: ", "")}',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'Crear Nuevo Hábito',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  label: 'Nombre del Hábito',
                  icon: Icons.flag_outlined,
                ),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'El nombre es obligatorio'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration(
                  label: 'Descripción (Opcional)',
                  icon: Icons.edit_note_outlined,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              const Text(
                'Elige el tipo de hábito',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _HabitTypeCard(
                    title: 'Sí / No',
                    icon: Icons.check_circle_outline,
                    isSelected: _selectedType == 'SI_NO',
                    onTap: () => setState(() => _selectedType = 'SI_NO'),
                  ),
                  _HabitTypeCard(
                    title: 'Numérico',
                    icon: Icons.straighten_outlined,
                    isSelected: _selectedType == 'MEDIBLE_NUMERICO',
                    onTap:
                        () =>
                            setState(() => _selectedType = 'MEDIBLE_NUMERICO'),
                  ),
                  _HabitTypeCard(
                    title: 'Mal Hábito',
                    icon: Icons.shield_outlined,
                    isSelected: _selectedType == 'MAL_HABITO',
                    onTap: () => setState(() => _selectedType = 'MAL_HABITO'),
                  ),
                ],
              ),

              // ==========================================================
              // --- CAMBIO CLAVE: Reemplazo de AnimatedVisibility ---
              // Usamos un 'if' simple para añadir el widget condicionalmente.
              // Logra el mismo efecto visual pero es 100% a prueba de errores del analizador.
              // ==========================================================
              if (_selectedType == 'MEDIBLE_NUMERICO')
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextFormField(
                    controller: _goalController,
                    decoration: _buildInputDecoration(
                      label: 'Meta Numérica (ej: 500)',
                      icon: Icons.numbers_outlined,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (_selectedType == 'MEDIBLE_NUMERICO' &&
                          (v == null || v.isEmpty)) {
                        return 'La meta es obligatoria';
                      }
                      return null;
                    },
                  ),
                ),

              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child:
                    _isSaving
                        ? const Center(child: CircularProgressIndicator())
                        : FilledButton.icon(
                          onPressed: _submitForm,
                          icon: const Icon(Icons.add_task_rounded),
                          label: const Text(
                            'Crear Hábito',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white54),
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
    );
  }
}

class _HabitTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _HabitTypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? Theme.of(context).colorScheme.primary : Colors.white24;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? color.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: isSelected ? 2 : 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? color : Colors.white70, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(color: isSelected ? color : Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
