import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProofApprovalScreen extends StatefulWidget {
  const ProofApprovalScreen({super.key});

  @override
  State<ProofApprovalScreen> createState() => _ProofApprovalScreenState();
}

class _ProofApprovalScreenState extends State<ProofApprovalScreen> {
  bool _isSubmitting = false;

  Future<void> _approveJob(int orderId) async {
    setState(() => _isSubmitting = true);
    try {
      final response = await ApiService.post('/orders/$orderId/approve', {
        'status': 'completed',
      });

      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pekerjaan berhasil disetujui!"), backgroundColor: Colors.green),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/user_home', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyetujui: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String? proofImage = order['proof_image'];
    final List<dynamic> locationImages = order['location_images'] ?? [];
    final tukang = order['tukang'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Konfirmasi Hasil Kerja', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.amber[50],
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Silakan periksa hasil pekerjaan ${tukang['name'] ?? 'Tukang'}. Jika sudah sesuai, klik Selesaikan.",
                      style: TextStyle(color: Colors.amber[900], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Foto Bukti Selesai", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: proofImage != null
                        ? Image.network(
                            '${ApiService.storageUrl}/$proofImage',
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(text: "Tidak ada foto bukti utama"),
                  ),

                  const SizedBox(height: 30),

                  if (locationImages.isNotEmpty) ...[
                    const Text("Foto Kondisi Lokasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: locationImages.length,
                        itemBuilder: (context, index) {
                          final img = locationImages[index];
                          final String imgPath = img is Map ? (img['image_path'] ?? img['path'] ?? '') : img.toString();
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                '${ApiService.storageUrl}/$imgPath',
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(width: 120),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  const Text("Detail Pekerjaan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildDetailItem(Icons.category_rounded, "Kategori", order['category'] ?? '-'),
                  _buildDetailItem(Icons.payments_rounded, "Total Biaya", "Rp ${order['total_price'] ?? 0}"),

                  const SizedBox(height: 40),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Komplain", style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : () => _approveJob(order['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: _isSubmitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Selesaikan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({double width = double.infinity, double height = 150, String text = "Gagal memuat"}) {
    return Container(
      width: width, height: height,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.grey))),
    );
  }
}
