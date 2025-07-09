// lib/views/routines/routines_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/routines_provider.dart';
import 'create_routine_modal.dart';
import 'routine_detail_view.dart';

class RoutinesView extends StatefulWidget {
  const RoutinesView({super.key});

  @override
  State<RoutinesView> createState() => _RoutinesViewState();
}

class _RoutinesViewState extends State<RoutinesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutinesProvider>().fetchRoutines();
    });
  }

  void _showCreateRoutineModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => ChangeNotifierProvider.value(
            value: context.read<RoutinesProvider>(),
            child: const CreateRoutineModal(),
          ),
    );
  }

  void _navigateToRoutineDetails(int routineId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoutineDetailView(routineId: routineId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Consumer<RoutinesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingList) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }

          if (provider.routines.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchRoutines(),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                    child: Text(
                      'Mis Rutinas',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.2),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final routine = provider.routines[index];
                    return _RoutineCard(
                          routine: routine,
                          onTap: () => _navigateToRoutineDetails(routine.id),
                        )
                        .animate()
                        .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                        .slideY(begin: 0.3, curve: Curves.easeOut);
                  }, childCount: provider.routines.length),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          );
        },
      ),
    );
  }

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
        onPressed: _showCreateRoutineModal,
        label: Text(
          'Nueva Rutina',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.all_inclusive_rounded,
              size: 100,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),
            Text(
              'Organiza tus hábitos',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Crea tu primera rutina para agrupar hábitos y alcanzar tus metas de forma estructurada.',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 80,
            ),
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

/// --- MEJORA: Tarjeta de Rutina completamente rediseñada ---
class _RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;

  const _RoutineCard({required this.routine, required this.onTap});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirmar Eliminación',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar la rutina "${routine.nombre}"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white60),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                context.read<RoutinesProvider>().deleteRoutine(routine.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.blueAccent.withOpacity(0.1),
                highlightColor: Colors.blueAccent.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blueAccent.withOpacity(0.2),
                            child: const Icon(
                              Icons.all_inclusive_rounded,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              routine.nombre,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _showDeleteConfirmation(context),
                            tooltip: 'Eliminar rutina',
                          ),
                        ],
                      ),
                      if (routine.descripcion != null &&
                          routine.descripcion!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            routine.descripcion!,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
