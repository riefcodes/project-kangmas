import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Histori Transaksi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHistoryCard(
            name: 'Titus Aji Saka',
            task: 'pemasangan kran air & pe..',
            status: 'Sedang Berlangsung',
            isActive: true,
          ),
          _buildHistoryCard(
            name: 'Belagio Hantono',
            task: 'pembersihan teras rumah',
            status: 'Kemarin pada 13.42 WIB',
          ),
          _buildHistoryCard(
            name: 'Rendra Wardana',
            task: 'Perbaikan AC',
            status: '12 Juni pada 09.23 WIB',
          ),
          _buildHistoryCard(
            name: 'Andy Santosa',
            task: 'Pemasangan Jendela di kam..',
            status: '8 Juni pada 15.34 WIB',
          ),
          _buildHistoryCard(
            name: 'Siti Barokah',
            task: 'Perbaikan genteng bocor',
            status: '17 Mei pada 08.46 WIB',
          ),
          _buildHistoryCard(
            name: 'Revina Gracia',
            task: 'Perbaikan kran air bocor',
            status: '8 Februari pada 10.28 WIB',
          ),
          _buildHistoryCard(
            name: 'Louise Chen',
            task: 'Pembersihan Halaman Rumah',
            status: '5 Februari pada 08.27 WIB',
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.amber,
        shape: const CircleBorder(),
        child: const Icon(Icons.build, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHistoryCard({
    required String name,
    required String task,
    required String status,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade100),
      ),
      child: Row(
        children: [
          Expanded( // Menambahkan Expanded untuk mencegah overflow pada teks sebelah kiri
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  task,
                  overflow: TextOverflow.ellipsis, // Tambahkan titik-titik jika teks terlalu panjang
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min, // Agar row kanan tidak memakan ruang berlebih
            children: [
              if (isActive)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),
              const SizedBox(width: 5),
              Text(
                status,
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.grey,
                  fontSize: 11, // Sedikit diperkecil
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: const Icon(Icons.home), onPressed: () {}),
            IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
            const SizedBox(width: 40),
            IconButton(icon: const Icon(Icons.assignment, color: Colors.amber), onPressed: () {}),
            IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
