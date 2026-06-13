import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.initAuth();

    if (auth.isAuthenticated) {
      if (auth.user?.role == 'tukang') {
        Navigator.pushReplacementNamed(context, '/tukang_home');
      } else {
        Navigator.pushReplacementNamed(context, '/user_home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/role_selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menampilkan logo kustom Anda di Splash Screen
            Image.asset(
              'asset/images/logo loading dan tombol tenggah.webp',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Color(0xFFFFB800),
            ),
          ],
        ),
      ),
    );
  }
}
