import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  // Fungsi untuk membuka WhatsApp
  Future<void> _launchWhatsApp(String phone, String name) async {
    final String message = "Halo $name, saya Tukang dari Kangmas. Saya menghubungi terkait pekerjaan yang saya ambil.";
    final Uri url = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak bisa membuka WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pekerjaan Aktif', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: 2, // Contoh: Ada 2 pekerjaan aktif
        itemBuilder: (context, index) {
          String customerName = index == 0 ? "Budi Santoso" : "Siti Aminah";
          String phoneNumber = index == 0 ? "6281234567890" : "6289876543210";
          String jobType = index == 0 ? "Perbaikan Atap" : "Pemasangan Pintu";

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(jobType),
                  const SizedBox(height: 5),
                  const Text("Ketuk untuk hubungi via WhatsApp", style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: const Icon(Icons.message, color: Colors.green),
              onTap: () => _launchWhatsApp(phoneNumber, customerName),
            ),
          );
        },
      ),
    );
  }
}
