import 'package:flutter/material.dart';
import '../services/google_auth_service.dart';

class SidebarDrawer extends StatelessWidget {
  final Map<String, dynamic> student;

  const SidebarDrawer({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final email = student['student_id'] ?? student['email'];

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(student['name']),
            accountEmail: Text(student['email'] ?? student['student_id']),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text("Leave Application"),
            onTap: () => Navigator.pushNamed(
              context,
              '/leave',
              arguments: {'email': email},
            ),
          ),

          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text("My QR Code"),
            onTap: () => Navigator.pushNamed(
              context,
              '/qr',
              arguments: {'email': email},
            ),
          ),

          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text("Bills"),
            onTap: () => Navigator.pushNamed(
              context,
              '/bills',
              arguments: {'email': email},
            ),
          ),

          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              final authService = GoogleAuthService();
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
