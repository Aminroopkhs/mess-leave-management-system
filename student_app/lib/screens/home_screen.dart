import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/google_auth_service.dart';

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
  Map<String, dynamic>? monthUsage;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      final profile = await service.getStudentProfile(widget.studentId);

      if (profile == null) {
        if (mounted) {
          setState(() {
            errorMessage =
                'Student profile not found. Please contact administration.';
            isLoading = false;
          });
        }
        return;
      }

      final leave = await service.getTodayLeave(widget.studentId);
      final billing = await service.getCurrentMonthBill(widget.studentId);
      final usage = await service.getCurrentMonthUsage(widget.studentId);

      if (mounted) {
        setState(() {
          student = profile;
          leaveStatus = leave;
          bill = billing;
          monthUsage = usage;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error loading data: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Student Dashboard")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final authService = GoogleAuthService();
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      );
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

            // 🔹 Current Month Usage Card
            _monthUsageCard(),

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

  Widget _monthUsageCard() {
    if (monthUsage == null) {
      return const SizedBox.shrink();
    }

    print('DEBUG UI: monthUsage = $monthUsage');
    print('DEBUG UI: leave_periods = ${monthUsage!['leave_periods']}');
    print(
      'DEBUG UI: leave_periods type = ${monthUsage!['leave_periods'].runtimeType}',
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant, size: 36, color: Colors.purple),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Month Usage",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${monthUsage!['chargeable_days']} days • ₹${monthUsage!['total_amount']}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _usageDetail("Total Days", "${monthUsage!['total_days']}"),
              _usageDetail("Leave Days", "${monthUsage!['leave_days']}"),
              _usageDetail("Rate/Day", "₹${monthUsage!['rate_per_day']}"),
            ],
          ),
          if (monthUsage!['leave_periods'] != null &&
              (monthUsage!['leave_periods'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              "Applied Leaves This Month:",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (monthUsage!['leave_periods'] as List)
                  .map(
                    (period) => Chip(
                      label: Text(
                        "${period['start']} - ${period['end']}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.purple.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _usageDetail(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
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
            accountEmail: Text(student!['email'] ?? widget.studentId),
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),

          // 🔹 Menu Items
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text("My QR Code"),
            onTap: () => Navigator.pushNamed(
              context,
              '/qr',
              arguments: {'email': widget.studentId},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text("Apply Leave"),
            onTap: () => Navigator.pushNamed(
              context,
              '/leave',
              arguments: {'email': widget.studentId},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Leave Applications"),
            onTap: () => Navigator.pushNamed(
              context,
              '/leave-applications',
              arguments: {'email': widget.studentId},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text("Bills"),
            onTap: () => Navigator.pushNamed(
              context,
              '/bills',
              arguments: {'email': widget.studentId},
            ),
          ),

          // 🔹 Push logout to bottom
          const Spacer(),

          const Divider(),

          // 🔴 Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              final authService = GoogleAuthService();
              await authService.signOut();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
