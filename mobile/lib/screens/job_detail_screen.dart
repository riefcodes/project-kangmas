import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isSubmitting = false;
  Map<String, dynamic>? _currentJob;
  bool _isLoadingDetail = true;
  String _errorMessage = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentJob == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        // Langsung tampilkan data dari argumen agar tidak stuck loading
        setState(() {
          _currentJob = Map<String, dynamic>.from(args);
          _isLoadingDetail = false;
        });

        final jobId = args['id'];
        if (jobId != null) {
          _fetchJobDetail(int.parse(jobId.toString()));
        }
      } else {
        setState(() {
          _isLoadingDetail = false;
          _errorMessage = "Data pesanan tidak ditemukan";
        });
      }
    }
  }

  Future<void> _fetchJobDetail(int id) async {
    try {
      final response = await ApiService.get('/orders/$id');
      if (response['success'] && mounted) {
        setState(() {
          _currentJob = response['data'];
          _isLoadingDetail = false;
        });
      }
    } catch (e) {
      debugPrint("Error refreshing job detail: $e");
      // Jika _currentJob masih null (tidak ada data dari argumen), baru tampilkan error
      if (_currentJob == null && mounted) {
        String msg = e.toString();
        if (msg.contains("403") || msg.contains("Unauthorized")) {
          msg = "Sesi habis atau akses ditolak. Silakan coba Logout dan Login kembali.";
        }
        setState(() {
          _isLoadingDetail = false;
          _errorMessage = msg;
        });
      }
    }
  }

  Future<void> _acceptJob(dynamic job) async {
    setState(() => _isSubmitting = true);
    try {
      final response = await ApiService.post('/orders/${job['id']}/accept', {
        'status': 'accepted',
      });

      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pekerjaan berhasil diambil!"), backgroundColor: Colors.green),
          );
          Navigator.pushReplacementNamed(context, '/tukang_home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengambil pekerjaan: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDetail) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    if (_currentJob == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.amber),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage.isEmpty ? "Gagal memuat detail pekerjaan" : _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Kembali"),
              )
            ],
          ),
        ),
      );
    }

    final job = _currentJob!;
    final auth = Provider.of<AuthProvider>(context);
    final bool isTukang = auth.user?.role == 'tukang';
    final bool isPending = job['status'] == 'pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Colors.amber,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                job['category'] ?? 'Detail Pekerjaan',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              centerTitle: true,
              background: Container(
                color: Colors.amber,
                child: Center(
                  child: Icon(Icons.handyman_rounded, size: 70, color: Colors.white.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          job['category'] ?? "Pekerjaan",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(job['status']?.toString().toUpperCase() ?? "PENDING",
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildQuickInfo(Icons.payments_rounded, "Rp ${job['total_price'] ?? 0}", "Tawaran Biaya"),
                      const SizedBox(width: 15),
                      _buildQuickInfo(Icons.calendar_month_rounded, job['job_date'] ?? '-', "Jadwal"),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text("Deskripsi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    job['description'] ?? "Tidak ada deskripsi.",
                    style: const TextStyle(color: Color(0xFF64748B), height: 1.6),
                  ),

                  // --- FOTO MASALAH ---
                  if (job['image_path'] != null) ...[
                    const SizedBox(height: 30),
                    const Text("Foto Masalah", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        '${ApiService.storageUrl}/${job['image_path']}',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildImageError(),
                      ),
                    ),
                  ],

                  // --- FOTO LOKASI SEKITAR ---
                  if (job['location_images'] != null && (job['location_images'] as List).isNotEmpty) ...[
                    const SizedBox(height: 30),
                    const Text("Foto Lokasi Sekitar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (job['location_images'] as List).length,
                        itemBuilder: (context, index) {
                          final img = job['location_images'][index];
                          final String imgPath = img is Map ? (img['image_path'] ?? img['path'] ?? '') : img.toString();

                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                '${ApiService.storageUrl}/$imgPath',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildImageError(width: 120),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // --- BUKTI PEKERJAAN SELESAI (Jika Ada) ---
                  if (job['proof_image'] != null) ...[
                    const SizedBox(height: 30),
                    const Text("Bukti Hasil Pekerjaan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        '${ApiService.storageUrl}/${job['proof_image']}',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildImageError(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                  const Text("Lokasi Pekerjaan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(job['address'] ?? "Alamat tidak tersedia",
                            style: const TextStyle(fontSize: 14, color: Color(0xFF334155))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (job['job_time'] != null) ...[
                    const Text("Waktu Kunjungan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, color: Colors.amber),
                        const SizedBox(width: 10),
                        Text(job['job_time'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: isTukang && isPending ? Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : () => _acceptJob(job),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: _isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Ambil Pekerjaan Sekarang",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ) : null,
    );
  }

  Widget _buildQuickInfo(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.amber, size: 24),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError({double width = double.infinity, double height = 200}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
    );
  }
}
