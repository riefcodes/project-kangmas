import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'tukang_detail_screen.dart';
import 'user_orders_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final List<Map<String, String>> categories = [
    {'value': 'listrik', 'label': 'LISTRIK & KABEL'},
    {'value': 'air', 'label': 'SERVICE AC & AIR'},
    {'value': 'bangunan', 'label': 'PEMBANGUNAN'},
  ];
  String selectedCategory = 'listrik';
  List<dynamic> recommendations = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRecommendations();
  }

  Future<void> _fetchRecommendations() async {
    setState(() => isLoading = true);
    try {
      double lat = -6.9730;
      double lng = 107.6307;

      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          lat = position.latitude;
          lng = position.longitude;
        }
      } catch (_) {
        // Ignored, use fallback
      }

      final res = await ApiService.get(
          '/recommend?latitude=$lat&longitude=$lng&category=$selectedCategory');

      if (res['success']) {
        setState(() {
          recommendations = res['data'];
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _fetchRecommendations,
        color: Colors.amber,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header (Exactly like Tukang Home)
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
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 20,
                            child: Icon(Icons.person, color: Colors.amber),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    Text(
                      'Selamat Datang,\n${auth.user?.name ?? 'Pengguna'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text('Temukan tukang ahli untuk rumah Anda',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ),

            // Category Selector (Tabs style)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Kategori Layanan",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 45,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = cat['value'] == selectedCategory;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InkWell(
                              onTap: () {
                                setState(() => selectedCategory = cat['value']!);
                                _fetchRecommendations();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.amber : Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: isSelected ? Colors.amber : Colors.grey.shade300),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  cat['label']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recommendations Title
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tukang Tersedia (${recommendations.length})",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                    const Icon(Icons.sync, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),

            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Colors.amber)),
              )
            else if (recommendations.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      const Text("Belum ada tukang di kategori ini", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTukangCard(recommendations[index]),
                    childCount: recommendations.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, auth),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchRecommendations,
        backgroundColor: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('asset/images/logo loading dan tombol tenggah.webp', fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.handyman_rounded, color: Colors.amber),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTukangCard(dynamic tukang) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TukangDetailScreen(tukangId: tukang['user_id'])),
        );
      },
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
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: Colors.amber, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tukang['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          Text(' ${tukang['avg_rating']} ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('(${tukang['total_reviews']} ulasan)', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                        ],
                      ),
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
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: Colors.grey[400], size: 14),
                    const SizedBox(width: 4),
                    Text('${tukang['distance_km']} km dari lokasi Anda', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  ],
                ),
                Text("Rp ${tukang['base_price']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
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
            IconButton(icon: const Icon(Icons.receipt_long_rounded, color: Colors.grey),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserOrdersScreen()))
            ),
            const SizedBox(width: 40),
            IconButton(icon: const Icon(Icons.chat_rounded, color: Colors.grey), onPressed: () => Navigator.pushReplacementNamed(context, '/chat_list')),
            IconButton(icon: const Icon(Icons.person_rounded, color: Colors.grey), onPressed: () => Navigator.pushReplacementNamed(context, '/profile')),
          ],
        ),
      ),
    );
  }
}
