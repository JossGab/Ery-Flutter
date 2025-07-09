import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
  final _valueController = TextEditingController();

  String? _selectedGoalType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

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
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    BuildContext context, {
    required bool isStartDate,
  }) async {
    final now = DateTime.now();
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate ? now : (_startDate ?? now);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF1B1D2A),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0E0F1A),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final int goalValue = int.tryParse(_goalController.text) ?? 0;
    final double valuePerPoint = double.tryParse(_valueController.text) ?? 1.0;

    final competitionData = {
      'nombre': _nameController.text.trim(),
      'descripcion': _descriptionController.text.trim(),
      'tipo_meta': _selectedGoalType,
      'meta_objetivo': goalValue,
      'valor': valuePerPoint,
      'fecha_inicio': _startDate!.toIso8601String().substring(0, 10),
      'fecha_fin': _endDate!.toIso8601String().substring(0, 10),
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
        backgroundColor: Colors.transparent,
        title: Text(
          'Crear Competencia',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildEnhancedField(
                        controller: _nameController,
                        label: 'Nombre de la competencia',
                        maxLength: 50,
                        hint: 'Ej: Reto 30 días sin azúcar',
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _descriptionController,
                        label: 'Descripción',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGoalType,
                        decoration: _inputDecoration('Tipo de Meta'),
                        style: GoogleFonts.poppins(color: Colors.white),
                        dropdownColor: const Color(0xFF1B1D2A),
                        iconEnabledColor: Colors.white70,
                        items:
                            _goalTypes.entries
                                .map(
                                  (entry) => DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(
                                      entry.value,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setState(() => _selectedGoalType = v),
                        validator:
                            (v) =>
                                v == null ? 'Selecciona un tipo de meta' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _goalController,
                        label: 'Meta a alcanzar',
                        helper: 'Ej: 100 hábitos o días',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _valueController,
                        label: 'Valor por punto',
                        helper: 'Ej: 1.0',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePickerField(
                              label: 'Fecha de inicio',
                              date: _startDate,
                              onTap:
                                  () => _pickDate(context, isStartDate: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDatePickerField(
                              label: 'Fecha de fin',
                              date: _endDate,
                              onTap:
                                  () => _pickDate(context, isStartDate: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                            onPressed:
                                (_startDate == null || _endDate == null)
                                    ? null
                                    : _submitForm,
                            icon: const Icon(Icons.check),
                            label: Text(
                              'Crear Competencia',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ).animate().fade().slideY(),
                    ],
                  ),
                ),
              ).animate().fade().slideY(begin: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedField({
    required TextEditingController controller,
    required String label,
    required int maxLength,
    String? hint,
  }) {
    return AnimatedContainer(
      duration: 500.ms,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          counterStyle: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: 12,
          ),
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white70),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.white30),
        ),
        validator:
            (v) => v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
      ),
    ).animate().fade(duration: 500.ms).slideY(begin: 0.3);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? helper,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: _inputDecoration(label, helperText: helper),
      validator: (v) {
        if (label.contains('*') && (v == null || v.isEmpty)) {
          return 'Campo obligatorio';
        }
        if (label.contains('Meta') &&
            (v == null || int.tryParse(v) == null || int.parse(v) <= 0)) {
          return 'Debe ser un número positivo';
        }
        if (label.contains('Valor') &&
            (v == null || double.tryParse(v) == null || double.parse(v) <= 0)) {
          return 'Debe ser un número mayor a 0';
        }
        return null;
      },
    );
  }

  InputDecoration _inputDecoration(String label, {String? helperText}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.white70),
      helperText: helperText,
      helperStyle: GoogleFonts.poppins(color: Colors.white38),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Text(
          date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Seleccionar',
          style: GoogleFonts.poppins(
            color: date != null ? Colors.white : Colors.white54,
          ),
        ),
      ),
    );
  }
}
