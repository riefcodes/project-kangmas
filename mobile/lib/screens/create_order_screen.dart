import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class CreateOrderScreen extends StatefulWidget {
  final int tukangId;
  final String tukangName;
  final String category;
  final String basePrice;

  const CreateOrderScreen({
    super.key,
    required this.tukangId,
    required this.tukangName,
    required this.category,
    required this.basePrice,
  });

  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _addressCtl = TextEditingController();
  final _descCtl = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _priceCtl = TextEditingController();
  bool isSubmitting = false;

  XFile? _problemImage;
  final List<XFile> _locationImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yy').format(DateTime.now());
    _timeController.text = "08:00 - 17:00";
    _priceCtl.text = widget.basePrice;
  }

  Future<void> _pickProblemImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _problemImage = image;
      });
    }
  }

  Future<void> _pickLocationImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _locationImages.addAll(images);
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

    // Format date for database (yyyy-MM-dd)
    String formattedDate = '';
    try {
      DateTime parsedDate = DateFormat('dd/MM/yy').parse(_dateController.text);
      formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      formattedDate = _dateController.text;
    }

    try {
      final res = await ApiService.multipartPost(
        endpoint: '/orders',
        fields: {
          'tukang_id': widget.tukangId.toString(),
          'category': widget.category,
          'description': _descCtl.text.trim(),
          'address': _addressCtl.text.trim(),
          'job_date': formattedDate,
          'job_time': _timeController.text.trim(),
          'price': _priceCtl.text.trim(),
          'status': 'pending',
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
            const SizedBox(height: 20),

            // Jadwal Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tanggal Kerja', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2101),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Colors.amber,
                                    onPrimary: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _dateController.text = DateFormat('dd/MM/yy').format(pickedDate);
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'dd/mm/yy',
                          prefixIcon: const Icon(Icons.calendar_today, size: 18, color: Colors.amber),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estimasi Jam', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          hintText: 'Jam - Jam',
                          prefixIcon: const Icon(Icons.access_time, size: 18, color: Colors.amber),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text('Tawaran Harga', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _priceCtl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Rp ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
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
                        child: kIsWeb
                          ? Image.network(_problemImage!.path, fit: BoxFit.cover)
                          : Image.network(_problemImage!.path, fit: BoxFit.cover), // Image.network handles blob on web and paths on mobile sometimes, but let's be safe
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
                        child: kIsWeb
                          ? Image.network(_locationImages[index].path, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                          : Image.network(_locationImages[index].path, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
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
