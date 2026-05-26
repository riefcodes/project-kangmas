import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateOrderScreen extends StatefulWidget {
  final int tukangId;
  final String tukangName;
  final String category;

  const CreateOrderScreen({
    super.key,
    required this.tukangId,
    required this.tukangName,
    required this.category,
  });

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _descCtl = TextEditingController();
  bool isSubmitting = false;

  Future<void> _submitOrder() async {
    if (_descCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deskripsi masalah harus diisi')));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final res = await ApiService.post('/orders', {
        'tukang_id': widget.tukangId,
        'description': _descCtl.text.trim(),
      });

      if (res['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat!')));
        // Navigate back to Home
        Navigator.popUntil(context, ModalRoute.withName('/user_home'));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tukang: ${widget.tukangName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Kategori: ${widget.category.toUpperCase()}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: _descCtl,
              decoration: const InputDecoration(
                labelText: 'Jelaskan masalah Anda',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            const Text('Metode Pembayaran: Cash on Delivery (COD)', style: TextStyle(fontStyle: FontStyle.italic)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitOrder,
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Pesanan', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
