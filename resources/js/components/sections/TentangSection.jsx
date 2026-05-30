import React from 'react';
import { CheckBadgeIcon } from '@heroicons/react/24/solid';
import { Hand } from 'lucide-react';

export default function TentangSection() {
  return (
    <section id="tentang" className="w-full pt-16">
      <div className="bg-white py-16">
        <div className="kangmas-container">
          <div className="flex flex-col lg:flex-row items-center gap-12">
            <div className="lg:w-1/2">
              <div className="inline-flex items-center gap-2 bg-gray-100 px-4 py-2 rounded-full text-sm font-semibold text-gray-700 mb-6">
                 <Hand className="w-4 h-4" /> Tentang KANGMAS
              </div>
              <h2 className="text-4xl font-bold text-gray-900 leading-tight mb-6">
                Menghubungkan Anda<br/>Dengan Ahlinya
              </h2>
              <p className="text-gray-600 mb-8 leading-relaxed">
                Di era digital yang serba cepat ini, mencari tukang bangunan atau teknisi yang terpercaya seringkali menjadi kendala. KANGMAS hadir memberikan platform digital yang mempermudah Anda bertemu dengan mitra tukang profesional, dengan standar mutu dan kepuasan yang diatur secara sistematis melalui kontrol verifikasi yang ketat oleh sistem.
              </p>
              
              <div className="grid grid-cols-2 gap-4 mb-8">
                <div className="flex items-center gap-2">
                  <CheckBadgeIcon className="h-6 w-6 text-primary" />
                  <span className="text-sm font-semibold text-gray-800">Tukang Terkualifikasi</span>
                </div>
                <div className="flex items-center gap-2">
                  <CheckBadgeIcon className="h-6 w-6 text-primary" />
                  <span className="text-sm font-semibold text-gray-800">Teknologi Mumpuni</span>
                </div>
              </div>

            </div>
            <div className="lg:w-1/2 flex justify-center relative">
               <img src="https://images.unsplash.com/photo-1621905252507-b35492cc74b4?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80" alt="Tukang Professional" className="max-w-md w-full rounded-2xl shadow-xl z-10 relative" />
               <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-full h-[120%] bg-gray-100 rounded-full z-0 -rotate-12 blur-3xl opacity-50"></div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
