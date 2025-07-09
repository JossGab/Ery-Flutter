import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/friends_provider.dart';
import 'tabs/my_friends_tab.dart';
import 'tabs/requests_tab.dart';
import 'tabs/search_users_tab.dart';

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FriendsProvider>();
      provider.fetchFriends();
      provider.fetchInvitations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0F1A),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AppBar(
                automaticallyImplyLeading: false, // Elimina flecha
                elevation: 0,
                backgroundColor: Colors.white.withOpacity(0.05),
                title: const Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    "Comunidad",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.indigoAccent.withOpacity(0.15),
                    ),
                    labelColor: Colors.indigoAccent,
                    unselectedLabelColor: Colors.white60,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.people_alt_rounded),
                        text: 'Mis Amigos',
                      ),
                      Tab(
                        icon: Icon(Icons.person_add_alt_1_rounded),
                        text: 'Solicitudes',
                      ),
                      Tab(icon: Icon(Icons.search_rounded), text: 'Buscar'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [MyFriendsTab(), RequestsTab(), SearchUsersTab()],
        ),
      ),
    );
  }
}
