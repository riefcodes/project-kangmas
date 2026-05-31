import React, { useState, useEffect } from 'react';
import api from '../../services/api';
import { GoogleMap, useLoadScript, Marker, InfoWindow } from '@react-google-maps/api';
import { Smartphone, Download, Star } from 'lucide-react';

const mapContainerStyle = {
  width: '100%',
  height: '500px',
  borderRadius: '1rem',
};

const center = {
  lat: -6.974001,
  lng: 107.630348,
};

export default function MapsSection() {
  const [tukangList, setTukangList] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
     fetchTukangs();
  }, []);

  const fetchTukangs = async () => {
     try {
        const res = await api.get('/tukang');
        setTukangList(res.data.data);
     } catch (error) {
        console.error('Error fetching map data:', error);
     } finally {
        setLoading(false);
     }
  };
  const { isLoaded, loadError } = useLoadScript({
    googleMapsApiKey: import.meta.env.VITE_GOOGLE_MAPS_API_KEY || '', 
  });

  const [selectedTukang, setSelectedTukang] = useState(null);
  const [showMobileAlert, setShowMobileAlert] = useState(false);

  const getStatusColor = (status) => {
     return status === 'Available' ? 'text-green-600 bg-green-100' : 'text-red-600 bg-red-100';
  }

  return (
    <section id="maps" className="w-full bg-white py-20 border-t border-gray-100">

      <style dangerouslySetInnerHTML={{__html: `
        .gm-err-container, .gm-err-modal, .gm-err-content {
          display: none !important;
        }
        .gm-style iframe + div {
          background-color: transparent !important;
        }
        .gm-style-cc {
          display: none !important;
        }
        .gmnoprint {
          display: none !important;
        }
        a[href^="https://maps.google.com/maps"] {
          display: none !important;
        }
        a[href^="https://www.google.com/maps"] {
          display: none !important;
        }
      `}} />


      {showMobileAlert && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-fade-in">
          <div className="bg-white rounded-2xl p-8 max-w-md w-full shadow-2xl text-center border border-gray-100">
            <div className="w-16 h-16 bg-yellow-50 rounded-full flex items-center justify-center mx-auto mb-4 text-primary">
              <Smartphone className="w-8 h-8" />
            </div>
            <h3 className="text-2xl font-bold text-gray-900 mb-2">Pesan via Aplikasi Mobile</h3>
            <p className="text-gray-600 text-sm mb-6 leading-relaxed">
              Untuk melakukan pemesanan jasa tukang secara praktis, memantau posisi tukang secara real-time, dan bertransaksi dengan aman, silakan gunakan aplikasi mobile <strong>KANGMAS</strong>!
            </p>
            <div className="flex flex-col gap-2.5">
              <button 
                onClick={() => {
                  alert('Fitur download aplikasi mobile segera hadir di Google Play Store!');
                  setShowMobileAlert(false);
                }}
                className="w-full bg-slate-900 hover:bg-slate-800 text-white font-bold py-3 rounded-xl transition text-sm shadow-md flex items-center justify-center gap-2"
              >
                <Download className="w-4 h-4" /> Unduh untuk Android (.APK)
              </button>
              <button 
                onClick={() => setShowMobileAlert(false)}
                className="w-full bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold py-2.5 rounded-xl transition text-xs"
              >
                Tutup
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="kangmas-container">
        <div className="text-center mb-12">
          <div className="inline-block text-primary text-sm font-semibold mb-2">Pusat Layanan</div>
          <h2 className="text-3xl font-bold text-gray-900">Area Layanan Terfokus</h2>
          <p className="text-gray-600 mt-4 max-w-2xl mx-auto">
            Area utama operasional KANGMAS saat ini dipusatkan di sekitar kawasan Telkom University Bandung.
          </p>
        </div>

        <div className="bg-gray-50 border border-gray-200 rounded-2xl p-2 shadow-inner relative">
          {loadError ? (
            <div className="h-[500px] flex items-center justify-center text-red-500 font-bold bg-white rounded-xl">
              Error Loading Maps
            </div>
          ) : !isLoaded ? (
            <div className="h-[500px] flex items-center justify-center text-gray-500 font-bold bg-white rounded-xl">
              Loading Google Maps...
            </div>
          ) : (
            <>

              <div className="absolute top-6 right-6 z-10 bg-white/90 backdrop-blur px-4 py-2 rounded-lg shadow-md border border-gray-200 pointer-events-none">
                 <p className="text-xs font-bold text-gray-800">Menampilkan hasil di:</p>
                 <p className="text-sm font-semibold text-primary">Telkom University, Bandung</p>
              </div>

              <GoogleMap
                mapContainerStyle={mapContainerStyle}
                zoom={15}
                center={center}
                options={{
                   disableDefaultUI: true,
                   zoomControl: true,
                }}
              >


                {tukangList.map((tukang) => {
                  const pseudoRandom = (seed) => {
                     const x = Math.sin(seed) * 10000;
                     return x - Math.floor(x);
                  };
                  
                  const hasValidCoords = tukang.lat && tukang.lng && parseFloat(tukang.lat) !== 0;
                  
                  const posLat = hasValidCoords 
                      ? parseFloat(tukang.lat) 
                      : center.lat + (pseudoRandom(tukang.id) - 0.5) * 0.015;
                  
                  const posLng = hasValidCoords 
                      ? parseFloat(tukang.lng) 
                      : center.lng + (pseudoRandom(tukang.id + 100) - 0.5) * 0.015;
                  
                  return (
                    <Marker
                      key={tukang.id}
                      position={{ lat: posLat, lng: posLng }}
                      onClick={() => setSelectedTukang({...tukang, lat: posLat, lng: posLng, rating: tukang.rating || 4.5, status: tukang.status || 'Available'})}
                    />
                  );
                })}

                {selectedTukang && (
                  <InfoWindow
                    position={{ lat: selectedTukang.lat, lng: selectedTukang.lng }}
                    onCloseClick={() => setSelectedTukang(null)}
                  >
                    <div className="p-2 min-w-[220px]">
                      <h3 className="font-bold text-gray-900 text-lg">{selectedTukang.nama || selectedTukang.name}</h3>
                      <div className="flex items-center gap-1 mt-1 font-semibold text-gray-700">
                        <Star className="w-4 h-4 text-yellow-400 fill-yellow-400" />
                        {selectedTukang.rating}
                      </div>

                      <div className="mt-3 flex items-center gap-2">
                         <span className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Status:</span>
                         <span className={`px-2 py-0.5 rounded text-xs font-bold ${getStatusColor(selectedTukang.status)}`}>
                            {selectedTukang.status}
                         </span>
                      </div>

                      <button 
                        onClick={() => setShowMobileAlert(true)}
                        disabled={selectedTukang.status === 'Busy'}
                        className={`mt-4 w-full font-bold py-1.5 rounded text-sm transition ${
                           selectedTukang.status === 'Available' ? 'bg-primary text-gray-900 hover:bg-primary-hover' : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                        }`}
                      >
                        {selectedTukang.status === 'Available' ? 'Pesan Sekarang' : 'Tukang Sibuk'}
                      </button>
                    </div>
                  </InfoWindow>
                )}
              </GoogleMap>
            </>
          )}
        </div>
      </div>
    </section>
  );
}
