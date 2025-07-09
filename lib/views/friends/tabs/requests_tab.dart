// lib/views/friends/tabs/requests_tab.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../providers/friends_provider.dart';

class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsProvider>().fetchInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingInvitations) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.receivedInvitations.isEmpty) {
          return Center(
            child: Text(
              'No tienes solicitudes de amistad pendientes.',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchInvitations(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
            itemCount: provider.receivedInvitations.length,
            itemBuilder: (context, index) {
              final request = provider.receivedInvitations[index];
              final requesterName = request['solicitante_nombre'] ?? 'Usuario';

              return Card(
                elevation: 0,
                color: Colors.white.withOpacity(0.05),
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigoAccent.withOpacity(0.2),
                    child: Text(
                      requesterName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.indigoAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    requesterName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Quiere ser tu amigo.',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.greenAccent,
                        ),
                        onPressed:
                            () => provider.respondToInvitation(
                              request['id'],
                              'accept',
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        onPressed:
                            () => provider.respondToInvitation(
                              request['id'],
                              'reject',
                            ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.2);
            },
          ),
        );
      },
    );
  }
}
