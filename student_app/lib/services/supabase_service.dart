import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Fetch logged-in student profile
  Future<Map<String, dynamic>> getStudentProfile(String studentId) async {
    final res = await supabase
        .from('students')
        .select()
        .eq('student_id', studentId)
        .single();
    return res;
  }

  // Fetch bills
  Future<List<Map<String, dynamic>>> getBills(String studentId) async {
    final res = await supabase
        .from('billing')
        .select()
        .eq('student_id', studentId);
    return List<Map<String, dynamic>>.from(res);
  }

  // Submit leave request
  Future<void> submitLeave({
    required String studentId,
    required DateTime start,
    required DateTime end,
  }) async {
    await supabase.from('leave_requests').insert({
      'student_id': studentId,
      'start_date': start.toIso8601String(),
      'end_date': end.toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getCurrentMonthBill(String studentId) async {
    final now = DateTime.now();
    final monthStart = DateTime(
      now.year,
      now.month,
      1,
    ).toIso8601String().split('T')[0];

    final res = await supabase
        .from('billing')
        .select()
        .eq('student_id', studentId)
        .eq('billing_month', monthStart)
        .maybeSingle();

    return res;
  }

  Future<Map<String, dynamic>?> getTodayLeave(String studentId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final res = await supabase
        .from('leave_requests')
        .select()
        .eq('student_id', studentId)
        .lte('start_date', today)
        .gte('end_date', today)
        .maybeSingle();

    return res;
  }

  // Fetch all leave applications for a student
  Future<List<Map<String, dynamic>>> getLeaveApplications(String studentId) async {
    final res = await supabase
        .from('leave_requests')
        .select()
        .eq('student_id', studentId)
        .order('applied_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }
}
