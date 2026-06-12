import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/auth_choice_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/tukang_home_screen.dart';
import 'screens/job_detail_screen.dart';
import 'screens/job_success_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/job_closing_screen.dart';
import 'screens/create_job_screen.dart';
import 'screens/order_summary_screen.dart';
import 'screens/user_job_success_screen.dart';
import 'screens/live_tracking_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const KangmasApp(),
    ),
  );
}

class KangmasApp extends StatelessWidget {
  const KangmasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KANGMAS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A), // Slate 900
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF3B82F6), // Blue 500
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/auth_choice') {
          final role = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => AuthChoiceScreen(role: role),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => SplashScreen(),
        '/role_selection': (context) => RoleSelectionScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/user_home': (context) => UserHomeScreen(),
        '/tukang_home': (context) => TukangHomeScreen(),
        '/job_detail': (context) => const JobDetailScreen(),
        '/job_success': (context) => const JobSuccessScreen(),
        '/chat_detail': (context) => const ChatDetailScreen(),
        '/chat_list': (context) => const ChatListScreen(),
        '/history': (context) => const HistoryScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/job_closing': (context) => const JobClosingScreen(),
        '/create_job': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map) {
            return CreateJobScreen(category: args['category']?.toString() ?? 'Lainnya');
          } else if (args is String) {
            return CreateJobScreen(category: args);
          }
          return const CreateJobScreen(category: 'Lainnya');
        },
        '/order_summary': (context) => const OrderSummaryScreen(),
        '/user_job_success': (context) => const UserJobSuccessScreen(),
        '/live_tracking': (context) => const LiveTrackingScreen(),
      },
    );
  }
}
