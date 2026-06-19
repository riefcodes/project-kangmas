import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class CreateOrderScreen extends StatefulWidget {
  final int tukangId;
  final String tukangName;
  final String category;

  const CreateOrderScreen({
    super.key,
    required this.tukangId,
    required this.tukangName,
    required this.category,
  });

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _addressCtl = TextEditingController();
  final _descCtl = TextEditingController();
  bool isSubmitting = false;

  File? _problemImage;
  final List<File> _locationImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProblemImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _problemImage = File(image.path);
      });
    }
  }

  Future<void> _pickLocationImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _locationImages.addAll(images.map((img) => File(img.path)));
      });
    }
  }

  Future<void> _submitOrder() async {
    if (_addressCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat pengerjaan harus diisi')));
      return;
    }
    if (_descCtl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deskripsi masalah harus diisi')));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final res = await ApiService.multipartPost(
        endpoint: '/orders',
        fields: {
          'tukang_id': widget.tukangId.toString(),
          'category': widget.category,
          'description': _descCtl.text.trim(),
          'address': _addressCtl.text.trim(),
        },
        singleFile: _problemImage,
        singleFileKey: 'image',
        multiFiles: _locationImages,
        multiFilesKey: 'location_images[]',
      );

      if (res['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibuat!'), backgroundColor: Colors.green));
          Navigator.pushNamedAndRemoveUntil(context, '/user_home', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat pesanan: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Buat Pesanan', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Tukang
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xFF0F172A),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.tukangName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(widget.category, style: const TextStyle(color: Colors.blueGrey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text('Detail Masalah & Lokasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            TextField(
              controller: _addressCtl,
              decoration: InputDecoration(
                labelText: 'Alamat Lengkap',
                prefixIcon: const Icon(Icons.location_on, color: Colors.redAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descCtl,
              decoration: InputDecoration(
                labelText: 'Deskripsi Masalah',
                hintText: 'Cth: Kran bocor atau tembok retak...',
                prefixIcon: const Icon(Icons.edit_note),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),

            // Upload Foto Masalah
            const Text("Foto Masalah (Wajib)", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickProblemImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _problemImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_problemImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.camera_alt, size: 40, color: Colors.amber),
                          Text("Ambil Foto Masalah", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Foto Lokasi Sekitar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Foto Kondisi Sekitar (Opsional)", style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _pickLocationImages,
                  icon: const Icon(Icons.add_a_photo, size: 18),
                  label: const Text("Tambah"),
                )
              ],
            ),
            if (_locationImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _locationImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_locationImages[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _locationImages.removeAt(index)),
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB800),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('KIRIM PESANAN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
