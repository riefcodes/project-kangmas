import React, { useState, useEffect } from 'react';
import api from '../../services/api';

// Modal untuk menampilkan dokumen tukang
function DocumentModal({ tukang, onClose }) {
  if (!tukang) return null;

  const docs = [
    { label: 'Foto KTP', url: tukang.ktp_url },
    { label: 'Selfie dengan KTP', url: tukang.selfie_url },
    { label: 'Portofolio', url: tukang.portofolio_url },
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
        {/* Header modal */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <div>
            <h2 className="text-xl font-bold text-gray-800">Dokumen Pendaftar</h2>
            <p className="text-sm text-gray-500 mt-1">
              {tukang.nama || tukang.name} &bull; {tukang.skill} &bull; {tukang.phone}
            </p>
          </div>
          <button
            onClick={onClose}
            className="w-9 h-9 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200 text-gray-600 text-xl font-bold transition"
          >
            &times;
          </button>
        </div>

        {/* Isi dokumen */}
        <div className="p-6 grid gap-6">
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
                      📄 Buka PDF {doc.label}
                    </a>
                  ) : (
                    <a href={doc.url} target="_blank" rel="noopener noreferrer">
                      <img
                        src={doc.url}
                        alt={doc.label}
                        className="max-h-64 max-w-full rounded-lg object-contain shadow border border-gray-200 hover:opacity-90 transition"
                      />
                    </a>
                  )
                ) : (
                  <div className="text-center text-gray-400 py-8">
                    <div className="text-4xl mb-2">📂</div>
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

export default function AdminDashboard() {
  const [activeTab, setActiveTab] = useState('verification');
  const [pendingTukangs, setPendingTukangs] = useState([]);
  const [allTukangs, setAllTukangs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedTukang, setSelectedTukang] = useState(null); // untuk modal dokumen

  useEffect(() => {
    fetchData();
  }, [activeTab]);

  const fetchData = async () => {
    setLoading(true);
    try {
      if (activeTab === 'verification') {
        const res = await api.get('/admin/tukang/pending');
        setPendingTukangs(res.data.data);
      } else {
        const res = await api.get('/admin/users?role=tukang');
        const users = res.data.data.data || res.data.data;
        const formatted = users.map(u => ({
          id: u.tukang_profile?.id || u.id,
          name: u.name,
          status: u.tukang_profile?.status || 'Active',
          isBlacklisted: u.tukang_profile?.is_blacklisted || false
        }));
        setAllTukangs(formatted);
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
    <div className="min-h-screen bg-gray-100 flex pb-10">
      {/* Modal Dokumen */}
      {selectedTukang && (
        <DocumentModal tukang={selectedTukang} onClose={() => setSelectedTukang(null)} />
      )}

      {/* Sidebar */}
      <div className="w-64 bg-slate-900 text-white p-6">
        <h2 className="text-2xl font-bold mb-8 text-primary">Admin Panel</h2>
        <nav className="space-y-4">
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
        </nav>
      </div>

      {/* Main Content */}
      <div className="flex-1 p-10">
        <div className="flex justify-between items-center mb-10">
          <h1 className="text-3xl font-bold text-gray-800">
            {activeTab === 'verification' ? 'Verifikasi Pendaftaran Tukang WEB' : 'Manajemen & Blacklist Tukang'}
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
                        <td className="p-4">{t.skill}</td>
                        <td className="p-4 text-gray-600">{t.phone}</td>
                        <td className="p-4">
                          <button
                            onClick={() => setSelectedTukang(t)}
                            className="inline-flex items-center gap-1 bg-blue-50 border border-blue-200 text-blue-700 px-3 py-1.5 rounded-lg text-sm font-semibold hover:bg-blue-100 transition"
                          >
                            🪪 Lihat Dokumen
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
                      <th className="p-4 font-semibold text-gray-600">Status</th>
                      <th className="p-4 font-semibold text-gray-600">Manajemen Aksi</th>
                    </tr>
                  </thead>
                  <tbody>
                    {allTukangs.length === 0 ? (
                      <tr><td colSpan="4" className="p-4 text-center text-gray-500">Belum ada tukang terverifikasi.</td></tr>
                    ) : allTukangs.map(t => (
                      <tr key={t.id} className="border-b border-gray-100">
                        <td className="p-4">#{t.id}</td>
                        <td className="p-4 font-medium">{t.nama || t.name}</td>
                        <td className="p-4">
                          {t.isBlacklisted || t.status === 'Blacklisted' ? (
                            <span className="bg-red-100 text-red-700 px-2 py-1 rounded text-xs font-bold">Blacklisted</span>
                          ) : (
                            <span className="bg-green-100 text-green-700 px-2 py-1 rounded text-xs font-bold">Active</span>
                          )}
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
          </>
        )}
      </div>
    </div>
  );
}
