import 'package:flutter/material.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar Modern
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.amber,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Detail Pekerjaan',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              centerTitle: true,
              background: Container(
                color: Colors.amber,
                child: Center(
                  child: Icon(Icons.handyman_rounded, size: 80, color: Colors.white.withOpacity(0.5)),
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
                  // Judul & Kategori
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Perbaikan Kran Air",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text("Perbaikan",
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info Cards
                  Row(
                    children: [
                      _buildQuickInfo(Icons.payments_rounded, "Rp100.000", "Estimasi"),
                      const SizedBox(width: 15),
                      _buildQuickInfo(Icons.timer_rounded, "2-3 Jam", "Durasi"),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text("Deskripsi Pekerjaan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    "Memperbaiki kran air yang mampet di area dapur. Kran tidak mengeluarkan air sama sekali padahal pompa menyala. Perlu pengecekan pipa di area belakang kran.",
                    style: TextStyle(color: Color(0xFF64748B), height: 1.6),
                  ),

                  const SizedBox(height: 30),
                  const Text("Lokasi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        const Expanded(
                          child: Text("Jalan Braga No. 13, Sumur Bandung, Kota Bandung",
                            style: TextStyle(fontSize: 14, color: Color(0xFF334155))),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text("Foto Lokasi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (context, index) => const SizedBox(width: 15),
                      itemBuilder: (context, index) => Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.image_outlined, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120), // Space for button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
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
            onPressed: () => Navigator.pushNamed(context, '/job_success'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text("Ambil Pekerjaan Sekarang",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
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
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
