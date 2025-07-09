import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Detalle de la Competencia',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fondo desenfocado
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          Consumer<CompetitionsProvider>(
            builder: (context, provider, child) {
              final responseData = provider.selectedCompetitionDetails;
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
                    style: GoogleFonts.poppins(color: Colors.red),
                  ),
                );
              }

              if (competitionDetails == null) {
                return Center(
                  child: Text(
                    'No se pudieron cargar los detalles.',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh:
                    () =>
                        provider.fetchCompetitionDetails(widget.competitionId),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                  children: [
                    Text(
                      competitionDetails['nombre'] ?? 'Competencia sin Nombre',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fade().slideY(begin: 0.2),

                    const SizedBox(height: 8),
                    Text(
                      competitionDetails['descripcion'] ?? 'Sin descripción.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),

                    const Divider(height: 32, color: Colors.white24),

                    if ((competitionDetails['estado'] ?? '') == 'activa' &&
                        !isParticipant)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: ElevatedButton.icon(
                          onPressed:
                              () => provider.joinCompetition(
                                widget.competitionId,
                              ),
                          icon: const Icon(Icons.group_add),
                          label: Text(
                            'Unirse a la Competencia',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ).animate().fade().slideY(begin: 0.3),
                      ),

                    Text(
                      'Clasificación',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (leaderboard.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Text(
                          'Aún no hay participantes en la clasificación.',
                          style: GoogleFonts.poppins(color: Colors.white60),
                        ),
                      )
                    else
                      ...leaderboard.map((player) {
                        final bool isCurrentUser =
                            player['is_current_user'] ?? false;
                        final rank = leaderboard.indexOf(player) + 1;
                        return Card(
                          color: Colors.white.withOpacity(0.05),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isCurrentUser ? Colors.amber : Colors.white24,
                              child: Text(
                                '#$rank',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isCurrentUser
                                          ? Colors.black
                                          : Colors.white,
                                ),
                              ),
                            ),
                            title: Text(
                              player['user_name'] ?? 'Jugador Desconocido',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              '${player['score'] ?? 0} pts',
                              style: GoogleFonts.poppins(
                                color: Colors.amberAccent,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ).animate().fade(duration: 300.ms).slideX(begin: -0.2);
                      }).toList(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
