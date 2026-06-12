import 'package:flutter/material.dart';import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _passConfCtl = TextEditingController();

  Future<void> _register() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (_passCtl.text != _passConfCtl.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password tidak cocok")));
      return;
    }

    Map<String, dynamic> data = {
      'name': _nameCtl.text,
      'email': _emailCtl.text.trim(),
      'password': _passCtl.text,
      'password_confirmation': _passConfCtl.text,
      'role': 'user', // Register via app hanya untuk user
      'phone_number': _phoneCtl.text,
    };

    try {
      final success = await auth.register(data);
      if (success) {
        Navigator.pushNamedAndRemoveUntil(context, '/user_home', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC107),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Daftar Baru',
                    style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text('Lengkapi data untuk membuat akun', style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  _buildTextField(_nameCtl, 'Nama Lengkap', Icons.person_outline),
                  const SizedBox(height: 15),
                  _buildTextField(_emailCtl, 'Email', Icons.email_outlined),
                  const SizedBox(height: 15),
                  _buildTextField(_phoneCtl, 'No. WhatsApp', Icons.phone_android_outlined),
                  const SizedBox(height: 15),
                  _buildTextField(_passCtl, 'Password', Icons.lock_outline, isPassword: true),
                  const SizedBox(height: 15),
                  _buildTextField(_passConfCtl, 'Konfirmasi Password', Icons.lock_outline, isPassword: true),
                  const SizedBox(height: 30),
                  if (auth.isLoading)
                    const CircularProgressIndicator(color: Color(0xFFFFC107))
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: const Text('Daftar Sekarang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctl, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: ctl,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFFC107)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}
