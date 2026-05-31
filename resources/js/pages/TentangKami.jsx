import React from 'react';
import { CheckBadgeIcon } from '@heroicons/react/24/solid';
import { BuildingOfficeIcon, UserGroupIcon, WrenchIcon } from '@heroicons/react/24/outline';
import { Hand, Star } from 'lucide-react';

export default function TentangKami() {
  return (
    <div className="w-full">
      <div className="bg-white py-16">
        <div className="kangmas-container">
          <div className="flex flex-col lg:flex-row items-center gap-12">
            <div className="lg:w-1/2">
              <div className="inline-flex items-center gap-2 bg-gray-100 px-4 py-2 rounded-full text-sm font-semibold text-gray-700 mb-6">
                 <Hand className="w-4 h-4" /> Selamat Datang Di TUKANG
              </div>
              <h1 className="text-5xl font-bold text-gray-900 leading-tight mb-6">
                Kami Berkomitmen<br/>Untuk Kualitas
              </h1>
              <p className="text-gray-600 mb-8 leading-relaxed">
                Kami adalah penyedia layanan jasa tenaga kerja yang siap dan berkomitmen untuk mengutamakan kualitas serta kepuasan pelanggan dari berbagai aspek. Kami dibangun pada tahun 2023 dan ingin menyelesaikan masalah yang ada di dalam masyarakat terutama mempermudah antara konsumen dan TUKANG untuk bersama-sama membuat pekerjaan dan saling menguntungkan. Kami adalah penghubung antara konsumen yang kebingungan untuk mencari tukang serta kepastian harga untuk pekerjaan yang dia ingin selesaikan.
              </p>
              
              <div className="grid grid-cols-2 gap-4 mb-8">
                <div className="flex items-center gap-2">
                  <CheckBadgeIcon className="h-6 w-6 text-primary" />
                  <span className="text-sm font-semibold text-gray-800">TUKANG Terkualifikasi</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckBadgeIcon className="h-6 w-6 text-primary" />
                  <span className="text-sm font-semibold text-gray-800">Teknologi Yang Mumpuni</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckBadgeIcon className="h-6 w-6 text-primary" />
                  <span className="text-sm font-semibold text-gray-800">Kami Mengutamakan 24 Jam</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckBadgeIcon className="h-6 w-6 text-primary" />
                  <span className="text-sm font-semibold text-gray-800">Ingin Mengembangkan</span>
                </div>
              </div>

              <div className="border-l-4 border-primary pl-4">
                <h4 className="font-bold text-gray-900">Titus Tunjung Aji</h4>
                <p className="text-primary text-sm font-semibold">Founder of TUKANG</p>
              </div>
            </div>
            <div className="lg:w-1/2 flex justify-center relative">
               <img src="https://images.unsplash.com/photo-1621905252507-b35492cc74b4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80" alt="Tukang Professional" className="max-w-md w-full rounded-2xl shadow-xl z-10 relative" />
               <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-full h-[120%] bg-gray-100 rounded-full z-0 -rotate-12 blur-3xl opacity-50"></div>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-gray-50 pb-20">
        <div className="kangmas-container relative z-20 -mt-12">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
            {[
              { icon: <WrenchIcon className="h-10 w-10 text-primary" />, num: '2000+', label: 'Pekerjaan Selesai' },
              { icon: <BuildingOfficeIcon className="h-10 w-10 text-primary" />, num: '100+', label: 'Partner Bisnis' },
              { icon: <UserGroupIcon className="h-10 w-10 text-primary" />, num: '1000+', label: 'Tenaga Kerja TUKANG' },
              { icon: <Star className="h-10 w-10 text-primary" />, num: '1000+', label: 'Konsumen Senang' },
            ].map((stat, i) => (
              <div key={i} className="bg-white p-8 rounded-xl shadow border border-gray-100 text-center flex flex-col items-center justify-center">
                <div className="mb-4">{stat.icon}</div>
                <h3 className="text-3xl font-bold text-gray-900 mb-2">{stat.num}</h3>
                <p className="text-gray-500 text-sm font-medium">{stat.label}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="bg-white py-20 border-t border-gray-100">
        <div className="kangmas-container flex flex-col lg:flex-row gap-16">
          <div className="lg:w-1/2">
             <div className="inline-flex items-center gap-2 bg-gray-100 px-4 py-2 rounded-full text-sm font-semibold text-gray-700 mb-6">
                 <Hand className="w-4 h-4" /> Selamat Datang Di TUKANG
             </div>
             <h2 className="text-4xl font-bold text-gray-900 mb-6 leading-tight">
               Ayo Membangun Sesuatu Yang Kreatif Bersama!
             </h2>
             <p className="text-gray-600 mb-8">
               Kami berusaha menyediakan layanan terbaik untuk anda. Kami juga siap untuk bersama dengan anda membangun sesuatu yang menarik dan kreatif bersama. Bersama kita mengerjakan pekerjaan.
             </p>
             <div className="space-y-6">
               <div>
                 <div className="flex items-center gap-2 mb-2">
                   <CheckBadgeIcon className="h-6 w-6 text-primary" />
                   <h4 className="font-bold text-gray-900">24 Jam Prioritas Pelayanan</h4>
                 </div>
                 <p className="text-sm text-gray-600 pl-8">Kapanpun dan dimanapun anda berada. Di saat para TUKANG masih siap mereka akan menerima pekerjaan kapan saja anda memerlukannya.</p>
               </div>
               <div>
                 <div className="flex items-center gap-2 mb-2">
                   <CheckBadgeIcon className="h-6 w-6 text-primary" />
                   <h4 className="font-bold text-gray-900">TUKANG Terkualifikasi</h4>
                 </div>
                 <p className="text-sm text-gray-600 pl-8">Anda tidak akan mendapatkan TUKANG tanpa pengalaman. Dikarenakan semua TUKANG yang ada harus melalui seleksi terlebih dahulu untuk mengukur kemampuan dan pengalaman mereka di bidang pertukangan.</p>
               </div>
             </div>
          </div>
          
          <div className="lg:w-1/2 relative">
             <div className="absolute left-6 top-0 bottom-0 w-px bg-gray-300 border-dashed border-l-2"></div>
             <div className="space-y-12 relative z-10 pl-16">
                {[
                  { step: 'Tahap 1', text: 'Pesan TUKANG melalui aplikasi di handphone anda sesuai dengan pekerjaan yang ingin anda kami bantu.' },
                  { step: 'Tahap 2', text: 'Setelah pembayaran tukang terdekat akan langsung ke tempat anda. Mereka datang dengan keadaan sudah tau masalah anda dan ingin menyelesaikan bersama anda.' },
                  { step: 'Tahap 3', text: 'Ketika TUKANG sudah sampai di tempat anda, mereka akan langsung mengerjakan sesuai perintah anda dan sesuai aplikasi.' }
                ].map((item, i) => (
                  <div key={i} className="relative">
                    <div className="absolute -left-16 w-3 h-3 bg-primary rounded-full mt-2 ring-4 ring-white"></div>
                    <div className="bg-dark text-white text-xs font-bold px-3 py-1 rounded inline-block mb-3">
                      {item.step}
                    </div>
                    <div className="bg-gray-50 border border-gray-100 p-6 rounded-lg shadow-sm">
                      <p className="text-sm text-gray-600">{item.text}</p>
                    </div>
                  </div>
                ))}
             </div>
          </div>
        </div>
      </div>

    </div>
  );
}
