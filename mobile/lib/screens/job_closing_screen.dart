import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class JobClosingScreen extends StatefulWidget {
  const JobClosingScreen({super.key});

  @override
  State<JobClosingScreen> createState() => _JobClosingScreenState();
}

class _JobClosingScreenState extends State<JobClosingScreen> {
  bool _isLoading = false;
  File? _arrivalImage;
  File? _proofImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickArrivalImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _arrivalImage = File(image.path);
      });
    }
  }

  Future<void> _pickProofImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _proofImage = File(image.path);
      });
    }
  }

  Future<void> _submitForApproval(dynamic job) async {
    if (_arrivalImage == null || _proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi foto lokasi dan foto hasil pekerjaan"), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Kita kirim foto lokasi (saat tiba) dan foto bukti (selesai)
      // Status diubah menjadi 'waiting_approval' agar user bisa approve
      final response = await ApiService.multipartPost(
        endpoint: '/orders/${job['id']}/complete',
        fields: {
          'status': 'waiting_approval',
        },
        singleFile: _proofImage,
        singleFileKey: 'proof_image',
        multiFiles: [_arrivalImage!],
        multiFilesKey: 'location_images[]',
      );

      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Bukti berhasil dikirim! Menunggu persetujuan pelanggan."), backgroundColor: Colors.green),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/tukang_home', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim bukti: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Selesaikan Pekerjaan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F172A),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Alur Penyelesaian", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Ikuti langkah di bawah ini untuk menyelesaikan pesanan.", style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),

            // LANGKAH 1: FOTO LOKASI (TIBA)
            _buildStepHeader("1", "Foto Tiba di Lokasi", _arrivalImage != null),
            const SizedBox(height: 10),
            _buildImagePickerBox(
              image: _arrivalImage,
              onTap: _pickArrivalImage,
              placeholder: "Ambil Foto Saat Tiba",
            ),

            const SizedBox(height: 30),

            // LANGKAH 2: FOTO BUKTI (SELESAI)
            Opacity(
              opacity: _arrivalImage != null ? 1.0 : 0.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepHeader("2", "Foto Bukti Hasil Pekerjaan", _proofImage != null),
                  const SizedBox(height: 10),
                  _buildImagePickerBox(
                    image: _proofImage,
                    onTap: _arrivalImage != null ? _pickProofImage : null,
                    placeholder: "Ambil Foto Hasil Kerja",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: (_isLoading || _arrivalImage == null || _proofImage == null)
                    ? null
                    : () => _submitForApproval(job),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB800),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'KIRIM UNTUK PERSETUJUAN',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader(String step, String title, bool isDone) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone ? Colors.green : Colors.amber,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : Text(step, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildImagePickerBox({File? image, VoidCallback? onTap, required String placeholder}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.file(image, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_enhance_rounded, size: 45, color: Colors.amber),
                  const SizedBox(height: 8),
                  Text(placeholder, style: const TextStyle(color: Colors.grey)),
                ],
              ),
      ),
    );
  }
}
