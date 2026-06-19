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
        final List data = res['data']; // not paginated
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Pesanan Saya', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Belum ada pesanan aktif.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    
                    Color statusColor = Colors.grey;
                    Color statusBgColor = Colors.grey.shade100;
                    String statusText = 'MENUNGGU';

                    if (order.status == 'pending') {
                      statusColor = Colors.orange.shade700;
                      statusBgColor = Colors.orange.shade50;
                      statusText = 'MENUNGGU';
                    }
                    if (order.status == 'accepted') {
                      statusColor = Colors.blue.shade700;
                      statusBgColor = Colors.blue.shade50;
                      statusText = 'DITERIMA';
                    }
                    if (order.status == 'completed') {
                      statusColor = Colors.green.shade700;
                      statusBgColor = Colors.green.shade50;
                      statusText = 'SELESAI';
                    }
                    if (order.status == 'cancelled') {
                      statusColor = Colors.red.shade700;
                      statusBgColor = Colors.red.shade50;
                      statusText = 'BATAL';
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.receipt_long, size: 20, color: Colors.blueGrey),
                                    const SizedBox(width: 8),
                                    Text('Order #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusBgColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: statusColor.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    statusText, 
                                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  child: const Icon(Icons.person, color: Colors.blueGrey),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Mitra Tukang:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      Text(order.tukang?.name ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Deskripsi Pesanan:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(order.description, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                            
                            if (order.totalPrice != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Pembayaran', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                                  Text('Rp ${order.totalPrice}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.green)),
                                ],
                              ),
                            ],

                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (order.status != 'cancelled' && order.status != 'completed')
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.green.shade600,
                                        side: BorderSide(color: Colors.green.shade600),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      icon: const Icon(Icons.chat, size: 18),
                                      label: const Text('Chat WA', style: TextStyle(fontWeight: FontWeight.bold)),
                                      onPressed: () => _openWhatsApp(order.tukang?.phoneNumber ?? ''),
                                    ),
                                  ),
                                if (order.status == 'pending') ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        backgroundColor: Colors.red.shade50,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () => _cancelOrder(order.id),
                                      child: const Text('Batalkan', style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                                if (order.status == 'completed' && order.review == null)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber.shade500,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      icon: const Icon(Icons.star),
                                      label: const Text('Beri Ulasan', style: TextStyle(fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => ReviewScreen(orderId: order.id, tukangName: order.tukang?.name ?? 'Tukang')),
                                        ).then((_) => _fetchOrders());
                                      },
                                    ),
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
