import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';

class TukangHomeScreen extends StatefulWidget {
  const TukangHomeScreen({super.key});

  @override
  _TukangHomeScreenState createState() => _TukangHomeScreenState();
}

class _TukangHomeScreenState extends State<TukangHomeScreen> {
  bool isActive = false;
  List<OrderModel> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    isActive = auth.user?.tukangProfile?.isActive ?? false;
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => isLoading = true);
    try {
      final res = await ApiService.get('/orders');
      if (res['success']) {
        final List data = res['data']['data'];
        setState(() {
          orders = data.map((e) => OrderModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleActive() async {
    try {
      final res = await ApiService.patch('/tukang/toggle-active');
      if (res['success']) {
        setState(() {
          isActive = res['data']['is_active'];
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _updateOrderStatus(int id, String status, {int? price}) async {
    try {
      final Map<String, dynamic> body = {'status': status};
      if (price != null) body['total_price'] = price;

      final res = await ApiService.put('/orders/$id', body);
      if (res['success']) {
        _fetchOrders();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status pesanan diperbarui')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _showCompleteDialog(int orderId) async {
    final priceCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Selesaikan Pesanan'),
          content: TextField(
            controller: priceCtl,
            decoration: const InputDecoration(labelText: 'Total Biaya (Rp)'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final price = int.tryParse(priceCtl.text);
                if (price != null && price > 0) {
                  Navigator.pop(context);
                  _updateOrderStatus(orderId, 'completed', price: price);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap masukkan harga yang valid')));
                }
              },
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openWhatsApp(String phone) async {
    String formattedPhone = phone;
    if (phone.startsWith('0')) {
      formattedPhone = '62${phone.substring(1)}';
    }
    final url = Uri.parse('https://wa.me/$formattedPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka WhatsApp')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Tukang'),
        actions: [
          Row(
            children: [
              const Text('Aktif'),
              Switch(
                value: isActive,
                onChanged: (val) => _toggleActive(),
                activeThumbColor: Colors.green,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: Text(
              'Profil: ⭐ ${auth.user?.tukangProfile?.avgRating ?? 0} | Kategori: ${auth.user?.tukangProfile?.category.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          const Text('Daftar Pekerjaan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? const Center(child: Text('Belum ada pesanan masuk.'))
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          Color statusColor = Colors.grey;
                          if (order.status == 'pending') statusColor = Colors.orange;
                          if (order.status == 'accepted') statusColor = Colors.blue;
                          if (order.status == 'completed') statusColor = Colors.green;
                          if (order.status == 'cancelled') statusColor = Colors.red;

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Chip(
                                        label: Text(order.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                        backgroundColor: statusColor,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Pelanggan: ${order.user?.name ?? '-'}'),
                                  Text('Kendala: ${order.description}'),
                                  if (order.totalPrice != null)
                                    Text('Total Harga: Rp ${order.totalPrice}', style: const TextStyle(fontWeight: FontWeight.bold)),

                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (order.status == 'pending' || order.status == 'accepted')
                                        TextButton.icon(
                                          icon: const Icon(Icons.chat, color: Colors.green),
                                          label: const Text('Hubungi WA', style: TextStyle(color: Colors.green)),
                                          onPressed: () => _openWhatsApp(order.user?.phoneNumber ?? ''),
                                        ),
                                      if (order.status == 'pending')
                                        ElevatedButton(
                                          onPressed: () => _updateOrderStatus(order.id, 'accepted'),
                                          child: const Text('Terima Order'),
                                        ),
                                      if (order.status == 'accepted')
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                          onPressed: () => _showCompleteDialog(order.id),
                                          child: const Text('Selesaikan', style: TextStyle(color: Colors.white)),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
