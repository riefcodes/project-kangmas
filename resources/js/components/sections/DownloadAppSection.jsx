import React from 'react';
import { Rocket, Smartphone, Download, Apple, Wrench, Zap } from 'lucide-react';

export default function DownloadAppSection() {
  return (
    <section id="download-app" className="w-full bg-slate-900 py-20 relative overflow-hidden text-white border-t border-slate-800">
      <div className="absolute top-0 right-0 w-96 h-96 bg-primary/10 rounded-full blur-3xl pointer-events-none -mr-20 -mt-20"></div>
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-primary/5 rounded-full blur-3xl pointer-events-none -ml-20 -mb-20"></div>

      <div className="kangmas-container relative z-10">
        <div className="bg-gradient-to-r from-slate-800 to-slate-900 border border-slate-700/60 rounded-3xl p-8 md:p-16 flex flex-col md:flex-row items-center justify-between gap-12 shadow-2xl">
          <div className="md:w-3/5 text-left">
            <div className="inline-flex items-center gap-2 bg-primary/20 text-primary border border-primary/40 px-4 py-1.5 rounded-full text-xs font-bold mb-6 tracking-wide uppercase">
              <Rocket className="w-4 h-4" /> KANGMAS Mobile App
            </div>
            <h2 className="text-3xl md:text-5xl font-black mb-6 leading-tight tracking-tight text-white">
              Semua Layanan Pertukangan<br className="hidden md:inline" /> 
              Kini Ada di Genggaman Anda!
            </h2>
            <p className="text-slate-300 text-base md:text-lg mb-8 leading-relaxed">
              Dapatkan kemudahan memesan tukang profesional, berkonsultasi secara real-time, melacak pengerjaan, dan melakukan pembayaran secara aman hanya melalui aplikasi mobile <strong>KANGMAS</strong>. Unduh sekarang juga!
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4">
              <button 
                onClick={() => alert('Fitur unduh aplikasi mobile di Google Play Store segera hadir!')}
                className="inline-flex items-center justify-center gap-3 px-6 py-3.5 bg-primary hover:bg-yellow-500 text-gray-900 font-bold rounded-xl transition shadow-lg text-sm"
              >
                <Download className="w-5 h-5" /> Unduh untuk Android (.APK)
              </button>
              <button 
                onClick={() => alert('Aplikasi iOS saat ini sedang dalam proses pengembangan!')}
                className="inline-flex items-center justify-center gap-3 px-6 py-3.5 bg-slate-800 hover:bg-slate-700 text-white font-bold rounded-xl transition border border-slate-700 text-sm"
              >
                <Apple className="w-5 h-5" /> Unduh untuk iOS (App Store)
              </button>
            </div>
          </div>

          <div className="md:w-2/5 flex justify-center relative">
            <div className="w-56 h-[460px] bg-slate-950 border-[6px] border-slate-800 rounded-[3rem] shadow-2xl relative overflow-hidden flex flex-col justify-between p-4">
              <div className="w-24 h-4 bg-slate-800 rounded-full mx-auto mb-2"></div>
              
              <div className="flex-grow bg-slate-900 rounded-2xl p-4 flex flex-col justify-between border border-slate-800/80">
                <div>
                  <div className="text-primary font-black text-xl mb-1 flex items-center gap-1">
                    <Wrench className="w-5 h-5" /> KANGMAS
                  </div>
                  <div className="w-full h-2 bg-slate-800 rounded-full mb-4"></div>
                  
                  <div className="space-y-2">
                    <div className="bg-slate-800/60 p-2.5 rounded-xl border border-slate-700/30 flex items-center gap-2">
                      <Zap className="w-3 h-3 text-primary" />
                      <div className="flex-grow space-y-1">
                        <div className="w-3/4 h-1.5 bg-slate-700 rounded"></div>
                        <div className="w-1/2 h-1 bg-slate-700 rounded"></div>
                      </div>
                    </div>
                    <div className="bg-slate-800/60 p-2.5 rounded-xl border border-slate-700/30 flex items-center gap-2">
                      <Wrench className="w-3 h-3 text-primary" />
                      <div className="flex-grow space-y-1">
                        <div className="w-2/3 h-1.5 bg-slate-700 rounded"></div>
                        <div className="w-1/2 h-1 bg-slate-700 rounded"></div>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="bg-primary text-gray-900 text-center font-black py-2 rounded-xl text-xs shadow">
                  Pesan Tukang Sekarang
                </div>
              </div>
            </div>

            <div className="absolute inset-0 bg-primary/20 rounded-full blur-2xl -z-10 w-48 h-48 mx-auto my-auto"></div>
          </div>
        </div>
      </div>
    </section>
  );
}
