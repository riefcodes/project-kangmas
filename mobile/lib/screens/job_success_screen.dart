import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JobSuccessScreen extends StatelessWidget {
  const JobSuccessScreen({super.key});

  // Fungsi untuk membuka WhatsApp
  Future<void> _launchWhatsApp() async {
    const String phoneNumber = "6281234567890"; // Nanti ini diambil dari data pelanggan
    const String message = "Halo, saya Tukang dari aplikasi Kangmas. Saya sudah mengambil pekerjaan Anda.";
    final Uri url = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak bisa membuka WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 150, color: Color(0xFFA5D6A7)),
            const SizedBox(height: 40),
            const Text(
              'Terimakasih',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pekerjaan berhasil diambil! Silakan hubungi pelanggan untuk konfirmasi keberangkatan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _launchWhatsApp,
                icon: const Icon(Icons.message, color: Colors.white),
                label: const Text('Hubungi via WhatsApp', style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Warna WhatsApp
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/tukang_home', (route) => false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
