import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../models/habit_model.dart';

class HabitsView extends StatelessWidget {
  const HabitsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al AuthProvider para obtener la lista de hábitos
    final authProvider = context.watch<AuthProvider>();
    final habits = authProvider.habits;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mis Hábitos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Crear Hábito',
            onPressed: () => _showCreateHabitModal(context),
          ),
        ],
      ),
      body:
          authProvider.isLoading && habits.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : habits.isEmpty
              ? _buildEmptyState(context)
              : _buildHabitsGrid(habits),
    );
  }

  void _showCreateHabitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1D2A),
      builder: (_) {
        // Pasamos el AuthProvider al modal
        return ChangeNotifierProvider.value(
          value: Provider.of<AuthProvider>(context, listen: false),
          child: const CreateHabitModal(),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_flags_outlined,
            size: 60,
            color: Colors.white38,
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Es hora de empezar un nuevo reto!',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea tu primer hábito usando el botón "+".',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsGrid(List<Habit> habits) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        return HabitCard(habit: habits[index]);
      },
    );
  }
}

// --- WIDGET PARA LA TARJETA DE UN HÁBITO ---

class HabitCard extends StatelessWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  String get _todayStringForAPI {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _logProgress(BuildContext context, Map<String, dynamic> payload) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final logData = {
        'habito_id': habit.id,
        'fecha_registro': _todayStringForAPI,
        ...payload,
      };
      await authProvider.logHabitProgress(logData);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('¡Progreso registrado!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: habit.tipo == 'MAL_HABITO' ? Colors.redAccent : Colors.green,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            habit.nombre,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (habit.descripcion != null && habit.descripcion!.isNotEmpty)
            Text(
              habit.descripcion!,
              style: const TextStyle(color: Colors.white60),
            ),
          const Spacer(),
          _buildActionWidget(context),
        ],
      ),
    );
  }

  Widget _buildActionWidget(BuildContext context) {
    switch (habit.tipo) {
      case 'SI_NO':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _logProgress(context, {'valor_booleano': true}),
            child: const Text('Marcar como Hecho'),
          ),
        );
      case 'MAL_HABITO':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _logProgress(context, {'es_recaida': true}),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent[100],
            ),
            child: const Text('Registrar Recaída'),
          ),
        );
      case 'MEDIBLE_NUMERICO':
        final controller = TextEditingController();
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Valor (Meta: ${habit.metaObjetivo})',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null) {
                  _logProgress(context, {'valor_numerico': value});
                }
              },
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        );
      default:

        // Si el tipo de hábito es desconocido o nulo, no mostramos nada.

        // SizedBox.shrink() es un widget vacío que no ocupa espacio.

        return const SizedBox.shrink();
    }
  }
}

// --- WIDGET PARA EL MODAL DE CREACIÓN DE HÁBITOS ---

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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Crear Nuevo Hábito',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nombre del Hábito'),
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
                  child: Text('Numérico'),
                ),
                DropdownMenuItem(
                  value: 'MAL_HABITO',
                  child: Text('Dejar un Mal Hábito'),
                ),
              ],
              onChanged: (v) => setState(() => _tipo = v!),
            ),
            if (_tipo == 'MEDIBLE_NUMERICO') ...[
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Meta Numérica'),
                keyboardType: TextInputType.number,
                validator:
                    (v) =>
                        v == null || v.isEmpty
                            ? 'La meta es obligatoria'
                            : null,
                onSaved: (v) => _meta = double.tryParse(v!),
              ),
            ],
            const SizedBox(height: 24),
            authProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Crear Hábito'),
                ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

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
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
