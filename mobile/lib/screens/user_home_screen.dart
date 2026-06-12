import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  List<dynamic> _activeOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActiveOrders();
  }

  Future<void> _fetchActiveOrders() async {
    try {
      final response = await ApiService.get('/orders');
      if (response['success']) {
        if (mounted) {
          setState(() {
            _activeOrders = (response['data'] as List)
                .where((o) => o['status'] == 'pending' || o['status'] == 'accepted')
                .toList();
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
      body: RefreshIndicator(
        onRefresh: _fetchActiveOrders,
        color: Colors.amber,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 40),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFC107),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.notes_rounded, color: Colors.white, size: 30),
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: Icon(Icons.person, color: Colors.amber),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    Text(
                      'Halo,\n${auth.user?.name ?? 'User'}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 10),
                    const Text('Butuh bantuan apa hari ini?',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),

              // SEKSI PESANAN AKTIF (Notifikasi)
              if (_activeOrders.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Pesanan Aktif",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                      const SizedBox(height: 15),
                      ..._activeOrders.map((order) => _buildActiveOrderCard(order)).toList(),
                    ],
                  ),
                ),

              // Bagian Kategori
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Layanan Kami",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.7,
                      children: [
                        _buildCategory('Bangunan', Icons.home_repair_service_rounded),
                        _buildCategory('Listrik', Icons.electric_bolt_rounded),
                        _buildCategory('Pipa', Icons.plumbing_rounded),
                        _buildCategory('Cat', Icons.format_paint_rounded),
                        _buildCategory('AC', Icons.ac_unit_rounded),
                        _buildCategory('Kebun', Icons.local_florist_rounded),
                        _buildCategory('Bersih', Icons.cleaning_services_rounded),
                        _buildCategory('Lainnya', Icons.grid_view_rounded),
                      ],
                    ),
                  ],
                ),
              ),

              // Info Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Colors.blue, size: 40),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Tukang Terverifikasi", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("Semua tukang kami telah melewati seleksi ketat.",
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(auth),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0F172A),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildActiveOrderCard(dynamic order) {
    bool isAccepted = order['status'] == 'accepted';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isAccepted ? const Color(0xFFE3F2FD) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isAccepted ? Colors.blue.shade100 : Colors.amber.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isAccepted ? Colors.blue : Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: Icon(isAccepted ? Icons.engineering : Icons.hourglass_empty,
                     color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAccepted ? "Tukang Menuju Lokasi!" : "Menunggu Verifikasi...",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text("Kategori: ${order['category']}", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ),
            ],
          ),
          if (isAccepted) ...[
            const Divider(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/live_tracking', arguments: order),
                icon: const Icon(Icons.map_outlined),
                label: const Text("Lacak Lokasi Tukang"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/create_job', arguments: {'category': title}),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: const Color(0xFFFFC107), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(AuthProvider auth) {
    return BottomAppBar(
      notchMargin: 10,
      shape: const CircularNotchedRectangle(),
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home_rounded, color: Colors.amber, size: 28), onPressed: () {}),
            IconButton(icon: const Icon(Icons.receipt_long_rounded, color: Colors.grey), onPressed: () => Navigator.pushNamed(context, '/history')),
            const SizedBox(width: 40),
            IconButton(icon: const Icon(Icons.chat_rounded, color: Colors.grey), onPressed: () => Navigator.pushNamed(context, '/chat_list')),
            IconButton(icon: const Icon(Icons.person_rounded, color: Colors.grey), onPressed: () => Navigator.pushNamed(context, '/profile')),
          ],
        ),
      ),
    );
  }
}
