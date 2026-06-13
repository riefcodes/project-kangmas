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
                .where((o) => o['status'] == 'pending' ||
                              o['status'] == 'accepted' ||
                              o['status'] == 'waiting_approval')
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

  Future<void> _cancelOrder(int orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Batalkan Pesanan?"),
        content: const Text("Apakah Anda yakin ingin membatalkan pesanan ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Tidak")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await ApiService.post('/orders/$orderId/cancel', {});
        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pesanan berhasil dibatalkan")));
          _fetchActiveOrders();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal membatalkan: $e")));
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

              // 1. BAGIAN KATEGORI (Sekarang di Atas)
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
                        _buildCategory('Bangunan', 'asset/images/logo pekerja bangunan.webp'),
                        _buildCategory('Perbaikan', 'asset/images/logo pekerjaan perbaikan.webp'),
                        _buildCategory('Pemasangan', 'asset/images/logo pemasangan.webp'),
                        _buildCategory('Bersih', 'asset/images/logo pembersihan.webp'),
                        _buildCategory('Listrik', 'asset/images/logo pekerjaan Pemeliharaan & listrik.webp'),
                        _buildCategory('Pembantu', 'asset/images/logo  pekerjaan pembantu.webp'),
                        _buildCategory('AC', Icons.ac_unit_rounded),
                        _buildCategory('Lainnya', Icons.grid_view_rounded),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. SEKSI PESANAN AKTIF (Di bawah Kategori)
              if (_activeOrders.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
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

              // Info Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
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
        backgroundColor: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('asset/images/logo loading dan tombol tenggah.webp', fit: BoxFit.contain),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildActiveOrderCard(dynamic order) {
    String status = order['status'] ?? 'pending';
    bool isAccepted = status == 'accepted';
    bool isWaitingApproval = status == 'waiting_approval';

    Color cardColor = const Color(0xFFFFF8E1); // Pending
    Color accentColor = Colors.amber;
    String titleText = "Menunggu Tukang...";

    if (isAccepted) {
      cardColor = const Color(0xFFE3F2FD);
      accentColor = Colors.blue;
      titleText = "Tukang Menuju Lokasi!";
    } else if (isWaitingApproval) {
      cardColor = const Color(0xFFE8F5E9);
      accentColor = Colors.green;
      titleText = "Pekerjaan Telah Selesai!";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isWaitingApproval ? Icons.verified : (isAccepted ? Icons.engineering : Icons.hourglass_empty),
                  color: Colors.white,
                  size: 24
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text("Kategori: ${order['category']}", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ),
              if (status == 'pending')
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: () => _cancelOrder(order['id']),
                  tooltip: "Batalkan Pesanan",
                )
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
          ],
          if (isWaitingApproval) ...[
            const Divider(height: 25),
            const Text(
              "Tukang sudah menyelesaikan pekerjaannya. Silakan periksa hasil dan konfirmasi.",
              style: TextStyle(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/proof_approval', arguments: order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Periksa & Selesaikan Pesanan"),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildCategory(String title, dynamic iconSource) {
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
            child: Center(
              child: iconSource is IconData
                  ? Icon(iconSource, color: const Color(0xFFFFC107), size: 28)
                  : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(iconSource, fit: BoxFit.contain),
                    ),
            ),
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
            IconButton(
              icon: const Icon(Icons.home_rounded, color: Colors.amber, size: 28),
              onPressed: () {}
            ),
            IconButton(
              icon: const Icon(Icons.receipt_long_rounded, color: Colors.grey),
              onPressed: () => Navigator.pushReplacementNamed(context, '/history')
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.chat_rounded, color: Colors.grey),
              onPressed: () => Navigator.pushReplacementNamed(context, '/chat_list')
            ),
            IconButton(
              icon: const Icon(Icons.person_rounded, color: Colors.grey),
              onPressed: () => Navigator.pushReplacementNamed(context, '/profile')
            ),
          ],
        ),
      ),
    );
  }
}
