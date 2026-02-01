import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Extract student ID from email (last 7 characters before @)
  static String getStudentIdFromEmail(String email) {
    final beforeAt = email.split('@')[0];
    if (beforeAt.length <= 7) {
      return beforeAt;
    }
    return beforeAt.substring(beforeAt.length - 7);
  }

  // Fetch logged-in student profile
  Future<Map<String, dynamic>?> getStudentProfile(String studentId) async {
    final res = await supabase
        .from('students')
        .select()
        .eq('student_id', studentId)
        .maybeSingle();
    return res;
  }

  // Get student profile by email
  Future<Map<String, dynamic>?> getStudentProfileByEmail(String email) async {
    final studentId = getStudentIdFromEmail(email);
    return getStudentProfile(studentId);
  }

  // Create a new student profile
  Future<Map<String, dynamic>> createStudentProfile({
    required String email,
    required String name,
    String? phone,
    String hostel = 'Not Assigned',
    int year = 1,
    String department = 'Not Assigned',
  }) async {
    final studentId = getStudentIdFromEmail(email);
    final res = await supabase
        .from('students')
        .insert({
          'student_id': studentId,
          'name': name,
          'phone': phone ?? 'Not Provided',
          'email': email,
          'hostel': hostel,
          'year': year,
          'department': department,
        })
        .select()
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
}
