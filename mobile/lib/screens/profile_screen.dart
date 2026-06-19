import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB800),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Profil Saya', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB800),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, size: 60, color: Color(0xFFFFB800)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
            Text(
              user?.name ?? 'Nama Pengguna',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'email@example.com',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildProfileItem(Icons.person_outline, 'Edit Profil', () {}),
            _buildProfileItem(Icons.history, 'Riwayat Transaksi', () {
               Navigator.pushReplacementNamed(context, '/history');
            }),
            _buildProfileItem(Icons.help_outline, 'Pusat Bantuan', () {}),
            _buildProfileItem(Icons.settings_outlined, 'Pengaturan', () {}),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(),
            ),
            _buildProfileItem(Icons.logout, 'Keluar', () async {
              await auth.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (route) => false);
            }, textColor: Colors.red),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, auth),
      floatingActionButton: _buildFAB(context, auth),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap, {Color textColor = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFFB800)),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
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
              icon: const Icon(Icons.chat_rounded, color: Colors.grey),
              onPressed: () => Navigator.pushReplacementNamed(context, '/chat_list'),
            ),
            IconButton(
              icon: const Icon(Icons.person_rounded, color: Color(0xFFFFB800), size: 28),
              onPressed: () {} // Halaman saat ini
            ),
          ],
        ),
      ),
    );
  }
}
