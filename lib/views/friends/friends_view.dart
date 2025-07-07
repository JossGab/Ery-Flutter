// lib/views/friends/friends_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/friends_provider.dart'; // Importamos el provider
import 'tabs/my_friends_tab.dart';
import 'tabs/requests_tab.dart';
import 'tabs/search_users_tab.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  @override
  void initState() {
    super.initState();
    // ESTA ES LA PARTE CLAVE:
    // Al entrar a "Comunidad", cargamos tanto los amigos como las invitaciones.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FriendsProvider>();
      provider.fetchFriends();
      provider.fetchInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B1D2A),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text("Comunidad"),
          bottom: const TabBar(
            indicatorColor: Colors.indigoAccent,
            indicatorWeight: 3.0,
            tabs: [
              Tab(icon: Icon(Icons.people_alt_rounded), text: 'Mis Amigos'),
              Tab(
                icon: Icon(Icons.person_add_alt_1_rounded),
                text: 'Solicitudes',
              ),
              Tab(icon: Icon(Icons.search_rounded), text: 'Buscar'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [MyFriendsTab(), RequestsTab(), SearchUsersTab()],
        ),
      ),
    );
  }
}
