import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  // Fungsi untuk membuka WhatsApp
  Future<void> _launchWhatsApp(String phone, String name) async {
    final String message = "Halo $name, saya dari Kangmas. Saya menghubungi terkait pekerjaan.";
    final Uri url = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Tidak bisa membuka WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pesan Aktif', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: 1, // Contoh: Ada 1 percakapan aktif
        padding: const EdgeInsets.all(15),
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text("Bantuan Kangmas", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Hubungi kami jika ada kendala"),
              trailing: const Icon(Icons.message, color: Colors.green),
              onTap: () => _launchWhatsApp("6281234567890", "Admin Kangmas"),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(context, auth),
      floatingActionButton: _buildFAB(context, auth),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFAB(BuildContext context, AuthProvider auth) {
    return FloatingActionButton(
      onPressed: () => Navigator.pushReplacementNamed(context, auth.user?.role == 'tukang' ? '/tukang_home' : '/user_home'),
      backgroundColor: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('asset/images/logo loading dan tombol tenggah.webp', fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AuthProvider auth) {
    return BottomAppBar(
      notchMargin: 10,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home_rounded, color: Colors.grey),
              onPressed: () => Navigator.pushReplacementNamed(context, auth.user?.role == 'tukang' ? '/tukang_home' : '/user_home'),
            ),
            IconButton(
              icon: const Icon(Icons.receipt_long_rounded, color: Colors.grey),
              onPressed: () => Navigator.pushReplacementNamed(context, '/history'),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.chat_rounded, color: Colors.amber, size: 28),
              onPressed: () {} // Halaman saat ini
            ),
            IconButton(
              icon: const Icon(Icons.person_rounded, color: Colors.grey),
              onPressed: () => Navigator.pushReplacementNamed(context, '/profile'),
            ),
          ],
        ),
      ),
    );
  }
}
