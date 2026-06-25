import React, { useState, useEffect } from 'react';
import api from '../../services/api';
import { FileText, FolderOpen, IdCard, MapPin, Star, ClipboardList, ShoppingBag, Calendar, DollarSign, User as UserIcon, Home as HomeIcon } from 'lucide-react';
import DashboardHome from './DashboardHome';

// Normalize any storage URL/path to a relative /storage/... path
// Handles: full URLs (http://x.x.x.x:8000/storage/...), relative paths (/storage/...), raw paths (documents/ktp/...)
function normalizeStorageUrl(urlOrPath) {
  if (!urlOrPath) return null;
  // If it's already a full URL, extract just the path part after /storage/
  if (urlOrPath.startsWith('http')) {
    try {
      const parsed = new URL(urlOrPath);
      // Use just the pathname so it's relative to current origin
      return parsed.pathname;
    } catch (e) {
      // fallback
    }
  }
  // If it already starts with /storage, return as-is
  if (urlOrPath.startsWith('/storage')) return urlOrPath;
  // Raw path from DB like "documents/ktp/xxx.jpg"
  return `/storage/${urlOrPath}`;
}

function DocumentModal({ tukang, onClose }) {
  if (!tukang) return null;

  const docs = [
    { label: 'Foto KTP', url: normalizeStorageUrl(tukang.ktp_url) },
    { label: 'Selfie dengan KTP', url: normalizeStorageUrl(tukang.selfie_url) },
    { label: 'Portofolio', url: normalizeStorageUrl(tukang.portofolio_url) },
  ];

  return (
    <div
      className="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center z-50 p-4"
      onClick={onClose}
    >
      <div
        className="bg-white rounded-2xl shadow-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto"
        onClick={e => e.stopPropagation()}
      >
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <div>
            <h2 className="text-xl font-bold text-gray-800">Detail & Dokumen Pendaftar</h2>
            <p className="text-sm text-gray-500 mt-1">
              ID Pendaftar &bull; #{tukang.id}
            </p>
          </div>
          <button
            onClick={onClose}
            className="w-9 h-9 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 text-gray-600 text-xl font-bold transition"
          >
            &times;
          </button>
        </div>

        <div className="p-6 border-b border-gray-100 bg-gray-50/50">
          <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-4">Informasi Lengkap Pendaftaran</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-y-4 gap-x-8">
            <div className="flex flex-col">
              <span className="text-xs text-gray-500 font-semibold">Nama Lengkap</span>
              <span className="text-sm font-bold text-gray-800">{tukang.nama || tukang.name || '-'}</span>
            </div>
            <div className="flex flex-col">
              <span className="text-xs text-gray-500 font-semibold">Email</span>
              <span className="text-sm font-bold text-gray-800">{tukang.email || '-'}</span>
            </div>
            <div className="flex flex-col">
              <span className="text-xs text-gray-500 font-semibold">Kategori Keahlian</span>
              <span className="text-sm font-bold text-blue-700 bg-blue-50 px-2.5 py-0.5 rounded border border-blue-200 inline-block w-fit mt-1 uppercase text-xs">
                {tukang.skill || '-'}
              </span>
            </div>
            <div className="flex flex-col">
              <span className="text-xs text-gray-500 font-semibold">Lama Pengalaman</span>
              <span className="text-sm font-bold text-gray-800">{(tukang.experience !== undefined && tukang.experience !== null) ? tukang.experience : 0} Tahun</span>
            </div>
            <div className="flex flex-col">
              <span className="text-xs text-gray-500 font-semibold">Nomor WhatsApp / HP</span>
              <a href={`https://wa.me/${tukang.phone?.replace(/[^0-9]/g, '')}`} target="_blank" rel="noopener noreferrer" className="text-sm font-bold text-green-700 hover:underline flex items-center gap-1 mt-0.5">
                {tukang.phone || '-'} (Hubungi WhatsApp)
              </a>
            </div>
            <div className="flex flex-col md:col-span-2">
              <span className="text-xs text-gray-500 font-semibold">Alamat Lengkap</span>
              <span className="text-sm text-gray-800 font-medium leading-relaxed">{tukang.address || '-'}</span>
            </div>
            {tukang.lat && tukang.lng && (
              <div className="flex flex-col md:col-span-2">
                <span className="text-xs text-gray-500 font-semibold">Koordinat Lokasi</span>
                <a
                  href={`https://www.google.com/maps/search/?api=1&query=${tukang.lat},${tukang.lng}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm font-bold text-blue-600 hover:underline flex items-center gap-1 mt-0.5"
                >
                  <MapPin className="w-3.5 h-3.5 inline text-red-500" /> Lihat di Google Maps ({Number(tukang.lat).toFixed(5)}, {Number(tukang.lng).toFixed(5)})
                </a>
              </div>
            )}
          </div>
        </div>

        <div className="p-6 grid gap-6">
          <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider">Berkas Dokumen Lampiran</h3>
          {docs.map(doc => (
            <div key={doc.label} className="border border-gray-200 rounded-xl overflow-hidden">
              <div className="bg-gray-50 px-4 py-2 border-b border-gray-200">
                <span className="font-semibold text-gray-700 text-sm">{doc.label}</span>
                {!doc.url && (
                  <span className="ml-2 text-xs text-gray-400 italic">(Tidak diupload)</span>
                )}
              </div>
              <div className="p-4 flex justify-center bg-gray-50 min-h-[180px] items-center">
                {doc.url ? (
                  doc.url.toLowerCase().endsWith('.pdf') ? (
                    <a
                      href={doc.url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-2 px-5 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-semibold"
                    >
                      <FileText className="w-4 h-4 inline mr-1" /> Buka PDF {doc.label}
                    </a>
                  ) : (
                    <a href={doc.url} target="_blank" rel="noopener noreferrer">
                      <img
                        src={doc.url}
                        alt={doc.label}
                        className="max-h-64 max-w-full rounded-lg object-contain shadow border border-gray-200 hover:opacity-90 transition"
                        onError={(e) => {
                          e.target.onerror = null;
                          e.target.style.display = 'none';
                          e.target.parentElement.innerHTML = '<div class="text-center text-red-400 py-8"><p class="text-sm font-semibold">Gagal memuat gambar</p><p class="text-xs text-gray-400 mt-1">File mungkin belum tersedia di server</p></div>';
                        }}
                      />
                    </a>
                  )
                ) : (
                  <div className="text-center text-gray-400 py-8">
                    <div className="flex justify-center mb-2"><FolderOpen className="w-10 h-10 text-gray-300" /></div>
                    <p className="text-sm">Tidak ada dokumen yang diupload</p>
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function OrderDocumentModal({ order, onClose }) {
  if (!order) return null;

  const docs = [];
  if (order.image_path) {
    docs.push({ label: 'Foto Masalah Utama', url: normalizeStorageUrl(order.image_path) });
  }
  if (order.location_images && order.location_images.length > 0) {
    order.location_images.forEach((img, idx) => {
      docs.push({ label: `Foto Kondisi Lokasi ${idx + 1}`, url: normalizeStorageUrl(img.image_path || img.path) });
    });
  }
  if (order.proof_image) {
    docs.push({ label: 'Bukti Pekerjaan Selesai', url: normalizeStorageUrl(order.proof_image) });
  }

  return (
    <div
      className="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center z-50 p-4"
      onClick={onClose}
    >
      <div
        className="bg-white rounded-2xl shadow-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto"
        onClick={e => e.stopPropagation()}
      >
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <div>
            <h2 className="text-xl font-bold text-gray-800">Foto & Bukti Pesanan</h2>
            <p className="text-sm text-gray-500 mt-1">
              ID Pesanan &bull; #O-{order.id}
            </p>
          </div>
          <button
            onClick={onClose}
            className="w-9 h-9 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 text-gray-600 text-xl font-bold transition"
          >
            &times;
          </button>
        </div>

        <div className="p-6 grid gap-6">
          <h3 className="text-xs font-bold text-gray-400 uppercase tracking-wider">Berkas Gambar Pesanan</h3>
          {docs.length === 0 ? (
            <div className="text-center text-gray-400 py-8">
              <div className="flex justify-center mb-2"><FolderOpen className="w-10 h-10 text-gray-300" /></div>
              <p className="text-sm">Tidak ada foto/bukti yang diupload untuk pesanan ini.</p>
            </div>
          ) : docs.map((doc, idx) => (
            <div key={idx} className="border border-gray-200 rounded-xl overflow-hidden">
              <div className="bg-gray-50 px-4 py-2 border-b border-gray-200">
                <span className="font-semibold text-gray-700 text-sm">{doc.label}</span>
              </div>
              <div className="p-4 flex justify-center bg-gray-50 min-h-[180px] items-center">
                <a href={doc.url} target="_blank" rel="noopener noreferrer">
                  <img
                    src={doc.url}
                    alt={doc.label}
                    className="max-h-64 max-w-full rounded-lg object-contain shadow border border-gray-200 hover:opacity-90 transition"
                    onError={(e) => {
                      e.target.onerror = null;
                      e.target.style.display = 'none';
                      e.target.parentElement.innerHTML = '<div class="text-center text-red-400 py-8"><p class="text-sm font-semibold">Gagal memuat gambar</p><p class="text-xs text-gray-400 mt-1">File mungkin belum tersedia di server</p></div>';
                    }}
                  />
                </a>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default function AdminDashboard() {
  const [activeTab, setActiveTab] = useState('home');
  const [pendingTukangs, setPendingTukangs] = useState([]);
  const [allTukangs, setAllTukangs] = useState([]);
  const [analyticsData, setAnalyticsData] = useState([]);
  const [ordersData, setOrdersData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedTukang, setSelectedTukang] = useState(null);
  const [selectedOrder, setSelectedOrder] = useState(null);

  useEffect(() => {
    fetchData();
  }, [activeTab]);

  const fetchData = async () => {
    setLoading(true);
    try {
      if (activeTab === 'home') {
        setLoading(false);
        return;
      }
      if (activeTab === 'verification') {
        const res = await api.get('/admin/tukang/pending');
        setPendingTukangs(res.data.data);
      } else if (activeTab === 'manage') {
        const res = await api.get('/admin/users?role=tukang');
        const users = res.data.data.data || res.data.data;
        const approvedUsers = users.filter(u => u.tukang_profile && u.tukang_profile.status === 'approved');
        const formatted = approvedUsers.map(u => {
          const getStorageUrl = (path) => normalizeStorageUrl(path);

          return {
            id: u.tukang_profile?.id || u.id,
            name: u.name,
            email: u.email || '-',
            skill: u.tukang_profile?.category || '-',
            experience: u.tukang_profile?.experience || 0,
            phone: u.phone_number || '-',
            address: u.tukang_profile?.address || '-',
            lat: u.tukang_profile?.lat,
            lng: u.tukang_profile?.lng,
            status: u.tukang_profile?.status || 'Active',
            isBlacklisted: u.tukang_profile?.is_blacklisted || false,
            ktp_url: getStorageUrl(u.tukang_profile?.ktp_path),
            selfie_url: getStorageUrl(u.tukang_profile?.selfie_path),
            portofolio_url: getStorageUrl(u.tukang_profile?.portofolio_path),
          };
        });
        setAllTukangs(formatted);
      } else if (activeTab === 'analytics') {
        const res = await api.get('/admin/tukang/analytics');
        setAnalyticsData(res.data.data);
      } else if (activeTab === 'orders') {
        const res = await api.get('/admin/orders');
        const orders = res.data.data.data || res.data.data;
        setOrdersData(orders);
      }
    } catch (error) {
      console.error('Error fetching admin data:', error);
    } finally {
      setLoading(false);
    }
  };

  const onApprove = async (id) => {
    try {
      await api.post(`/admin/tukang/approve/${id}`);
      fetchData();
    } catch (error) {
      alert('Gagal approve: ' + (error.response?.data?.message || error.message));
    }
  };

  const onReject = async (id) => {
    try {
      await api.post(`/admin/tukang/reject/${id}`);
      fetchData();
    } catch (error) {
      alert('Gagal reject: ' + (error.response?.data?.message || error.message));
    }
  };

  const onBlacklist = async (id) => {
    try {
      await api.post(`/admin/tukang/blacklist/${id}`);
      fetchData();
    } catch (error) {
      alert('Gagal blacklist: ' + (error.response?.data?.message || error.message));
    }
  };

  const onUnblacklist = async (id) => {
    try {
      await api.post(`/admin/tukang/unblacklist/${id}`);
      fetchData();
    } catch (error) {
      alert('Gagal cabut blacklist: ' + (error.response?.data?.message || error.message));
    }
  };

  const handleAction = (actionFn, id, actionName) => {
    if (!window.confirm(`Yakin ingin melakukan aksi ${actionName} pada tukang ID #${id}?`)) return;
    actionFn(id);
  };

  return (
    <div className="h-screen bg-gray-100 flex overflow-hidden">
      {selectedTukang && (
        <DocumentModal tukang={selectedTukang} onClose={() => setSelectedTukang(null)} />
      )}
      {selectedOrder && (
        <OrderDocumentModal order={selectedOrder} onClose={() => setSelectedOrder(null)} />
      )}

      <div className="w-64 bg-slate-900 text-white p-6 shrink-0 overflow-y-auto">
        <h2 className="text-2xl font-bold mb-8 text-primary">Admin Panel</h2>
        <nav className="space-y-4">
          <button
            onClick={() => setActiveTab('home')}
            className={`w-full text-left px-4 py-2 rounded transition ${activeTab === 'home' ? 'bg-primary text-gray-900 font-bold' : 'hover:bg-slate-800'}`}
          >
            Dashboard Utama
          </button>
          <button
            onClick={() => setActiveTab('verification')}
            className={`w-full text-left px-4 py-2 rounded transition ${activeTab === 'verification' ? 'bg-primary text-gray-900 font-bold' : 'hover:bg-slate-800'}`}
          >
            Verifikasi Tukang
          </button>
          <button
            onClick={() => setActiveTab('manage')}
            className={`w-full text-left px-4 py-2 rounded transition ${activeTab === 'manage' ? 'bg-primary text-gray-900 font-bold' : 'hover:bg-slate-800'}`}
          >
            Manajemen / Blacklist
          </button>
          <button
            onClick={() => setActiveTab('orders')}
            className={`w-full text-left px-4 py-2 rounded transition ${activeTab === 'orders' ? 'bg-primary text-gray-900 font-bold' : 'hover:bg-slate-800'}`}
          >
            Monitoring Pesanan
          </button>
          <button
            onClick={() => setActiveTab('analytics')}
            className={`w-full text-left px-4 py-2 rounded transition ${activeTab === 'analytics' ? 'bg-primary text-gray-900 font-bold' : 'hover:bg-slate-800'}`}
          >
            Analitik & Performa
          </button>
        </nav>
      </div>

      <div className="flex-1 p-10 overflow-y-auto">
        <div className="flex justify-between items-center mb-10">
          <h1 className="text-3xl font-bold text-gray-800">
            {activeTab === 'home'
              ? 'Dashboard Utama'
              : activeTab === 'verification'
                ? 'Verifikasi Pendaftaran Tukang WEB'
                : activeTab === 'manage'
                  ? 'Manajemen & Blacklist Tukang'
                  : activeTab === 'orders'
                    ? 'Aktivitas & Monitoring Pesanan'
                    : 'Analitik & Performa Tukang'}
          </h1>
          <a href="/" className="flex items-center gap-2 px-4 py-2 bg-gray-200 text-gray-800 rounded font-semibold hover:bg-gray-300 transition">
            &larr; Kembali ke Beranda
          </a>
        </div>

        {loading ? (
          <div className="flex justify-center items-center py-20 text-gray-500 font-bold">
            Loading Data...
          </div>
        ) : (
          <>
            {activeTab === 'home' && (
              <DashboardHome onNavigateTo={setActiveTab} />
            )}
            {activeTab === 'verification' && (
              <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
                <h3 className="text-xl font-semibold mb-4">Menunggu Verifikasi</h3>
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="bg-gray-50 border-b border-gray-200">
                      <th className="p-4 font-semibold text-gray-600">ID</th>
                      <th className="p-4 font-semibold text-gray-600">Nama</th>
                      <th className="p-4 font-semibold text-gray-600">Keahlian</th>
                      <th className="p-4 font-semibold text-gray-600">No HP</th>
                      <th className="p-4 font-semibold text-gray-600">Dokumen</th>
                      <th className="p-4 font-semibold text-gray-600">Aksi</th>
                    </tr>
                  </thead>
                  <tbody>
                    {pendingTukangs.length === 0 ? (
                      <tr><td colSpan="6" className="p-4 text-center text-gray-500">Tidak ada data pending.</td></tr>
                    ) : pendingTukangs.map(t => (
                      <tr key={t.id} className="border-b border-gray-100">
                        <td className="p-4">#{t.id}</td>
                        <td className="p-4 font-medium">{t.nama || t.name}</td>
                        <td className="p-4">
                          <span className="bg-blue-50 text-blue-700 px-2.5 py-1 rounded-md text-xs font-semibold uppercase">{t.skill}</span>
                        </td>
                        <td className="p-4 text-gray-600">{t.phone}</td>
                        <td className="p-4">
                          <button
                            onClick={() => setSelectedTukang(t)}
                            className="inline-flex items-center gap-1 bg-blue-50 border border-blue-200 text-blue-700 px-3 py-1.5 rounded-lg text-sm font-semibold hover:bg-blue-100 transition"
                          >
                            <IdCard className="w-4 h-4 inline" /> Dokumen
                          </button>
                        </td>
                        <td className="p-4 flex gap-2">
                          <button onClick={() => handleAction(onApprove, t.id, 'Approve')} className="bg-green-500 text-white px-3 py-1 rounded text-sm hover:bg-green-600">Setujui</button>
                          <button onClick={() => handleAction(onReject, t.id, 'Reject')} className="bg-red-500 text-white px-3 py-1 rounded text-sm hover:bg-red-600">Tolak</button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            {activeTab === 'manage' && (
              <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
                <h3 className="text-xl font-semibold mb-4">Daftar Tukang Terverifikasi</h3>
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="bg-gray-50 border-b border-gray-200">
                      <th className="p-4 font-semibold text-gray-600">ID</th>
                      <th className="p-4 font-semibold text-gray-600">Nama</th>
                      <th className="p-4 font-semibold text-gray-600">Keahlian</th>
                      <th className="p-4 font-semibold text-gray-600">Status</th>
                      <th className="p-4 font-semibold text-gray-600">Dokumen</th>
                      <th className="p-4 font-semibold text-gray-600">Manajemen Aksi</th>
                    </tr>
                  </thead>
                  <tbody>
                    {allTukangs.length === 0 ? (
                      <tr><td colSpan="6" className="p-4 text-center text-gray-500">Belum ada tukang terverifikasi.</td></tr>
                    ) : allTukangs.map(t => (
                      <tr key={t.id} className="border-b border-gray-100">
                        <td className="p-4">#{t.id}</td>
                        <td className="p-4 font-medium">{t.nama || t.name}</td>
                        <td className="p-4">
                          <span className="bg-blue-50 text-blue-700 px-2.5 py-1 rounded-md text-xs font-semibold uppercase">{t.skill}</span>
                        </td>
                        <td className="p-4">
                          {t.isBlacklisted || t.status === 'Blacklisted' ? (
                            <span className="bg-red-100 text-red-700 px-2 py-1 rounded text-xs font-bold">Blacklisted</span>
                          ) : (
                            <span className="bg-green-100 text-green-700 px-2 py-1 rounded text-xs font-bold">Active</span>
                          )}
                        </td>
                        <td className="p-4">
                          <button
                            onClick={() => setSelectedTukang(t)}
                            className="inline-flex items-center gap-1 bg-blue-50 border border-blue-200 text-blue-700 px-3 py-1.5 rounded-lg text-sm font-semibold hover:bg-blue-100 transition"
                          >
                            <IdCard className="w-4 h-4 inline" /> Dokumen
                          </button>
                        </td>
                        <td className="p-4 flex gap-2">
                          {(!t.isBlacklisted && t.status !== 'Blacklisted') ? (
                            <button onClick={() => handleAction(onBlacklist, t.id, 'Blacklist')} className="bg-slate-800 text-white px-3 py-1 rounded text-sm hover:bg-slate-900 border border-slate-900">Blacklist</button>
                          ) : (
                            <button onClick={() => handleAction(onUnblacklist, t.id, 'Cabut Blacklist')} className="bg-white border border-gray-300 text-gray-800 px-3 py-1 rounded text-sm hover:bg-gray-50">Cabut Blacklist</button>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            {activeTab === 'analytics' && (
              <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
                <h3 className="text-xl font-semibold mb-4">Metrik Performa & Ulasan</h3>
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="bg-gray-50 border-b border-gray-200">
                      <th className="p-4 font-semibold text-gray-600">Nama</th>
                      <th className="p-4 font-semibold text-gray-600">Keahlian</th>
                      <th className="p-4 font-semibold text-gray-600">Lokasi Daftar</th>
                      <th className="p-4 font-semibold text-gray-600">Rating Rata-rata</th>
                      <th className="p-4 font-semibold text-gray-600">Total Order Selesai</th>
                      <th className="p-4 font-semibold text-gray-600">Pelanggan Unik</th>
                      <th className="p-4 font-semibold text-gray-600">Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {analyticsData.length === 0 ? (
                      <tr><td colSpan="7" className="p-4 text-center text-gray-500">Tidak ada data performa tukang.</td></tr>
                    ) : analyticsData.map(t => (
                      <tr key={t.id} className="border-b border-gray-100 hover:bg-gray-50 transition">
                        <td className="p-4 font-medium text-gray-800">
                          <div>
                            <span className="block font-bold">{t.name}</span>
                            <span className="text-xs text-gray-400">ID #{t.id}</span>
                          </div>
                        </td>
                        <td className="p-4">
                          <span className="bg-blue-50 text-blue-700 px-2.5 py-1 rounded-md text-xs font-semibold uppercase">{t.skill}</span>
                        </td>
                        <td className="p-4">
                          <div className="flex flex-col max-w-[200px]">
                            <span className="text-sm text-gray-700 truncate flex items-center gap-1" title={t.location}><MapPin className="w-3.5 h-3.5 text-red-500 flex-shrink-0" /> {t.location}</span>
                          </div>
                        </td>
                        <td className="p-4">
                          <div className="flex items-center gap-1">
                            <Star className="w-5 h-5 text-yellow-500 fill-yellow-500" />
                            <span className="font-bold text-gray-700">{t.rating ? t.rating : 'N/A'}</span>
                            <span className="text-xs text-gray-400">/5</span>
                          </div>
                        </td>
                        <td className="p-4">
                          <span className="font-bold text-gray-800">{t.completed_orders}</span>
                          <span className="text-xs text-gray-400"> / {t.total_orders} total</span>
                        </td>
                        <td className="p-4 font-semibold text-gray-700">{t.unique_customers} orang</td>
                        <td className="p-4">
                          {t.is_blacklisted || t.status === 'Blacklisted' ? (
                            <span className="bg-red-100 text-red-700 px-2.5 py-1 rounded-full text-xs font-bold">Blacklisted</span>
                          ) : t.status === 'Approved' ? (
                            <span className="bg-green-100 text-green-700 px-2.5 py-1 rounded-full text-xs font-bold">Active</span>
                          ) : (
                            <span className="bg-yellow-100 text-yellow-700 px-2.5 py-1 rounded-full text-xs font-bold">{t.status}</span>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            {activeTab === 'orders' && (
              <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200 font-sans">
                <h3 className="text-xl font-semibold mb-4">Aktivitas Pemantauan Pesanan Aktif</h3>
                <div className="overflow-x-auto">
                  <table className="w-full text-left border-collapse">
                    <thead>
                      <tr className="bg-gray-50 border-b border-gray-200">
                        <th className="p-4 font-semibold text-gray-600">ID Pesanan</th>
                        <th className="p-4 font-semibold text-gray-600">Pelanggan</th>
                        <th className="p-4 font-semibold text-gray-600">Mitra Tukang</th>
                        <th className="p-4 font-semibold text-gray-600">Deskripsi Masalah</th>
                        <th className="p-4 font-semibold text-gray-600">Foto & Bukti</th>
                        <th className="p-4 font-semibold text-gray-600">Estimasi Harga</th>
                        <th className="p-4 font-semibold text-gray-600">Status</th>
                        <th className="p-4 font-semibold text-gray-600">Ulasan & Rating</th>
                      </tr>
                    </thead>
                    <tbody>
                      {ordersData.length === 0 ? (
                        <tr>
                          <td colSpan="8" className="p-8 text-center text-gray-400">
                            <div className="flex flex-col items-center justify-center py-6">
                              <ShoppingBag className="w-12 h-12 text-gray-300 mb-2 animate-bounce" />
                              <p className="text-base font-semibold text-gray-500">Tidak ada aktivitas pemesanan saat ini</p>
                              <p className="text-xs text-gray-400 mt-1">Semua pesanan yang diajukan oleh pengguna via aplikasi mobile akan terpantau real-time di sini.</p>
                            </div>
                          </td>
                        </tr>
                      ) : (
                        ordersData.map(order => (
                          <tr key={order.id} className="border-b border-gray-100 hover:bg-gray-50/50 transition">
                            <td className="p-4 font-bold text-gray-800">#O-{order.id}</td>
                            <td className="p-4">
                              <div className="font-semibold text-gray-900">{order.user?.name || 'Pelanggan'}</div>
                              {order.user?.phone_number && (
                                <a 
                                  href={`https://wa.me/${order.user.phone_number.replace(/[^0-9]/g, '')}`} 
                                  target="_blank" 
                                  rel="noopener noreferrer"
                                  className="text-xs text-green-600 hover:underline inline-flex items-center gap-1 font-medium mt-0.5"
                                >
                                  {order.user.phone_number} (Chat)
                                </a>
                              )}
                            </td>
                            <td className="p-4">
                              <div className="font-semibold text-gray-900">{order.tukang?.name || 'Mitra Tukang'}</div>
                              {order.tukang?.phone_number && (
                                <a 
                                  href={`https://wa.me/${order.tukang.phone_number.replace(/[^0-9]/g, '')}`} 
                                  target="_blank" 
                                  rel="noopener noreferrer"
                                  className="text-xs text-green-600 hover:underline inline-flex items-center gap-1 font-medium mt-0.5"
                                >
                                  {order.tukang.phone_number} (Chat)
                                </a>
                              )}
                            </td>
                            <td className="p-4 max-w-[240px]">
                              <p className="text-sm text-gray-700 font-medium truncate" title={order.description}>{order.description}</p>
                              <span className="text-xs text-gray-400 flex items-center gap-1 mt-1"><Calendar className="w-3 h-3 text-gray-400" /> {new Date(order.created_at).toLocaleDateString('id-ID', {day: 'numeric', month: 'short', year: 'numeric'})}</span>
                            </td>
                            <td className="p-4">
                              <button
                                onClick={() => setSelectedOrder(order)}
                                className="inline-flex items-center gap-1 bg-blue-50 border border-blue-200 text-blue-700 px-3 py-1.5 rounded-lg text-sm font-semibold hover:bg-blue-100 transition"
                              >
                                <IdCard className="w-4 h-4 inline" /> Foto
                              </button>
                            </td>
                            <td className="p-4 font-bold text-gray-800">
                              {order.total_price ? `Rp ${Number(order.total_price).toLocaleString('id-ID')}` : <span className="text-xs text-gray-400 font-normal italic">Menunggu Survei</span>}
                            </td>
                            <td className="p-4">
                              {order.status === 'pending' ? (
                                <span className="bg-yellow-50 text-yellow-700 border border-yellow-200 px-2.5 py-1 rounded-full text-xs font-bold uppercase tracking-wider">Menunggu</span>
                              ) : order.status === 'accepted' ? (
                                <span className="bg-blue-50 text-blue-700 border border-blue-200 px-2.5 py-1 rounded-full text-xs font-bold uppercase tracking-wider">Pengerjaan</span>
                              ) : order.status === 'completed' ? (
                                <span className="bg-green-50 text-green-700 border border-green-200 px-2.5 py-1 rounded-full text-xs font-bold uppercase tracking-wider">Selesai</span>
                              ) : (
                                <span className="bg-red-50 text-red-700 border border-red-200 px-2.5 py-1 rounded-full text-xs font-bold uppercase tracking-wider">Batal</span>
                              )}
                            </td>
                            <td className="p-4">
                              {order.review ? (
                                <div>
                                  <div className="flex items-center gap-0.5">
                                    {[...Array(5)].map((_, i) => (
                                      <Star key={i} className={`w-3.5 h-3.5 ${i < order.review.rating ? 'text-yellow-400 fill-yellow-400' : 'text-gray-200'}`} />
                                    ))}
                                  </div>
                                  <p className="text-xs text-gray-500 italic mt-1 max-w-[150px] truncate" title={order.review.comment}>"{order.review.comment}"</p>
                                </div>
                              ) : (
                                <span className="text-xs text-gray-400 italic">Belum ada ulasan</span>
                              )}
                            </td>
                          </tr>
                        ))
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
