import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReviewScreen extends StatefulWidget {
  final int orderId;
  final String tukangName;

  const ReviewScreen({super.key, required this.orderId, required this.tukangName});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int rating = 5;
  final _commentCtl = TextEditingController();
  bool isSubmitting = false;

  Future<void> _submitReview() async {
    setState(() => isSubmitting = true);
    try {
      final res = await ApiService.post('/reviews', {
        'order_id': widget.orderId,
        'rating': rating,
        'comment': _commentCtl.text.trim(),
      });

      if (res['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ulasan berhasil dikirim')));
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Beri Ulasan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tukang: ${widget.tukangName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Rating (1-5):'),
            Slider(
              value: rating.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: rating.toString(),
              onChanged: (val) => setState(() => rating = val.toInt()),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentCtl,
              decoration: const InputDecoration(labelText: 'Komentar (Opsional)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitReview,
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Kirim Ulasan', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
