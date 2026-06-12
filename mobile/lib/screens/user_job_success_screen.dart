import 'package:flutter/material.dart';

class UserJobSuccessScreen extends StatelessWidget {
  const UserJobSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Success Icon with wavy background (simplified with Icon for now)
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA5D6A7).withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(Icons.check_circle, size: 100, color: Color(0xFF81C784)),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Terimakasih',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'kami akan informasikan lagi ketika ada tukang yang tertarik dengan tawaran Anda',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Kembali ke Beranda dan bersihkan tumpukan layar sebelumnya
                  Navigator.pushNamedAndRemoveUntil(context, '/user_home', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
