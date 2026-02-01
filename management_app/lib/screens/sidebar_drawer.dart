import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'scan_qr_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text(
              "Mess Management",
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text("Dashboard"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text("Scan QR"),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ScanQRScreen()),
              );
            },
          ),

          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
