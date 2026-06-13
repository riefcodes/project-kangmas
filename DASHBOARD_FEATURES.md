# Dashboard Admin KANGMAS

## Fitur Baru

Dashboard admin KANGMAS sekarang memiliki halaman utama yang menampilkan statistik dan ranking tukang terbaik. Ini adalah halaman pertama yang dilihat admin saat membuka panel admin.

## Apa yang Ditampilkan

### 1. **Kartu Statistik** (4 kartu utama)
   - **Total Pengguna**: Jumlah seluruh pengguna (customers)
   - **Total Tukang**: Jumlah semua tukang + jumlah yang terverifikasi
   - **Total Pesanan**: Jumlah semua pesanan + jumlah yang selesai
   - **Pesanan Pending**: Pesanan yang menunggu perhatian

### 2. **Grafik Visualisasi**
   - **Pie Chart (Status Pesanan)**: Menampilkan distribusi status pesanan (Selesai, Diterima, Pending, Dibatalkan)
   - **Bar Chart (Breakdown Pesanan)**: Menampilkan jumlah pesanan untuk setiap status

### 3. **Ranking Tukang Terbaik (Top 5)**
   - Menampilkan 5 tukang dengan rating tertinggi
   - Menunjukkan rating, jumlah pesanan, dan kategori keahlian
   - Diurutkan berdasarkan rating tertinggi

### 4. **Pesanan Terbaru (5 Pesanan Terakhir)**
   - Menampilkan pesanan terbaru dengan status real-time
   - Nama pelanggan, tukang, waktu pembuatan, dan status

### 5. **Tombol Aksi Cepat**
   - Verifikasi Tukang
   - Kelola Tukang
   - Lihat Analitik

## Perubahan Backend

### New API Endpoint Enhanced
```
GET /api/admin/dashboard
```

Response yang diperbaharui mencakup:
- `total_users`: Jumlah pengguna
- `total_tukangs`: Jumlah tukang
- `approved_tukangs`: Jumlah tukang terverifikasi
- `orders`: Status pesanan breakdown
- `top_rated_tukangs`: Array top 5 tukang dengan rating tertinggi
- `recent_orders`: Array 5 pesanan terbaru

## Perubahan Frontend

### File Baru
- `resources/js/pages/admin/DashboardHome.jsx` - Komponen dashboard utama

### File Yang Dimodifikasi
- `resources/js/pages/admin/AdminDashboard.jsx` - Menambahkan tab "Dashboard" sebagai default
- `package.json` - Menambahkan dependency `recharts` untuk charting

## Cara Menggunakan

1. Admin login ke panel admin
2. Akan otomatis diarahkan ke Dashboard Home
3. Klik pada tombol di sidebar untuk navigasi ke fitur lain:
   - Dashboard (kembali ke halaman ini)
   - Verifikasi Tukang
   - Manajemen / Blacklist
   - Monitoring Pesanan
   - Analitik & Performa

## Dependencies

- **recharts**: Untuk menampilkan grafik dan chart
- **lucide-react**: Untuk ikon-ikon
- React dan React Router (sudah ada)

## Styling

Menggunakan Tailwind CSS dengan gradient backgrounds dan hover effects untuk tampilan modern yang responsif.

## Screenshot Features

- Responsive design untuk desktop, tablet, dan mobile
- Dark sidebar dengan navigation
- Kartu statistik dengan gradient colors
- Charts interaktif dengan tooltip
- Loading state saat mengambil data
- Error handling untuk API failures
