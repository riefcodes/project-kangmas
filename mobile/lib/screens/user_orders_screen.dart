import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';
import 'review_screen.dart';

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({super.key});

  @override
  _UserOrdersScreenState createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  List<OrderModel> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => isLoading = true);
    try {
      final res = await ApiService.get('/orders');
      if (res['success']) {
        final List data = res['data']['data']; // paginated response structure
        setState(() {
          orders = data.map((e) => OrderModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _cancelOrder(int id) async {
    try {
      final res = await ApiService.put('/orders/$id', {'status': 'cancelled'});
      if (res['success']) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan dibatalkan')));
        _fetchOrders();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    // Basic format assuming phone starts with 0 or 62
    String formattedPhone = phone;
    if (phone.startsWith('0')) {
      formattedPhone = '62${phone.substring(1)}';
    }
    final url = Uri.parse('https://wa.me/$formattedPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak dapat membuka WhatsApp')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(child: Text('Belum ada pesanan.'))
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
                            Text('Tukang: ${order.tukang?.name ?? '-'}'),
                            Text('Kendala: ${order.description}'),
                            if (order.totalPrice != null)
                              Text('Total Harga: Rp ${order.totalPrice}', style: const TextStyle(fontWeight: FontWeight.bold)),

                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (order.status != 'cancelled' && order.status != 'completed')
                                  TextButton.icon(
                                    icon: const Icon(Icons.chat, color: Colors.green),
                                    label: const Text('Chat WA', style: TextStyle(color: Colors.green)),
                                    onPressed: () => _openWhatsApp(order.tukang?.phoneNumber ?? ''),
                                  ),
                                if (order.status == 'pending')
                                  TextButton(
                                    onPressed: () => _cancelOrder(order.id),
                                    child: const Text('Batalkan', style: TextStyle(color: Colors.red)),
                                  ),
                                if (order.status == 'completed')
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => ReviewScreen(orderId: order.id, tukangName: order.tukang?.name ?? 'Tukang')),
                                      ).then((_) => _fetchOrders());
                                    },
                                    child: const Text('Beri Ulasan'),
                                  ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
