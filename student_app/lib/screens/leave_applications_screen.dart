import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/supabase_service.dart';

class LeaveApplicationsScreen extends StatefulWidget {
  final String studentId;
  const LeaveApplicationsScreen({super.key, required this.studentId});

  @override
  State<LeaveApplicationsScreen> createState() =>
      _LeaveApplicationsScreenState();
}

class _LeaveApplicationsScreenState extends State<LeaveApplicationsScreen> {
  final SupabaseService service = SupabaseService();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  List<Map<String, dynamic>> leaveApplications = [];
  Set<DateTime> leaveDays = {};
  bool isLoading = true;
  int totalLeaveDays = 0;
  static const int ratePerDay = 100;

  @override
  void initState() {
    super.initState();
    _loadLeaveApplications();
  }

  Future<void> _loadLeaveApplications() async {
    try {
      final applications = await service.getLeaveApplications(widget.studentId);

      Set<DateTime> allLeaveDays = {};
      int totalDays = 0;

      for (var leave in applications) {
        final startDate = DateTime.parse(leave['start_date']);
        final endDate = DateTime.parse(leave['end_date']);

        // Add all days in the leave period to the set
        for (
          var d = startDate;
          d.isBefore(endDate) || d.isAtSameMomentAs(endDate);
          d = d.add(const Duration(days: 1))
        ) {
          allLeaveDays.add(DateTime(d.year, d.month, d.day));
        }

        totalDays += endDate.difference(startDate).inDays + 1;
      }

      if (mounted) {
        setState(() {
          leaveApplications = applications;
          leaveDays = allLeaveDays;
          totalLeaveDays = totalDays;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _isLeaveDay(DateTime day) {
    return leaveDays.contains(DateTime(day.year, day.month, day.day));
  }

  Map<String, dynamic>? _getLeaveForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    for (var leave in leaveApplications) {
      final startDate = DateTime.parse(leave['start_date']);
      final endDate = DateTime.parse(leave['end_date']);
      final normalizedStart = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

      if ((normalizedDay.isAfter(normalizedStart) ||
              normalizedDay.isAtSameMomentAs(normalizedStart)) &&
          (normalizedDay.isBefore(normalizedEnd) ||
              normalizedDay.isAtSameMomentAs(normalizedEnd))) {
        return leave;
      }
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Leave Calendar",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // Calendar Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2024, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    availableGestures: AvailableGestures.horizontalSwipe,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    rowHeight: 48,
                    daysOfWeekHeight: 40,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                      ),
                      defaultTextStyle: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                      weekendTextStyle: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      outsideDaysVisible: false,
                      cellMargin: const EdgeInsets.all(4),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      headerPadding: const EdgeInsets.only(bottom: 16),
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      leftChevronIcon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                      ),
                      rightChevronIcon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        if (_isLeaveDay(day)) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFB923C).withOpacity(0.85),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      todayBuilder: (context, day, focusedDay) {
                        if (_isLeaveDay(day)) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFB923C).withOpacity(0.85),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF6366F1),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }
                        return Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendItem(
                    const Color(0xFFFB923C).withOpacity(0.85),
                    "Leave Days",
                  ),
                  const SizedBox(width: 32),
                  _legendItem(
                    const Color(0xFF6366F1).withOpacity(0.15),
                    "Today",
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Bottom Summary Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Total Leave Summary",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.savings_outlined,
                            color: const Color(0xFF10B981),
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.black87,
                                ),
                                children: [
                                  TextSpan(
                                    text: "$totalLeaveDays days",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6366F1),
                                    ),
                                  ),
                                  TextSpan(
                                    text: " × ",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  TextSpan(
                                    text: "₹$ratePerDay",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " = ",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  TextSpan(
                                    text: "₹${totalLeaveDays * ratePerDay}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF10B981),
                                      fontSize: 22,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: " saved",
                                    style: TextStyle(
                                      color: Color(0xFF10B981),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "You've applied for $totalLeaveDays days of leave",
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showLeaveDetails(Map<String, dynamic> leave) {
    final startDate = DateTime.parse(leave['start_date']);
    final endDate = DateTime.parse(leave['end_date']);
    final days = endDate.difference(startDate).inDays + 1;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Leave Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _detailRow(Icons.calendar_today, "From", _formatDate(startDate)),
              _detailRow(
                Icons.calendar_today_outlined,
                "To",
                _formatDate(endDate),
              ),
              _detailRow(
                Icons.timelapse,
                "Duration",
                "$days ${days == 1 ? 'day' : 'days'}",
              ),
              _detailRow(
                Icons.savings_outlined,
                "Amount Saved",
                "₹${days * ratePerDay}",
              ),
              if (leave['applied_at'] != null)
                _detailRow(
                  Icons.access_time,
                  "Applied On",
                  _formatDate(DateTime.parse(leave['applied_at'])),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
