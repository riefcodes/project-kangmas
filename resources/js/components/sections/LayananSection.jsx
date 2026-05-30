import React from 'react';
import { 
  BuildingOfficeIcon, 
  WrenchIcon, 
  BoltIcon, 
  VideoCameraIcon, 
  HomeIcon
} from '@heroicons/react/24/outline';
import { Lightbulb } from 'lucide-react';

export default function LayananSection() {
  const services = [
    {
      id: 1,
      name: 'Service AC',
      desc: 'Solusi tepat untuk AC kurang dingin atau tidak terawat. Kami melayani cuci AC, isi freon, dan perbaikan kerusakan agar udara rumah Anda kembali segar dan sejuk.',
      icon: <BoltIcon className="h-6 w-6 text-primary" />,
    },
    {
      id: 2,
      name: 'Kelistrikan Dan Kabel',
      desc: 'Instalasi dan perbaikan sistem kelistrikan rumah Anda secara aman. Kami menangani konsleting, pemasangan lampu, saklar, hingga penataan kabel baru dengan standar keamanan tinggi.',
      icon: <BoltIcon className="h-6 w-6 text-primary" />,
    },
    {
      id: 3,
      name: 'Pembangunan Umum',
      desc: 'Layanan konstruksi dan renovasi bangunan terpercaya. Dari pengecoran, pemasangan keramik, hingga perbaikan tembok yang retak dengan hasil yang presisi dan kokoh.',
      icon: <BuildingOfficeIcon className="h-6 w-6 text-primary" />,
    },
    {
      id: 4,
      name: 'Sistem Keamanan',
      desc: 'Instalasi perangkat keamanan rumah terintegrasi seperti CCTV modern, sensor gerak, dan alarm pintar untuk memastikan keamanan keluarga Anda terjaga setiap waktu.',
      icon: <VideoCameraIcon className="h-6 w-6 text-primary" />,
    },
    {
      id: 5,
      name: 'Perawatan Bangunan',
      desc: 'Pemeliharaan rutin bangunan untuk menjaga estetika dan ketahanan rumah Anda dari kebocoran, dinding lembab, pelapukan kayu, serta perbaikan struktural ringan lainnya.',
      icon: <WrenchIcon className="h-6 w-6 text-primary" />,
    },
    {
      id: 6,
      name: 'Perluasan Rumah',
      desc: 'Bantu wujudkan rencana penambahan ruangan, pembuatan lantai baru (tingkat), atau area taman baru dengan rancangan struktur yang aman, rapi, dan sesuai keinginan Anda.',
      icon: <HomeIcon className="h-6 w-6 text-primary" />,
    },
  ];

  return (
    <section id="layanan" className="w-full bg-white py-20">
      <div className="kangmas-container">
        <div className="text-center mb-12">
          <div className="inline-block text-primary text-sm font-semibold mb-2">Layanan Kami</div>
          <h2 className="text-3xl font-bold text-gray-900">Spesialisasi Kami</h2>
          <p className="text-gray-600 mt-4 max-w-2xl mx-auto">
            Temukan berbagai kategori layanan pertukangan terbaik, bergaransi, dan dikerjakan langsung oleh tenaga profesional untuk mewujudkan hunian impian Anda yang nyaman dan aman.
          </p>
        </div>

        {/* 1 col on mobile, 2 on tablet, 3 on desktop */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mt-12">
          {services.map((service) => (
            <div key={service.id} className="bg-dark text-white p-8 rounded-xl hover:-translate-y-1 transition duration-300 h-full flex flex-col">
              <div className="mb-6">{service.icon}</div>
              <h3 className="text-xl font-bold mb-4 text-primary">{service.name}</h3>
              <p className="text-gray-400 text-sm flex-grow leading-relaxed">{service.desc}</p>
              <div className="mt-8 flex justify-end">
                  <div className="w-8 h-8 rounded-full border border-gray-600 flex items-center justify-center text-gray-400 hover:text-white hover:border-white cursor-pointer transition">
                    →
                  </div>
              </div>
            </div>
          ))}
        </div>

        <div className="text-center mt-16 bg-gray-50 p-6 rounded-2xl border border-gray-100 max-w-3xl mx-auto">
          <p className="text-gray-600 text-sm">
            <Lightbulb className="w-4 h-4 inline text-primary" /> <strong>Butuh layanan khusus atau skala proyek besar?</strong> Jangan ragu untuk <a href="#call-center" className="text-primary font-bold hover:underline">menghubungi Call Center kami</a>. Kami siap memberikan konsultasi gratis dan mengirimkan tukang spesialis terbaik langsung ke tempat Anda!
          </p>
        </div>
      </div>
    </section>
  );
}
