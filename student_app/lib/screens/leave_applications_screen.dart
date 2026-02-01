import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class LeaveApplicationsScreen extends StatelessWidget {
  final String studentId;
  LeaveApplicationsScreen({super.key, required this.studentId});

  final SupabaseService service = SupabaseService();

  String formatDate(dynamic value) {
    if (value == null) return "Unknown Date";
    final date = DateTime.tryParse(value.toString());
    if (date == null) return "Unknown Date";
    return "${date.day}/${date.month}/${date.year}";
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  int calculateDays(dynamic startDate, dynamic endDate) {
    final start = DateTime.tryParse(startDate.toString());
    final end = DateTime.tryParse(endDate.toString());
    if (start == null || end == null) return 0;
    return end.difference(start).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Applications"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.getLeaveApplications(studentId),
        builder: (context, snapshot) {
          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (snapshot.hasError) {
            print(snapshot.error);
            return const Center(
              child: Text("Failed to load leave applications"),
            );
          }

          final applications = snapshot.data ?? [];

          // 🟡 No applications
          if (applications.isEmpty) {
            return const Center(
              child: Text(
                "No leave applications yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // ✅ Applications list
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];

              final startDate = app['start_date'];
              final endDate = app['end_date'];
              final status = app['status'] ?? "default";
              final days = calculateDays(startDate, endDate);

              final statusColor = getStatusColor(status);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              getStatusIcon(status),
                              color: statusColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              status.toString().toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$days ${days == 1 ? 'day' : 'days'}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 🔹 Date Range
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${formatDate(startDate)} - ${formatDate(endDate)}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // 🔹 Optional: Show created date
                    if (app['applied_at'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Applied on ${formatDate(app['applied_at'])}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
