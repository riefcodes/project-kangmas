import React from 'react';
import { StarIcon } from '@heroicons/react/24/solid';

export default function TestimoniSection() {
  const testimonials = [
    {
      id: 1,
      name: 'Budi Santoso',
      role: 'Pemilik Rumah',
      text: 'Pelayanan KANGMAS sangat cepat dan profesional. Tukang yang datang sangat ahli dalam memperbaiki masalah kelistrikan di rumah saya.',
      rating: 5
    },
    {
      id: 2,
      name: 'Rina Melati',
      role: 'Pengusaha',
      text: 'Sangat terbantu dengan layanan maintenance rutin dari KANGMAS untuk ruko saya. Harganya transparan dan kerjanya rapi.',
      rating: 5
    },
    {
      id: 3,
      name: 'Ahmad Fauzi',
      role: 'Manager Gedung',
      text: 'Sistem komplain dan garansinya sangat baik. Jika ada kekurangan, tim KANGMAS cepat tanggap.',
      rating: 4
    }
  ];

  return (
    <section id="testimoni" className="w-full bg-gray-50 py-20">
      <div className="kangmas-container">
        <div className="text-center mb-12">
          <div className="inline-block text-primary text-sm font-semibold mb-2">Testimoni</div>
          <h2 className="text-3xl font-bold text-gray-900">Apa Kata Klien Kami</h2>
          <p className="text-gray-600 mt-4 max-w-2xl mx-auto">
            Kepercayaan pelanggan adalah prioritas utama kami.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {testimonials.map((testi) => (
            <div key={testi.id} className="bg-white p-8 rounded-2xl shadow-sm border border-gray-100 flex flex-col items-center text-center">
              <div className="flex gap-1 mb-4">
                {[...Array(testi.rating)].map((_, i) => (
                  <StarIcon key={i} className="h-5 w-5 text-yellow-400" />
                ))}
              </div>
              <p className="text-gray-600 italic mb-6">"{testi.text}"</p>
              <div className="mt-auto">
                <h4 className="font-bold text-gray-900">{testi.name}</h4>
                <p className="text-xs text-gray-500 font-medium">{testi.role}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
