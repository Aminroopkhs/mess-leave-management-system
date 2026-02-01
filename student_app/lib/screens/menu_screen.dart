import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  final String studentId;
  const MenuScreen({super.key, required this.studentId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int selectedDayIndex = DateTime.now().weekday - 1; // 0 = Monday

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final Map<String, Map<String, List<String>>> weeklyMenu = {
    'Monday': {
      'Breakfast': ['Idli', 'Sambar', 'Coconut Chutney', 'Tea/Coffee'],
      'Lunch': ['Rice', 'Dal Fry', 'Aloo Gobi', 'Roti', 'Salad', 'Buttermilk'],
      'Snacks': ['Bread Pakora', 'Tea'],
      'Dinner': ['Rice', 'Rajma', 'Mixed Veg', 'Roti', 'Pickle'],
    },
    'Tuesday': {
      'Breakfast': ['Poha', 'Boiled Eggs', 'Bread & Butter', 'Tea/Coffee'],
      'Lunch': ['Rice', 'Sambar', 'Bhindi Fry', 'Roti', 'Curd', 'Papad'],
      'Snacks': ['Samosa', 'Tea'],
      'Dinner': ['Rice', 'Chana Masala', 'Palak Paneer', 'Roti', 'Salad'],
    },
    'Wednesday': {
      'Breakfast': ['Upma', 'Vada', 'Chutney', 'Tea/Coffee'],
      'Lunch': ['Rice', 'Dal Tadka', 'Cabbage Sabzi', 'Roti', 'Salad', 'Lassi'],
      'Snacks': ['Veg Cutlet', 'Tea'],
      'Dinner': ['Rice', 'Kadhi', 'Aloo Matar', 'Roti', 'Pickle'],
    },
    'Thursday': {
      'Breakfast': ['Paratha', 'Curd', 'Pickle', 'Tea/Coffee'],
      'Lunch': ['Rice', 'Dal Makhani', 'Baingan Bharta', 'Roti', 'Raita'],
      'Snacks': ['Kachori', 'Tea'],
      'Dinner': ['Rice', 'Chole', 'Paneer Butter Masala', 'Roti', 'Salad'],
    },
    'Friday': {
      'Breakfast': ['Puri', 'Aloo Sabzi', 'Halwa', 'Tea/Coffee'],
      'Lunch': ['Rice', 'Yellow Dal', 'Tinda Sabzi', 'Roti', 'Buttermilk'],
      'Snacks': ['Bhel Puri', 'Tea'],
      'Dinner': ['Rice', 'Moong Dal', 'Capsicum Paneer', 'Roti', 'Pickle'],
    },
    'Saturday': {
      'Breakfast': ['Chole Bhature', 'Pickle', 'Lassi', 'Tea/Coffee'],
      'Lunch': ['Veg Biryani', 'Raita', 'Mirchi Ka Salan', 'Papad'],
      'Snacks': ['Pav Bhaji', 'Tea'],
      'Dinner': ['Rice', 'Dal Fry', 'Mix Veg', 'Roti', 'Ice Cream'],
    },
    'Sunday': {
      'Breakfast': ['Masala Dosa', 'Sambar', 'Chutney', 'Tea/Coffee'],
      'Lunch': [
        'Jeera Rice',
        'Paneer Tikka Masala',
        'Dal Makhani',
        'Naan',
        'Gulab Jamun',
      ],
      'Snacks': ['Pasta', 'Cold Drink'],
      'Dinner': ['Rice', 'Chicken/Soya Curry', 'Roti', 'Salad', 'Kheer'],
    },
  };

  final Map<String, IconData> mealIcons = {
    'Breakfast': Icons.free_breakfast,
    'Lunch': Icons.lunch_dining,
    'Snacks': Icons.cookie,
    'Dinner': Icons.dinner_dining,
  };

  final Map<String, Color> mealColors = {
    'Breakfast': const Color(0xFFFB923C),
    'Lunch': const Color(0xFF10B981),
    'Snacks': const Color(0xFF8B5CF6),
    'Dinner': const Color(0xFF6366F1),
  };

  final Map<String, String> mealTimes = {
    'Breakfast': '7:30 - 9:30 AM',
    'Lunch': '12:30 - 2:30 PM',
    'Snacks': '5:00 - 6:00 PM',
    'Dinner': '7:30 - 9:30 PM',
  };

  @override
  Widget build(BuildContext context) {
    final selectedDay = days[selectedDayIndex];
    final todayMenu = weeklyMenu[selectedDay]!;
    final isToday = selectedDayIndex == DateTime.now().weekday - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Weekly Menu",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Day selector
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: List.generate(days.length, (index) {
                  final isSelected = index == selectedDayIndex;
                  final isTodayChip = index == DateTime.now().weekday - 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => selectedDayIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : isTodayChip
                              ? const Color(0xFF6366F1).withOpacity(0.1)
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: isTodayChip && !isSelected
                              ? Border.all(
                                  color: const Color(
                                    0xFF6366F1,
                                  ).withOpacity(0.3),
                                )
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              days[index].substring(0, 3),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: isSelected
                                    ? Colors.white
                                    : isTodayChip
                                    ? const Color(0xFF6366F1)
                                    : Colors.grey[700],
                              ),
                            ),
                            if (isTodayChip) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF6366F1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Header with day name
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Text(
                  selectedDay,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Today",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: todayMenu.length,
              itemBuilder: (context, index) {
                final meal = todayMenu.keys.elementAt(index);
                final items = todayMenu[meal]!;
                final color = mealColors[meal]!;
                final icon = mealIcons[meal]!;
                final time = mealTimes[meal]!;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meal header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),

                      // Menu items
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: items.map((item) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Text(
                                item,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
