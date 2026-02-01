import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  final String studentId;
  const HomeScreen({super.key, required this.studentId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService service = SupabaseService();

  Map<String, dynamic>? student;
  Map<String, dynamic>? leaveStatus;
  Map<String, dynamic>? bill;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final profile = await service.getStudentProfile(widget.studentId);
    final leave = await service.getTodayLeave(widget.studentId);
    final billing = await service.getCurrentMonthBill(widget.studentId);

    setState(() {
      student = profile;
      leaveStatus = leave;
      bill = billing;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Student Dashboard")),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Profile + Welcome Row
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: const Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Welcome, ${student!['name']} 👋",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔹 Leave Status Card
            _leaveStatusCard(),

            const SizedBox(height: 16),

            // 🔹 Bill Summary Card
            _billSummaryCard(),
          ],
        ),
      ),
    );
  }

  // -------------------- UI COMPONENTS --------------------

  Widget _leaveStatusCard() {
    if (leaveStatus == null) {
      return _infoCard(
        color: Colors.green,
        icon: Icons.check_circle,
        title: "Active Today",
        subtitle: "Mess access enabled",
      );
    }

    return _infoCard(
      color: Colors.orange,
      icon: Icons.hotel,
      title: "You are on Leave",
      subtitle:
          "From ${leaveStatus!['start_date']} to ${leaveStatus!['end_date']}",
    );
  }

  Widget _billSummaryCard() {
    if (bill == null) {
      return _infoCard(
        color: Colors.blue,
        icon: Icons.receipt_long,
        title: "Mess Bill",
        subtitle: "No bill generated yet",
      );
    }

    return _infoCard(
      color: Colors.blue,
      icon: Icons.receipt_long,
      title: "This Month's Bill",
      subtitle: "₹${bill!['total_amount']} • ${bill!['status'].toUpperCase()}",
    );
  }

  Widget _infoCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- SIDEBAR --------------------

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 🔹 Profile Header
          UserAccountsDrawerHeader(
            accountName: Text(student!['name']),
            accountEmail: Text("ID: ${student!['student_id']}"),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),

          // 🔹 Menu Items
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text("My QR Code"),
            onTap: () => Navigator.pushNamed(context, '/qr'),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Apply Leave"),
            onTap: () => Navigator.pushNamed(context, '/leave'),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Leave Applications"),
            onTap: () => Navigator.pushNamed(context, '/leave-applications'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text("Bills"),
            onTap: () => Navigator.pushNamed(context, '/bills'),
          ),

          // 🔹 Push logout to bottom
          const Spacer(),

          const Divider(),

          // 🔴 Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();

              // For now, just go back to home/dashboard entry
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
