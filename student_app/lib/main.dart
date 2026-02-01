import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/leave_screen.dart';
import 'screens/qr_screen.dart';
import 'screens/bill_screen.dart';
import 'screens/leave_applications_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  static const String tempStudentId = 'S004';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Mess Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),


      home: const HomeScreen(studentId: tempStudentId),

      routes: {
        '/home': (context) =>
            const HomeScreen(studentId: tempStudentId),

        '/leave': (context) =>
            const LeaveScreen(studentId: tempStudentId),

        '/qr': (context) =>
            const QRScreen(studentId: tempStudentId),

        '/bills': (context) =>
            BillScreen(studentId: tempStudentId),

        '/leave-applications': (context) =>
            LeaveApplicationsScreen(studentId: tempStudentId),
      },
    );
  }
}
