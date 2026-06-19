import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              'Fitur Chat Internal telah dihapus.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Gunakan WhatsApp untuk berkomunikasi.'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            )
          ],
        ),
      ),
    );
  }
}
