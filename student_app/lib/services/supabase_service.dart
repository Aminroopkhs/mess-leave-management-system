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

  // Fetch all leave applications for a student
  Future<List<Map<String, dynamic>>> getLeaveApplications(
    String studentId,
  ) async {
    final res = await supabase
        .from('leave_requests')
        .select()
        .eq('student_id', studentId)
        .order('applied_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }

  // Calculate current month usage (days and amount)
  Future<Map<String, dynamic>> getCurrentMonthUsage(String studentId) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final today = now;

    // Total days from start of month to today
    final totalDays = today.difference(monthStart).inDays + 1;

    // Get all leave requests for current month (including future leaves in this month)
    final monthStartStr = monthStart.toIso8601String().split('T')[0];
    final monthEnd = DateTime(
      now.year,
      now.month + 1,
      0,
    ); // Last day of current month
    final monthEndStr = monthEnd.toIso8601String().split('T')[0];

    final leaveRequests = await supabase
        .from('leave_requests')
        .select()
        .eq('student_id', studentId)
        .lte('start_date', monthEndStr)
        .gte('end_date', monthStartStr);

    print('DEBUG: Found ${leaveRequests.length} leave requests');
    for (var leave in leaveRequests) {
      print('DEBUG: Leave from ${leave['start_date']} to ${leave['end_date']}');
    }

    // Calculate total leave days in current month and collect leave dates
    int leaveDays = 0;
    List<Map<String, String>> leavePeriods = [];

    for (var leave in leaveRequests) {
      final startDate = DateTime.parse(leave['start_date']);
      final endDate = DateTime.parse(leave['end_date']);

      // Add to leave periods display (show actual leave dates)
      final displayStart = startDate.isBefore(monthStart)
          ? monthStart
          : startDate;
      final displayEnd = endDate.isAfter(monthEnd) ? monthEnd : endDate;

      leavePeriods.add({
        'start': '${displayStart.day}/${displayStart.month}',
        'end': '${displayEnd.day}/${displayEnd.month}',
      });

      print(
        'DEBUG: Added leave period ${displayStart.day}/${displayStart.month} - ${displayEnd.day}/${displayEnd.month}',
      );

      // Adjust dates to be within current month bounds for counting days up to today
      final effectiveStart = startDate.isBefore(monthStart)
          ? monthStart
          : startDate;
      final effectiveEnd = endDate.isAfter(today) ? today : endDate;

      if (effectiveStart.isBefore(effectiveEnd) ||
          effectiveStart.isAtSameMomentAs(effectiveEnd)) {
        leaveDays += effectiveEnd.difference(effectiveStart).inDays + 1;
      }
    }

    print('DEBUG: Total leave periods: ${leavePeriods.length}');

    // Calculate chargeable days
    final chargeableDays = totalDays - leaveDays;
    const ratePerDay = 100;
    final totalAmount = chargeableDays * ratePerDay;

    final result = {
      'total_days': totalDays,
      'leave_days': leaveDays,
      'chargeable_days': chargeableDays,
      'rate_per_day': ratePerDay,
      'total_amount': totalAmount,
      'leave_periods': leavePeriods,
    };

    print('DEBUG: Returning result with ${leavePeriods.length} periods');

    return result;
  }
}
