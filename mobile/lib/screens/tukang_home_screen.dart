import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class TukangHomeScreen extends StatefulWidget {
  const TukangHomeScreen({super.key});

  @override
  State<TukangHomeScreen> createState() => _TukangHomeScreenState();
}

class _TukangHomeScreenState extends State<TukangHomeScreen> {
  List<dynamic> _availableJobs = [];
  List<dynamic> _myActiveJobs = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _fetchJobs();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchJobs() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await ApiService.get('/orders');
      if (response['success']) {
        final allOrders = response['data'] as List;
        if (mounted) {
          setState(() {
            // Pekerjaan yang tersedia untuk diambil (status pending & belum ada tukang)
            _availableJobs = allOrders
                .where((o) => o['status'] == 'pending' && o['tukang_id'] == null)
                .toList();

            // Pekerjaan yang sedang saya kerjakan (status accepted & tukang_id adalah saya)
            _myActiveJobs = allOrders
                .where((o) => o['status'] == 'accepted' && o['tukang_id'] == auth.user?.id)
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
        onRefresh: _fetchJobs,
        color: Colors.amber,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 40),
                decoration: const BoxDecoration(
                  color: Colors.amber,
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
                      'Selamat Datang,\n${auth.user?.name ?? 'Tukang'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Kelola pekerjaanmu dengan mudah',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ),

            // SEKSI 1: PEKERJAAN SAYA (AKTIF)
            if (_myActiveJobs.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Pekerjaan Sedang Berjalan",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 5),
                      Text("Selesaikan pekerjaan ini tepat waktu", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildActiveJobCard(_myActiveJobs[index]),
                    childCount: _myActiveJobs.length,
                  ),
                ),
              ),
            ],

            // SEKSI 2: PEKERJAAN TERSEDIA
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Pekerjaan Tersedia (${_availableJobs.length})",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                    const Icon(Icons.sync, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Colors.amber)),
              )
            else if (_availableJobs.isEmpty && _myActiveJobs.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      const Text("Belum ada pekerjaan baru", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildJobCard(context, _availableJobs[index]),
                    childCount: _availableJobs.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, auth),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchJobs,
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

  // Card untuk pekerjaan yang SEDANG DIAMBIL
  Widget _buildActiveJobCard(dynamic job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.engineering_rounded, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(job['category'] ?? 'Pekerjaan',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                child: const Text("AKTIF", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(job['address'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.black87)),
          const Divider(height: 25),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/job_detail', arguments: job),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.blue)),
                  child: const Text("Detail"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/job_closing', arguments: job),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text("Selesaikan"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Card untuk pekerjaan BARU (tersedia)
  Widget _buildJobCard(BuildContext context, dynamic job) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/job_detail', arguments: job),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.handyman_rounded, color: Colors.amber, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job['category'] ?? 'Lainnya', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(job['address'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tawaran Biaya:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("Rp ${job['total_price'] ?? 0}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
              ],
            ),
          ],
        ),
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
            IconButton(icon: const Icon(Icons.home_rounded, color: Colors.amber, size: 28), onPressed: () {}),
            IconButton(icon: const Icon(Icons.receipt_long_rounded, color: Colors.grey), onPressed: () => Navigator.pushReplacementNamed(context, '/history')),
            const SizedBox(width: 40),
            IconButton(icon: const Icon(Icons.chat_rounded, color: Colors.grey), onPressed: () => Navigator.pushReplacementNamed(context, '/chat_list')),
            IconButton(icon: const Icon(Icons.person_rounded, color: Colors.grey), onPressed: () => Navigator.pushReplacementNamed(context, '/profile')),
          ],
        ),
      ),
    );
  }
}
