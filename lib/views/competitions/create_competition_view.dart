import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/competitions_provider.dart';

class CreateCompetitionView extends StatefulWidget {
  const CreateCompetitionView({super.key});

  @override
  State<CreateCompetitionView> createState() => _CreateCompetitionViewState();
}

class _CreateCompetitionViewState extends State<CreateCompetitionView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalController = TextEditingController();

  String? _selectedGoalType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  // Mapa para las opciones del dropdown
  final Map<String, String> _goalTypes = {
    'MAX_HABITOS_DIA': 'Máximo hábitos por día',
    'MAX_RACHA': 'Racha más larga',
    'TOTAL_COMPLETADOS': 'Total completados',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  // Función para abrir el selector de fechas
  Future<void> _pickDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final now = DateTime.now();
    final initialDate = isStartDate ? _startDate : _endDate;
    // La primera fecha seleccionable es hoy para el inicio, o la fecha de inicio para el fin.
    final firstDate = isStartDate ? now : (_startDate ?? now);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // Si la fecha de fin es anterior a la nueva de inicio, la reseteamos.
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  // Función para enviar el formulario a la API
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final int goalValue = int.tryParse(_goalController.text) ?? 0;

    final competitionData = {
      'nombre': _nameController.text.trim(),
      'descripcion': _descriptionController.text.trim(),
      'tipo_meta': _selectedGoalType,

      // --- CORRECCIÓN: Enviamos ambos campos como lo espera la API ---
      'meta_objetivo': goalValue,
      'valor': goalValue,

      // --- FIN DE LA CORRECCIÓN ---
      'fecha_inicio': _startDate!.toIso8601String().substring(
        0,
        10,
      ), // Formato YYYY-MM-DD
      'fecha_fin': _endDate!.toIso8601String().substring(
        0,
        10,
      ), // Formato YYYY-MM-DD
    };

    final provider = context.read<CompetitionsProvider>();
    final success = await provider.createCompetition(competitionData);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Competencia creada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${provider.error ?? "No se pudo crear la competencia."}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A),
      appBar: AppBar(
        title: const Text('Crear Nueva Competencia'),
        backgroundColor: const Color(0xFF1B1D2A),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la competencia',
              ),
              validator:
                  (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGoalType,
              hint: const Text('Tipo de Meta'),
              items:
                  _goalTypes.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
              onChanged: (v) => setState(() => _selectedGoalType = v),
              validator:
                  (v) => (v == null) ? 'Selecciona un tipo de meta' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _goalController,
              decoration: const InputDecoration(
                labelText: 'Meta a alcanzar (ej. 100)',
              ),
              keyboardType: TextInputType.number,
              validator:
                  (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDatePickerField(
                    label: 'Fecha de Inicio',
                    date: _startDate,
                    onTap: () => _pickDate(context, isStartDate: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDatePickerField(
                    label: 'Fecha de Fin',
                    date: _endDate,
                    onTap: () => _pickDate(context, isStartDate: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed:
                  (_isLoading || _startDate == null || _endDate == null)
                      ? null
                      : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                      : const Text('Crear Competencia'),
            ),
          ],
        ),
      ),
    );
  }

  // Widget de ayuda para construir los campos de fecha
  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
        child: Text(
          date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Seleccionar',
          style: TextStyle(
            color: date != null ? Colors.white : Colors.white54,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
