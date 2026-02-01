import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class LeaveScreen extends StatefulWidget {
  final String studentId;
  const LeaveScreen({super.key, required this.studentId});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  DateTime? startDate;
  DateTime? endDate;
  final SupabaseService service = SupabaseService();

  // ✅ Leave must be applied at least 24 hours in advance
  bool isValidLeave(DateTime selectedDate) {
    final now = DateTime.now();
    final difference = selectedDate.difference(now);
    return difference.inHours >= 24;
  }

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && !isValidLeave(picked)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Leave must be applied at least 24 hours in advance"),
        ),
      );
      return;
    }

    setState(() {
      isStart ? startDate = picked : endDate = picked;
    });
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Select date";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Application"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.deepPurple),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Leave must be applied at least 24 hours in advance.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 🔹 Start Date
            _dateCard(
              title: "From Date",
              dateText: formatDate(startDate),
              icon: Icons.calendar_today,
              onTap: () => pickDate(true),
            ),

            const SizedBox(height: 16),

            // 🔹 End Date
            _dateCard(
              title: "To Date",
              dateText: formatDate(endDate),
              icon: Icons.calendar_today_outlined,
              onTap: () => pickDate(false),
            ),

            const SizedBox(height: 32),

            // 🔹 Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (startDate == null || endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select both dates"),
                      ),
                    );
                    return;
                  }

                  await service.submitLeave(
                    studentId: widget.studentId,
                    start: startDate!,
                    end: endDate!,
                  );

                  Navigator.pop(context);
                },
                child: const Text(
                  "Submit Leave Application",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI COMPONENT ----------------

  Widget _dateCard({
    required String title,
    required String dateText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
