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
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
    // Refresh otomatis setiap 2 menit
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
    try {
      final response = await ApiService.get('/orders');
      if (response['success']) {
        if (mounted) {
          setState(() {
            // Tampilkan pesanan yang masih 'pending' dan belum ada tukangnya
            _availableJobs = (response['data'] as List)
                .where((o) => o['status'] == 'pending' && o['tukang_id'] == null)
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
                    const Text('Cari pekerjaan yang cocok untukmu hari ini',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Pekerjaan Terbaru (${_availableJobs.length})",
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
            else if (_availableJobs.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      const Text("Belum ada pekerjaan tersedia", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final job = _availableJobs[index];
                      return _buildJobCard(context, job);
                    },
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
        backgroundColor: const Color(0xFF0F172A),
        child: const Icon(Icons.refresh_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildJobCard(BuildContext context, dynamic job) {
    IconData iconData;
    switch (job['category']?.toString().toLowerCase()) {
      case 'listrik': iconData = Icons.electric_bolt_rounded; break;
      case 'pipa': iconData = Icons.plumbing_rounded; break;
      case 'bangunan': iconData = Icons.home_repair_service_rounded; break;
      case 'ac': iconData = Icons.ac_unit_rounded; break;
      default: iconData = Icons.handyman_rounded;
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/job_detail', arguments: job),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: Colors.amber[800], size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job['category'] ?? 'Lainnya',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                      Text(job['address'] ?? 'Lokasi tidak spesifik',
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Text(job['description'] ?? '-',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tawaran Biaya:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("Rp ${job['total_price'] ?? 0}",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.green)),
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
