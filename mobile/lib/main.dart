import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/user_home_screen.dart';
import 'screens/tukang_home_screen.dart';

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
      title: 'KANGMAS MVP',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/user_home': (context) => UserHomeScreen(),
        '/tukang_home': (context) => TukangHomeScreen(),
      },
    );
  }
}
