// lib/views/friends/friends_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: _buildAppBar(context),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [MyFriendsTab(), RequestsTab(), SearchUsersTab()],
      ),
    );
  }

  /// AppBar con efecto de desenfoque y TabBar corregido.
  Widget _buildAppBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AppBar(
          backgroundColor: Colors.white.withOpacity(0.05),
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              'Comunidad',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.indigoAccent.withOpacity(0.8),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.poppins(),
            tabs: const [
              Tab(icon: Icon(Icons.people_alt_rounded), text: 'Amigos'),
              Tab(
                icon: Icon(Icons.person_add_alt_1_rounded),
                text: 'Solicitudes',
              ),
              Tab(icon: Icon(Icons.search_rounded), text: 'Buscar'),
            ],
          ),
        ),
      ),
    );
  }
}
