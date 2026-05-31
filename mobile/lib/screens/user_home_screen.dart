import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import 'tukang_detail_screen.dart';
import 'user_orders_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final List<String> categories = ['listrik', 'air', 'bangunan'];
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
      // Mock latitude and longitude for Telkom University
      final lat = -6.9730;
      final lng = 107.6307;

      final res = await ApiService.get(
          '/recommend?latitude=$lat&longitude=$lng&category=$selectedCategory');

      if (res['success']) {
        setState(() {
          recommendations = res['data'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KANGMAS - Cari Tukang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserOrdersScreen()));
            },
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
          // Category Selector
          Container(
            height: 60,
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: categories.map((cat) {
                final isSelected = cat == selectedCategory;
                return ChoiceChip(
                  label: Text(cat.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => selectedCategory = cat);
                      _fetchRecommendations();
                    }
                  },
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : recommendations.isEmpty
                    ? const Center(child: Text('Tidak ada tukang ditemukan di sekitar Anda.'))
                    : ListView.builder(
                        itemCount: recommendations.length,
                        itemBuilder: (context, index) {
                          final tukang = recommendations[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(tukang['name'][0]),
                              ),
                              title: Text(tukang['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('⭐ ${tukang['avg_rating']} (${tukang['total_reviews']} ulasan)'),
                                  Text('📍 Jarak: ${tukang['distance_km']} km'),
                                  Text('Base Price: Rp ${tukang['base_price']}'),
                                ],
                              ),
                              isThreeLine: true,
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => TukangDetailScreen(tukangId: tukang['user_id'])),
                                  );
                                },
                                child: const Text('Detail'),
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
