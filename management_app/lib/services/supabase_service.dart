import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Check if student is on leave today
  Future<bool> isStudentOnLeave(String studentId, String today) async {
    final res = await supabase
        .from('leave_requests')
        .select()
        .eq('student_id', studentId)
        .lte('start_date', today)
        .gte('end_date', today)
        .maybeSingle();

    return res != null;
  }

  // Check if attendance already marked
  Future<bool> hasAttendance(String studentId, String today) async {
    final res = await supabase
        .from('mess_attendance')
        .select()
        .eq('student_id', studentId)
        .eq('date', today)
        .maybeSingle();

    return res != null;
  }

  // Mark attendance
  Future<void> markAttendance(String studentId) async {
    await supabase.from('mess_attendance').insert({
      'student_id': studentId,
      'date': DateTime.now().toIso8601String().split('T')[0],
      'scanned': true,
      'first_scan_time': DateTime.now().toIso8601String(),
    });
  }

  // Dashboard stats
  Future<int> getPendingBillsCount() async {
    final res = await supabase
        .from('billing')
        .select('id')
        .eq('status', 'pending');
    return res.length;
  }

  Future<int> getPaidBillsCount() async {
    final res = await supabase
        .from('billing')
        .select('id')
        .eq('status', 'paid');
    return res.length;
  }

  Future<int> getTotalRevenue() async {
    final res = await supabase
        .from('billing')
        .select('total_amount')
        .eq('status', 'paid');

    int sum = 0;
    for (final r in res) {
      sum += (r['total_amount'] ?? 0) as int;
    }
    return sum;
  }
}
