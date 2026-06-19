// lib/screens/tukang_home_screen.dart
import 'package:flutter/material.dart';

class TukangHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header sama dengan User
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                _buildJobCard(
                    'Perbaikan', 'memperbaiki kran air mampet', 'Rp100.000',
                    'Jalan braga 13, Bandung'),
                _buildJobCard('Perbaikan', 'genteng rumah bocor', 'Rp170.000',
                    'Sukapura, Bandung'),
                _buildJobCard(
                    'Pembangunan', 'membangun pagar depan rumah', 'Rp1.200.000',
                    'Margahayu, Bandung'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      decoration: BoxDecoration(color: Color(0xFFFFC107),
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(Icons.menu, color: Colors.white, size: 30),
            Text('Dashboard Tukang', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
            CircleAvatar(backgroundColor: Colors.white, radius: 20),
          ]),
          SizedBox(height: 30),
          Text('Selamat Datang', style: TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildJobCard(String cat, String desc, String price, String loc) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.amber.shade200),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Icon(Icons.build_circle, size: 50, color: Colors.grey),
          SizedBox(width: 15),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cat, style: TextStyle(fontWeight: FontWeight.bold)),
              Text('"$desc"', style: TextStyle(color: Colors.grey,
                  fontSize: 12,
                  fontStyle: FontStyle.italic)),
              SizedBox(height: 5),
              Row(children: [
                Icon(Icons.monetization_on, size: 14, color: Colors.amber),
                Text(' $price', style: TextStyle(fontWeight: FontWeight.bold))
              ]),
              Row(children: [
                Icon(Icons.location_on, size: 14, color: Colors.amber),
                Text(
                    ' $loc', style: TextStyle(color: Colors.grey, fontSize: 11))
              ]),
            ],
          ))
        ],
      ),
    );
  }
}
