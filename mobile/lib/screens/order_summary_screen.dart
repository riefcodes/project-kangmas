import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  bool _isSubmitting = false;
  final TextEditingController _addressController = TextEditingController(text: 'Jl. Sukabirus No. 187, Bojongsoang');

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _createOrder(Map<String, dynamic> args) async {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat harus diisi'), backgroundColor: Colors.red),
      );
      return;
    }

    // Konversi tanggal dari dd/MM/yy ke yyyy-MM-dd agar diterima database
    String formattedDate = '';
    try {
      if (args['job_date'] != null && args['job_date'].toString().isNotEmpty) {
        DateTime parsedDate = DateFormat('dd/MM/yy').parse(args['job_date']);
        formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      }
    } catch (e) {
      formattedDate = args['job_date'] ?? '';
    }

    setState(() => _isSubmitting = true);
    try {
      final Map<String, String> fields = {
        'category': args['category']?.toString() ?? '',
        'description': args['description']?.toString() ?? '',
        'price': args['price']?.toString() ?? '0',
        'job_date': formattedDate, // Gunakan tanggal yang sudah diformat
        'job_time': args['job_time']?.toString() ?? '',
        'address': _addressController.text.trim(),
        'status': 'pending',
      };

      if (args['tukang_id'] != null) {
        fields['tukang_id'] = args['tukang_id'].toString();
      }

      final response = await ApiService.multipartPost(
        endpoint: '/orders',
        fields: fields,
        singleFile: args['problem_image'] as XFile?,
        singleFileKey: 'image',
        multiFiles: args['location_images'] as List<XFile>?,
        multiFilesKey: 'location_images[]',
      );

      if (response['success']) {
        if (mounted) {
          Navigator.pushNamed(context, '/user_job_success');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat pesanan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final XFile? problemImage = args['problem_image'] as XFile?;
    final List<XFile>? locationImages = args['location_images'] as List<XFile>?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ringkasan Pesanan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Address Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alamat Pengerjaan:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Tuliskan alamat lengkap lokasi pengerjaan...',
                      prefixIcon: const Icon(Icons.location_on, color: Colors.redAccent),
                      filled: true,
                      fillColor: const Color(0xFFF1F4F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori: ${args['category']}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                  const SizedBox(height: 15),

                  // Problem Image Preview
                  if (problemImage != null) ...[
                    const Text('Foto Masalah:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: kIsWeb
                            ? NetworkImage(problemImage.path)
                            : FileImage(File(problemImage.path)) as ImageProvider,
                          fit: BoxFit.cover
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Jadwal Section
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                            Text(args['job_date'] ?? '-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Waktu:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                            Text(args['job_time'] ?? '-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text('Deskripsi Pekerjaan:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(args['description'] ?? '-', style: const TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(height: 20),

                  // Location Images Preview
                  if (locationImages != null && locationImages.isNotEmpty) ...[
                    const Text('Foto Lokasi Sekitar:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: locationImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: kIsWeb
                                  ? NetworkImage(locationImages[index].path)
                                  : FileImage(File(locationImages[index].path)) as ImageProvider,
                                fit: BoxFit.cover
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tawaran Harga:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Rp ${args['price']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text('Metode Pembayaran:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.payments_outlined, color: Colors.green),
                    title: Text('Tunai (Bayar di Tempat)'),
                    trailing: Icon(Icons.check_circle, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : () => _createOrder(args),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Pesan Sekarang', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
