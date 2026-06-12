import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthChoiceScreen extends StatelessWidget {
  final String role;

  const AuthChoiceScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    bool isTukang = role == 'tukang';
    String bgImage = isTukang ? 'assets/images/tukang_choice_bg.png' : 'assets/images/user_choice_bg.png';
    String prompt = isTukang ? 'Apakah kamu\nsudah punya akun\ntukang?' : 'Apakah kamu\nsudah punya akun\nPencari Tukang?';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              right: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 200,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      prompt,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 50),
                  _buildChoiceButton(
                    context,
                    title: 'Log In',
                    subtitle: '*jika sudah punya akun',
                    onTap: () => Navigator.pushNamed(context, '/login', arguments: role),
                  ),
                  const SizedBox(height: 20),
                  _buildChoiceButton(
                    context,
                    title: 'Register',
                    subtitle: '*jika belum punya akun',
                    onTap: () async {
                      if (isTukang) {
                        // Gunakan IP Laptop Anda
                        final Uri url = Uri.parse('http://192.168.101.23:8000/register-tukang');
                        try {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal membuka browser: $e')),
                          );
                        }
                      } else {
                        Navigator.pushNamed(context, '/register', arguments: role);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(BuildContext context, {required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB800),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
