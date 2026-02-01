import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class BillScreen extends StatelessWidget {
  final String studentId;
  BillScreen({super.key, required this.studentId});

  final SupabaseService service = SupabaseService();

  String formatMonth(dynamic value) {
    if (value == null) return "Unknown Month";
    final date = DateTime.tryParse(value.toString());
    if (date == null) return "Unknown Month";
    return "${_monthName(date.month)} ${date.year}";
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bills"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.getBills(studentId),
        builder: (context, snapshot) {
          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (snapshot.hasError) {
            return const Center(
              child: Text("Failed to load bills"),
            );
          }

          final bills = snapshot.data ?? [];

          // 🟡 No bills
          if (bills.isEmpty) {
            return const Center(
              child: Text(
                "No bills generated yet",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // ✅ Bills list
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];

              final amount = bill['total_amount'] ?? 0;
              final status = bill['status'] ?? "pending";
              final month = formatMonth(bill['billing_month']);

              final isPaid = status.toString().toLowerCase() == "paid";

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isPaid
                      ? Colors.green.withOpacity(0.08)
                      : Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPaid ? Colors.green : Colors.orange,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPaid ? Icons.check_circle : Icons.warning_amber,
                      color: isPaid ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            month,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Amount: ₹$amount",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      status.toString().toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPaid ? Colors.green : Colors.orange,
                      ),
                    ),
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
