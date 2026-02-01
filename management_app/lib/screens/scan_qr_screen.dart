import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/supabase_service.dart';
import 'sidebar_drawer.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  final service = SupabaseService();
  bool processing = false;

  Future<void> handleScan(String studentId) async {
    if (processing) return;
    processing = true;

    final today = DateTime.now().toIso8601String().split('T')[0];

    if (await service.isStudentOnLeave(studentId, today)) {
      show("Rejected", "Student is on leave");
    } else if (await service.hasAttendance(studentId, today)) {
      show("Already Counted", "Attendance already marked");
    } else {
      await service.markAttendance(studentId);
      show("Success", "Attendance recorded");
    }

    processing = false;
  }

  void show(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR")),
      drawer: const SidebarDrawer(),
      body: MobileScanner(
        onDetect: (capture) {
          final code = capture.barcodes.first.rawValue;
          if (code != null) handleScan(code);
        },
      ),
    );
  }
}
