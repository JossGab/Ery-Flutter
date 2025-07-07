import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/competitions_provider.dart';
import 'create_competition_view.dart';
import 'competition_detail_view.dart';

class CompetitionsView extends StatefulWidget {
  const CompetitionsView({super.key});

  @override
  State<CompetitionsView> createState() => _CompetitionsViewState();
}

class _CompetitionsViewState extends State<CompetitionsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompetitionsProvider>().fetchMyCompetitions();
    });
  }

  void _navigateToCreateCompetition() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateCompetitionView()),
    );
  }

  void _navigateToCompetitionDetails(int competitionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionDetailView(competitionId: competitionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateCompetition,
        label: const Text('Crear Competencia'),
        icon: const Icon(Icons.add),
      ),
      body: Consumer<CompetitionsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingList) {
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
          if (provider.myCompetitions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Aún no participas en ninguna competencia.\n¡Crea una para empezar!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => provider.fetchMyCompetitions(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: provider.myCompetitions.length,
              itemBuilder: (context, index) {
                // --- CORRECCIÓN CLAVE: Usamos el objeto directamente ---
                final competition = provider.myCompetitions[index];
                return _CompetitionCard(
                  competition: competition,
                  onTap: () => _navigateToCompetitionDetails(competition['id']),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Widget para la tarjeta de cada competición (Ya estaba correcto, solo se mantiene)
class _CompetitionCard extends StatelessWidget {
  final Map<String, dynamic> competition;
  final VoidCallback onTap;

  const _CompetitionCard({required this.competition, required this.onTap});

  Widget _buildStatusChip() {
    final status = competition['estado'] ?? 'desconocido';
    Color chipColor;
    String statusText;

    switch (status) {
      case 'activa':
        chipColor = Colors.green.withOpacity(0.3);
        statusText = 'Activa';
        break;
      case 'proxima':
        chipColor = Colors.blue.withOpacity(0.3);
        statusText = 'Próxima';
        break;
      case 'finalizada':
        chipColor = Colors.red.withOpacity(0.3);
        statusText = 'Finalizada';
        break;
      default:
        chipColor = Colors.grey.withOpacity(0.3);
        statusText = 'Desconocido';
    }

    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1B1D2A),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      competition['nombre'] ?? 'Competencia sin nombre',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                competition['descripcion'] ?? 'Sin descripción.',
                style: const TextStyle(color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 24, color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.people_alt_outlined,
                        size: 16,
                        color: Colors.white54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${competition['participantes_count'] ?? 0} Participantes',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white54),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
