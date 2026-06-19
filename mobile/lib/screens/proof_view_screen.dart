import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProofViewScreen extends StatelessWidget {
  const ProofViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Normalize arguments since they might come from different screens
    final String? proofImage = args['proof_image'];
    final List<dynamic> locationImages = args['location_images'] ?? [];
    final Map<String, dynamic> tukang = args['tukang'] is Map ? args['tukang'] : {'name': 'Tukang Kangmas'};
    final String category = args['category'] ?? '-';
    final String description = args['description'] ?? '-';
    final dynamic totalPrice = args['total_price'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Bukti Pengerjaan', style: TextStyle(fontWeight: FontWeight.bold)),
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
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
              color: Colors.green[50],
              child: Column(
                children: [
                  const Icon(Icons.verified_rounded, color: Colors.green, size: 60),
                  const SizedBox(height: 10),
                  const Text(
                    "Pekerjaan Selesai",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  Text(
                    "Dikerjakan oleh ${tukang['name'] ?? 'Tukang Kangmas'}",
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Hasil Pekerjaan Utama", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          final String imgPath = img is Map ? (img['path'] ?? '') : img.toString();
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
                  _buildDetailItem(Icons.category_rounded, "Kategori", category),
                  _buildDetailItem(Icons.description_rounded, "Deskripsi", description),
                  _buildDetailItem(Icons.payments_rounded, "Biaya Dibayarkan", "Rp ${totalPrice ?? 0}"),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text(
                        "Tutup",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
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
