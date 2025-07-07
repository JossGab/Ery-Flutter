// lib/views/friends/tabs/requests_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // Cargamos las solicitudes al iniciar la pestaña
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
          return const Center(
            child: Text(
              'No tienes solicitudes de amistad pendientes.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchInvitations(),
          child: ListView.builder(
            itemCount: provider.receivedInvitations.length,
            itemBuilder: (context, index) {
              final request = provider.receivedInvitations[index];

              // --- CORRECCIÓN CLAVE ---
              // Accedemos a las claves directamente desde el objeto 'request'
              final requesterName = request['solicitante_nombre'] ?? 'Usuario';
              // --- FIN DE LA CORRECCIÓN ---

              return Card(
                color: const Color(0xFF1F2937),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(requesterName[0].toUpperCase()),
                  ),
                  title: Text(
                    requesterName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Quiere ser tu amigo.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.greenAccent,
                        ),
                        onPressed: () {
                          provider.respondToInvitation(request['id'], 'accept');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        onPressed: () {
                          provider.respondToInvitation(request['id'], 'reject');
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
