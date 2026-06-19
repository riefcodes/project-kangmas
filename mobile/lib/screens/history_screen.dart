import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _historyOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await ApiService.get('/orders');
      if (response['success']) {
        if (mounted) {
          setState(() {
            // Sort by ID descending (newest first)
            _historyOrders = (response['data'] as List).toList()
              ..sort((a, b) => b['id'].compareTo(a['id']));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        title: const Text(
          'Histori Transaksi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        color: Colors.amber,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : () {
                // Filter data berdasarkan role
                final displayOrders = auth.user?.role == 'tukang'
                    ? _historyOrders.where((o) => o['tukang_id'] == auth.user?.id).toList()
                    : _historyOrders;

                if (displayOrders.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: displayOrders.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(displayOrders[index]);
                  },
                );
              }(),
      ),
      bottomNavigationBar: _buildBottomNav(context, auth),
      floatingActionButton: _buildFAB(context, auth),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Belum ada riwayat pesanan", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic order) {
    String status = order['status'] ?? 'pending';
    Color statusColor = Colors.grey;
    String statusLabel = status.toUpperCase();

    if (status == 'completed') {
      statusColor = Colors.green;
      statusLabel = "SELESAI";
    } else if (status == 'cancelled') {
      statusColor = Colors.red;
      statusLabel = "DIBATALKAN";
    } else if (status == 'waiting_approval') {
      statusColor = Colors.orange;
      statusLabel = "MENUNGGU KONFIRMASI";
    } else if (status == 'accepted') {
      statusColor = Colors.blue;
      statusLabel = "DALAM PROSES";
    } else if (status == 'pending') {
      statusColor = Colors.amber;
      statusLabel = "MENUNGGU";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            if (status == 'completed' || status == 'waiting_approval') {
              Navigator.pushNamed(context, '/proof_view', arguments: order);
            } else {
              Navigator.pushNamed(context, '/job_detail', arguments: order);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIconForCategory(order['category']), color: statusColor),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['category'] ?? 'Layanan',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['description'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      statusLabel,
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(order['created_at']),
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'bangunan': return Icons.home_work_rounded;
      case 'perbaikan': return Icons.build_rounded;
      case 'pemasangan': return Icons.add_business_rounded;
      case 'bersih': return Icons.cleaning_services_rounded;
      case 'listrik': return Icons.electric_bolt_rounded;
      case 'pembantu': return Icons.person_search_rounded;
      case 'ac': return Icons.ac_unit_rounded;
      default: return Icons.miscellaneous_services_rounded;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "";
    }
  }

  Widget _buildFAB(BuildContext context, AuthProvider auth) {
    return FloatingActionButton(
      onPressed: () => Navigator.pushReplacementNamed(context, auth.user?.role == 'tukang' ? '/tukang_home' : '/user_home'),
      backgroundColor: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('asset/images/logo loading dan tombol tenggah.webp', fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AuthProvider auth) {
    return BottomAppBar(
      notchMargin: 10,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home_rounded, color: Colors.grey),
              onPressed: () => Navigator.pushReplacementNamed(context, auth.user?.role == 'tukang' ? '/tukang_home' : '/user_home'),
            ),
            IconButton(
              icon: const Icon(Icons.receipt_long_rounded, color: Colors.amber, size: 28),
              onPressed: () {}
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.chat_rounded, color: Colors.grey),
              onPressed: () => Navigator.pushReplacementNamed(context, '/chat_list'),
            ),
            IconButton(
              icon: const Icon(Icons.person_rounded, color: Colors.grey),
              onPressed: () => Navigator.pushReplacementNamed(context, '/profile'),
            ),
          ],
        ),
      ),
    );
  }
}
