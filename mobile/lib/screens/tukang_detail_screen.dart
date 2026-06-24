import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_order_screen.dart';

class TukangDetailScreen extends StatefulWidget {
  final int tukangId;

  const TukangDetailScreen({super.key, required this.tukangId});

  @override
  _TukangDetailScreenState createState() => _TukangDetailScreenState();
}

class _TukangDetailScreenState extends State<TukangDetailScreen> {
  Map<String, dynamic>? tukangData;
  Map<String, dynamic>? reviewData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final tRes = await ApiService.get('/tukang/${widget.tukangId}');
      final rRes = await ApiService.get('/reviews/tukang/${widget.tukangId}');

      if (tRes['success'] && rRes['success']) {
        setState(() {
          tukangData = tRes['data'];
          reviewData = rRes['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tukang')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final t = tukangData!;
    final user = t['user'];
    final reviews = reviewData!['reviews'] as List;

    return Scaffold(
      appBar: AppBar(title: Text(user['name'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Text(user['name'][0], style: const TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Kategori: ${t['category'].toString().toUpperCase()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('No HP: ${user['phone_number']}'),
            Text('Alamat: ${t['address']}'),
            Text('Harga Dasar: Rp ${t['base_price']}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                Text(' ${t['avg_rating']} / 5.0 (${t['total_reviews']} ulasan)', style: const TextStyle(fontSize: 16)),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateOrderScreen(
                        tukangId: user['id'],
                        tukangName: user['name'],
                        category: t['category'],
                        basePrice: t['base_price'].toString(),
                      ),
                    ),
                  );
                },
                child: const Text('Pesan Jasa Sekarang', style: TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(height: 30),
            const Text('Ulasan Pelanggan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            if (reviews.isEmpty)
              const Text('Belum ada ulasan.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final r = reviews[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(r['user']['name'] ?? 'User'),
                    subtitle: Text(r['comment'] ?? 'Tanpa komentar.'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${r['rating']}'),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
