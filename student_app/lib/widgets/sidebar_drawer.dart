import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SidebarDrawer extends StatelessWidget {
  final Map<String, dynamic> student;

  const SidebarDrawer({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(student['name']),
            accountEmail: Text("ID: ${student['student_id']}"),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text("Leave Application"),
            onTap: () => Navigator.pushNamed(context, '/leave'),
          ),

          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text("My QR Code"),
            onTap: () => Navigator.pushNamed(context, '/qr'),
          ),

          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text("Bills"),
            onTap: () => Navigator.pushNamed(context, '/bills'),
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
