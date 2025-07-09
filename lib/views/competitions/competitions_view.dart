import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    ).then((_) {
      context.read<CompetitionsProvider>().fetchMyCompetitions();
    });
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
      backgroundColor: const Color(0xFF0E0F1A),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateCompetition,
        label: Text("Crear Competencia", style: GoogleFonts.poppins()),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
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
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            );
          }

          if (provider.myCompetitions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Aún no participas en ninguna competencia.\n¡Crea una para empezar!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMyCompetitions(),
            color: Colors.white,
            backgroundColor: Colors.indigo,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              itemCount: provider.myCompetitions.length,
              itemBuilder: (context, index) {
                final competition = provider.myCompetitions[index];
                return _CompetitionCard(
                  competition: competition,
                  onTap: () => _navigateToCompetitionDetails(competition['id']),
                ).animate().fade().slideY(begin: 0.2, duration: 400.ms);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  final Map<String, dynamic> competition;
  final VoidCallback onTap;

  const _CompetitionCard({required this.competition, required this.onTap});

  Widget _buildStatusChip() {
    final status =
        competition['status']?.toString().toLowerCase() ?? 'desconocido';
    Color chipColor;
    String statusText;

    switch (status) {
      case 'activa':
        chipColor = Colors.green.withOpacity(0.2);
        statusText = 'Activa';
        break;
      case 'finalizada':
        chipColor = Colors.grey.withOpacity(0.2);
        statusText = 'Finalizada';
        break;
      case 'cancelada':
        chipColor = Colors.red.withOpacity(0.2);
        statusText = 'Cancelada';
        break;
      default:
        chipColor = Colors.grey.withOpacity(0.2);
        statusText = status.capitalize();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                      competition['name'] ?? 'Competencia sin nombre',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      softWrap: true,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                competition['description'] ?? 'Sin descripción.',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
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
                        '${competition['participant_count'] ?? 0} Participantes',
                        style: GoogleFonts.poppins(color: Colors.white60),
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
