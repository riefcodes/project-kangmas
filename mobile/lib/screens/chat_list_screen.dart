import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  final Set<int> _hiddenUserIds = {}; // Local state to hide contacts until refresh

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/orders');
      if (res['success']) {
        final List data = res['data'];
        if (mounted) {
          setState(() {
            _orders = data.map((e) => OrderModel.fromJson(e)).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _launchWhatsApp(String phone, String name) async {
    String formattedPhone = phone;
    if (phone.startsWith('0')) {
      formattedPhone = '62${phone.substring(1)}';
    } else if (!phone.startsWith('62')) {
       // Basic fallback for other international formats if needed,
       // but here we assume Indonesia context
    }

    final String message = "Halo $name, saya dari Kangmas. Saya menghubungi terkait pekerjaan.";
    final Uri url = Uri.parse("https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak bisa membuka WhatsApp'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final myRole = auth.user?.role;

    // Grouping logic: Get unique contacts from relevant orders
    final Map<int, OrderModel> contactGroups = {};
    for (var order in _orders) {
      final contact = myRole == 'user' ? order.tukang : order.user;
      if (contact == null) continue;
      if (_hiddenUserIds.contains(contact.id)) continue;

      // Only include active or completed jobs
      if (['accepted', 'waiting_approval', 'completed'].contains(order.status)) {
        // We keep the latest order (assuming orders list is already sorted by latest)
        if (!contactGroups.containsKey(contact.id)) {
          contactGroups[contact.id] = order;
        }
      }
    }

    final contacts = contactGroups.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Pesan Aktif', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        color: Colors.amber,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : contacts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final order = contacts[index];
                      final contact = myRole == 'user' ? order.tukang! : order.user!;
                      return _buildContactCard(order, contact, myRole!);
                    },
                  ),
      ),
      bottomNavigationBar: _buildBottomNav(context, auth),
      floatingActionButton: _buildFAB(context, auth),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildEmptyState() {
    return ListView( // Use ListView to allow RefreshIndicator to work on empty state
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text("Belum ada percakapan aktif", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              const Text("Kontak muncul saat pekerjaan dimulai", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(OrderModel order, UserModel contact, String myRole) {
    bool isCompleted = order.status == 'completed';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: isCompleted ? Colors.grey[200] : Colors.amber.shade100,
              child: Icon(Icons.person, color: isCompleted ? Colors.grey : Colors.amber),
            ),
            title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.category, style: TextStyle(color: Colors.amber.shade800, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  isCompleted ? "Pekerjaan Selesai" : "Pekerjaan Sedang Berjalan",
                  style: TextStyle(fontSize: 11, color: isCompleted ? Colors.grey : Colors.blue),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.message, color: Colors.green),
              onPressed: () => _launchWhatsApp(contact.phoneNumber ?? '', contact.name),
            ),
          ),
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
              child: Row(
                children: [
                  if (myRole == 'user') ...[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/create_job', arguments: {
                            'category': order.category,
                            'tukang_id': contact.id,
                          });
                        },
                        child: const Text("Pesan Lagi", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        _showDeleteConfirmation(contact.id);
                      },
                      child: const Text("Hapus Kontak", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int contactId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Kontak?"),
        content: const Text("Kontak ini akan disembunyikan dari daftar pesan aktif."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              setState(() => _hiddenUserIds.add(contactId));
              Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
              icon: const Icon(Icons.receipt_long_rounded, color: Colors.grey),
              onPressed: () => Navigator.pushReplacementNamed(context, '/history'),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.chat_rounded, color: Colors.amber, size: 28),
              onPressed: () {}
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
