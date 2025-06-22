// lib/widgets/custom_sidebar.dart
import 'package:flutter/material.dart';

class CustomSidebar extends StatelessWidget {
  final Function(int) onItemSelected;

  const CustomSidebar({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1B1D2A),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.white),
                title: Text("Meng To", style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  "UI Designer",
                  style: TextStyle(color: Colors.white54),
                ),
                trailing: Icon(Icons.close, color: Colors.white),
              ),
            ),
            const Divider(color: Colors.white24),
            _buildSectionTitle("MENU"),
            _buildItem(Icons.home, "Home", 0),
            _buildItem(Icons.dashboard, "Browse", 1, badge: 12),
            _buildItem(Icons.topic, "Topics", 2),
            _buildItem(Icons.search, "Search", 3),
            _buildItem(Icons.payment, "Billing", 4),
            _buildItem(Icons.help, "Help", 5),
            const Divider(color: Colors.white24),
            _buildSectionTitle("HISTORY"),
            _buildItem(Icons.download, "Downloads", 6),
            _buildItem(Icons.favorite, "Favorites", 7),
            const Spacer(),
            SwitchListTile(
              value: true,
              onChanged: (_) {},
              title: const Text(
                "Dark Mode",
                style: TextStyle(color: Colors.white),
              ),
              secondary: const Icon(Icons.dark_mode, color: Colors.white),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text(
                "Settings",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title, style: const TextStyle(color: Colors.white54)),
    );
  }

  Widget _buildItem(IconData icon, String label, int index, {int? badge}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing:
          badge != null
              ? CircleAvatar(
                backgroundColor: Colors.red,
                radius: 10,
                child: Text(
                  '$badge',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              )
              : null,
      onTap: () => onItemSelected(index),
    );
  }
}
