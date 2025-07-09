// lib/views/routines/routine_detail_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/routines_provider.dart';
import 'add_habit_to_routine_modal.dart';

class RoutineDetailView extends StatefulWidget {
  final int routineId;

  const RoutineDetailView({super.key, required this.routineId});

  @override
  State<RoutineDetailView> createState() => _RoutineDetailViewState();
}

class _RoutineDetailViewState extends State<RoutineDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Usamos `listen: false` para evitar reconstrucciones innecesarias dentro de initState.
      Provider.of<RoutinesProvider>(
        context,
        listen: false,
      ).fetchRoutineDetails(widget.routineId);
    });
  }

  void _showAddHabitModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ChangeNotifierProvider.value(
          // Pasamos el provider existente al modal.
          value: context.read<RoutinesProvider>(),
          child: const AddHabitToRoutineModal(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A), // Fondo base oscuro
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // --- MEJORA: Usamos CustomScrollView para un layout más flexible ---
      body: Consumer<RoutinesProvider>(
        builder: (context, provider, child) {
          final routine = provider.selectedRoutine;

          if (provider.isLoadingDetails) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }
          if (routine == null) {
            return _buildErrorState("No se pudo cargar la rutina.");
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(routine),
              _buildHeader(routine),
              if (routine.habits.isEmpty)
                _buildEmptyHabitList()
              else
                _buildHabitList(routine, provider),
              // Espacio para que el FAB no tape el último elemento.
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }

  /// --- MEJORA: AppBar que se integra con el scroll ---
  Widget _buildSliverAppBar(Routine routine) {
    return SliverAppBar(
      expandedHeight: 150.0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true, // El AppBar se queda visible al hacer scroll
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          routine.nombre,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        background: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// --- MEJORA: Botón flotante con diseño premium ---
  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Colors.purpleAccent.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _showAddHabitModal,
        label: Text(
          'Añadir Hábito',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  /// Header con la descripción de la rutina.
  Widget _buildHeader(Routine routine) {
    if (routine.descripcion == null || routine.descripcion!.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          routine.descripcion!,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 16,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 200.ms),
      ),
    );
  }

  /// --- MEJORA: Lista de hábitos con diseño renovado ---
  Widget _buildHabitList(Routine routine, RoutinesProvider provider) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final habit = routine.habits[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.white.withOpacity(0.05),
              child: ListTile(
                leading: const Icon(
                  Icons.psychology_alt_outlined,
                  color: Colors.white70,
                ),
                title: Text(
                  habit['nombre'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed:
                      () =>
                          provider.removeHabitFromSelectedRoutine(habit['id']),
                  tooltip: 'Quitar de la rutina',
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2);
      }, childCount: routine.habits.length),
    );
  }

  /// --- MEJORA: Estado para cuando no hay hábitos en la rutina ---
  Widget _buildEmptyHabitList() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child:
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.playlist_add_check_circle_outlined,
                  size: 80,
                  color: Colors.white24,
                ),
                const SizedBox(height: 20),
                Text(
                  'Rutina Vacía',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Añade hábitos a esta rutina para empezar a construirla.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).scale(),
    );
  }

  /// Estado para cuando ocurre un error.
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
            const SizedBox(height: 20),
            Text(
              'Ocurrió un error',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
