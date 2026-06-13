import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthChoiceScreen extends StatelessWidget {
  final String role;

  const AuthChoiceScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    bool isTukang = role == 'tukang';
    String mascotImage = isTukang ? 'asset/images/Tukang maskot.webp' : 'asset/images/pengguna maskot.webp';
    String prompt = isTukang ? 'Apakah kamu\nsudah punya akun\ntukang?' : 'Apakah kamu\nsudah punya akun\nPencari Tukang?';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Maskot sebagai background yang menutupi sebagian layar
          Positioned(
            left: -100, // Menjorok ke kiri agar bagian tubuh maskot lebih ke tengah
            bottom: -50, // Sedikit turun ke bawah
            top: 40,
            child: Opacity(
              opacity: 0.5, // Sedikit lebih transparan agar teks tetap mudah dibaca
              child: Image.asset(
                mascotImage,
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 1.6, // Perbesar skala agar menutupi setengah halaman lebih
                alignment: Alignment.bottomLeft,
              ),
            ),
          ),

          // Konten Utama
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol Kembali
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 10),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const Spacer(), // Menyeimbangkan posisi konten ke tengah/bawah

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      // Balon Teks / Prompt
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9), // Sedikit transparan agar BG terlihat sedikit
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
                          ],
                        ),
                        child: Text(
                          prompt,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Tombol Log In
                      _buildChoiceButton(
                        context,
                        title: 'Log In',
                        subtitle: '*jika sudah punya akun',
                        color: const Color(0xFFFFB800),
                        onTap: () => Navigator.pushNamed(context, '/login', arguments: role),
                      ),
                      const SizedBox(height: 20),

                      // Tombol Register
                      _buildChoiceButton(
                        context,
                        title: 'Register',
                        subtitle: '*jika belum punya akun',
                        color: const Color(0xFF0F172A),
                        onTap: () async {
                          if (isTukang) {
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
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
