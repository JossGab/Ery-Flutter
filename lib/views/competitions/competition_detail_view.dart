import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/competitions_provider.dart';
import '../../providers/auth_provider.dart';

class CompetitionDetailView extends StatefulWidget {
  final int competitionId;

  const CompetitionDetailView({super.key, required this.competitionId});

  @override
  State<CompetitionDetailView> createState() => _CompetitionDetailViewState();
}

class _CompetitionDetailViewState extends State<CompetitionDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompetitionsProvider>().fetchCompetitionDetails(
        widget.competitionId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A),
      appBar: AppBar(
        title: const Text('Detalle de la Competencia'),
        backgroundColor: const Color(0xFF1B1D2A),
      ),
      body: Consumer<CompetitionsProvider>(
        builder: (context, provider, child) {
          final responseData = provider.selectedCompetitionDetails;

          // --- CORRECCIÓN: Accedemos al objeto 'competition' anidado ---
          final competitionDetails =
              responseData?['competition'] as Map<String, dynamic>?;

          final leaderboard =
              responseData?['leaderboard'] as List<dynamic>? ?? [];
          final currentUserId = context.watch<AuthProvider>().user?.id;
          final isParticipant = leaderboard.any(
            (p) => p['user_id'].toString() == currentUserId,
          );

          if (provider.isLoadingDetails) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                'Error: ${provider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (competitionDetails == null) {
            return const Center(
              child: Text('No se pudieron cargar los detalles.'),
            );
          }

          return RefreshIndicator(
            onRefresh:
                () => provider.fetchCompetitionDetails(widget.competitionId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  competitionDetails['nombre'] ?? 'Competencia sin Nombre',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  competitionDetails['descripcion'] ?? 'Sin descripción.',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const Divider(height: 32, color: Colors.white24),

                if ((competitionDetails['estado'] ?? '') == 'activa' &&
                    !isParticipant)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: ElevatedButton(
                      onPressed:
                          () => provider.joinCompetition(widget.competitionId),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Unirse a la Competencia'),
                    ),
                  ),

                const Text(
                  'Clasificación',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                if (leaderboard.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Aún no hay participantes en la clasificación.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                else
                  ...leaderboard.map((player) {
                    final bool isCurrentUser =
                        player['is_current_user'] ?? false;
                    return Card(
                      color:
                          isCurrentUser
                              ? Colors.indigo.withOpacity(0.5)
                              : const Color(0xFF1F2937),
                      child: ListTile(
                        leading: Text(
                          '#${leaderboard.indexOf(player) + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isCurrentUser ? Colors.amber : Colors.white,
                          ),
                        ),
                        // --- CORRECCIÓN: Usamos 'user_name' en lugar de 'nombre' ---
                        title: Text(
                          player['user_name'] ?? 'Jugador Desconocido',
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Text(
                          '${player['score'] ?? 0} pts',
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
