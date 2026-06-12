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
        backgroundColor: Colors.amber,
        elevation: 0,
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
                    color: Colors.amber,
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
                      child: const Icon(Icons.person, size: 60, color: Colors.amber),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
            Text(
              user?.name ?? 'Nama Pencari Tukang',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? 'email@example.com',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            _buildProfileItem(Icons.person_outline, 'Edit Profil', () {}),
            _buildProfileItem(Icons.history, 'Riwayat Transaksi', () {
              Navigator.pushNamed(context, '/history');
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
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, VoidCallback onTap, {Color textColor = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: Colors.amber),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
