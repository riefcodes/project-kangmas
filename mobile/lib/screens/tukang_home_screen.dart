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
        final List data = res['data'];
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Dashboard Mitra', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          Row(
            children: [
              Text(isActive ? 'Online' : 'Offline', style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.greenAccent : Colors.white70)),
              Switch(
                value: isActive,
                onChanged: (val) => _toggleActive(),
                activeColor: Colors.greenAccent,
                inactiveThumbColor: Colors.grey.shade400,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: Theme.of(context).colorScheme.primary,
            width: double.infinity,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: const Icon(Icons.engineering, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.user?.name ?? 'Mitra Tukang', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(4)),
                            child: Text(auth.user?.tukangProfile?.category.toUpperCase() ?? 'KATEGORI', style: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          Text(' ${auth.user?.tukangProfile?.avgRating ?? 0}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.work_history, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text('Daftar Pekerjaan Masuk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            const Text('Belum ada pesanan masuk hari ini.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          
                          Color statusColor = Colors.grey;
                          Color statusBgColor = Colors.grey.shade100;
                          String statusText = 'MENUNGGU';

                          if (order.status == 'pending') {
                            statusColor = Colors.orange.shade700;
                            statusBgColor = Colors.orange.shade50;
                            statusText = 'ORDER BARU';
                          }
                          if (order.status == 'accepted') {
                            statusColor = Colors.blue.shade700;
                            statusBgColor = Colors.blue.shade50;
                            statusText = 'DIPROSES';
                          }
                          if (order.status == 'completed') {
                            statusColor = Colors.green.shade700;
                            statusBgColor = Colors.green.shade50;
                            statusText = 'SELESAI';
                          }
                          if (order.status == 'cancelled') {
                            statusColor = Colors.red.shade700;
                            statusBgColor = Colors.red.shade50;
                            statusText = 'DIBATALKAN';
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                                          const Icon(Icons.receipt, size: 20, color: Colors.blueGrey),
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
                                        backgroundColor: Colors.blue.shade50,
                                        child: const Icon(Icons.person, color: Colors.blue),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Pelanggan:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            Text(order.user?.name ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                                        const Text('Detail Pekerjaan:', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text(order.description, style: const TextStyle(fontSize: 14, height: 1.4)),
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
                                    children: [
                                      if (order.status == 'pending' || order.status == 'accepted')
                                        Expanded(
                                          flex: 1,
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.green.shade600,
                                              side: BorderSide(color: Colors.green.shade600),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            icon: const Icon(Icons.chat, size: 18),
                                            label: const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                                            onPressed: () => _openWhatsApp(order.user?.phoneNumber ?? ''),
                                          ),
                                        ),
                                      if (order.status == 'pending') ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context).colorScheme.primary,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () => _updateOrderStatus(order.id, 'accepted'),
                                            child: const Text('Terima Order', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                      if (order.status == 'accepted') ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 2,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: () => _showCompleteDialog(order.id),
                                            child: const Text('Selesaikan', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
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
