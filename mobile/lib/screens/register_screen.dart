import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  // Tukang specific
  final _addressCtl = TextEditingController();
  final _priceCtl = TextEditingController();

  String _role = 'user';
  String _category = 'listrik';

  Future<void> _register() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    Map<String, dynamic> data = {
      'name': _nameCtl.text,
      'email': _emailCtl.text.trim(),
      'password': _passCtl.text,
      'password_confirmation': _passConfCtl.text,
      'role': _role,
      'phone_number': _phoneCtl.text,
    };

    if (_role == 'tukang') {
      data['category'] = _category;
      data['address'] = _addressCtl.text;
      data['base_price'] = int.tryParse(_priceCtl.text) ?? 50000;
      // Mock latitude/longitude near Telkom Univ for MVP
      data['latitude'] = -6.9730;
      data['longitude'] = 107.6307;
    }

    try {
      final success = await auth.register(data);
      if (success) {
        if (auth.user?.role == 'tukang') {
          Navigator.pushNamedAndRemoveUntil(context, '/tukang_home', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/user_home', (route) => false);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar KANGMAS')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Mendaftar sebagai'),
              items: const [
                DropdownMenuItem(value: 'user', child: Text('Pencari Jasa (User)')),
                DropdownMenuItem(value: 'tukang', child: Text('Tukang (Worker)')),
              ],
              onChanged: (val) => setState(() => _role = val!),
            ),
            TextField(controller: _nameCtl, decoration: const InputDecoration(labelText: 'Nama Lengkap')),
            TextField(controller: _emailCtl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _phoneCtl, decoration: const InputDecoration(labelText: 'No. WhatsApp')),
            TextField(controller: _passCtl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: _passConfCtl, decoration: const InputDecoration(labelText: 'Konfirmasi Password'), obscureText: true),

            if (_role == 'tukang') ...[
              const Divider(height: 30, thickness: 2,),
              const Text('Data Profil Tukang', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Kategori Keahlian'),
                items: const [
                  DropdownMenuItem(value: 'listrik', child: Text('Listrik')),
                  DropdownMenuItem(value: 'air', child: Text('Air / Plumbing')),
                  DropdownMenuItem(value: 'bangunan', child: Text('Bangunan')),
                ],
                onChanged: (val) => setState(() => _category = val!),
              ),
              TextField(controller: _addressCtl, decoration: const InputDecoration(labelText: 'Alamat Tinggal')),
              TextField(controller: _priceCtl, decoration: const InputDecoration(labelText: 'Harga Dasar Jasa (Rp)'), keyboardType: TextInputType.number),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Note: Lokasi akan di-set otomatis ke area Telkom University untuk MVP demo.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ],

            const SizedBox(height: 20),
            if (auth.isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _register,
                child: const Text('Daftar Sekarang'),
              ),
          ],
        ),
      ),
    );
  }
}
