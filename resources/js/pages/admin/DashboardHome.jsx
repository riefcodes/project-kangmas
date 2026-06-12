import React, { useState, useEffect } from 'react';
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Users, Briefcase, CheckCircle, AlertCircle, Star, TrendingUp, Clock, Shield } from 'lucide-react';
import api from '../../services/api';

function DashboardHome({ onNavigateTo }) {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboardStats();
  }, []);

  const fetchDashboardStats = async () => {
    try {
      setLoading(true);
      const res = await api.get('/admin/dashboard');
      setStats(res.data.data);
    } catch (error) {
      console.error('Error fetching dashboard stats:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600 font-semibold">Memuat dashboard...</p>
        </div>
      </div>
    );
  }

  if (!stats) {
    return (
      <div className="p-6 bg-red-50 border border-red-200 rounded-lg text-red-700">
        Gagal memuat data dashboard
      </div>
    );
  }

  const orderData = [
    { name: 'Selesai', value: stats.orders.completed, fill: '#10b981' },
    { name: 'Diterima', value: stats.orders.accepted, fill: '#3b82f6' },
    { name: 'Pending', value: stats.orders.pending, fill: '#f59e0b' },
    { name: 'Dibatalkan', value: stats.orders.cancelled, fill: '#ef4444' },
  ];

  const orderStatusData = [
    { status: 'Selesai', count: stats.orders.completed },
    { status: 'Diterima', count: stats.orders.accepted },
    { status: 'Pending', count: stats.orders.pending },
    { status: 'Dibatalkan', count: stats.orders.cancelled },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 p-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 mb-2">Dashboard Admin KANGMAS</h1>
          <p className="text-gray-600">Kelola dan monitor semua aktivitas platform</p>
        </div>

        {/* Statistics Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          {/* Total Users */}
          <div className="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition border-l-4 border-blue-500">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-gray-500 text-sm font-medium">Total Pengguna</p>
                <p className="text-3xl font-bold text-gray-900 mt-2">{stats.total_users}</p>
              </div>
              <div className="bg-blue-100 p-4 rounded-lg">
                <Users className="w-8 h-8 text-blue-600" />
              </div>
            </div>
          </div>

          {/* Total Tukangs */}
          <div className="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition border-l-4 border-purple-500">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-gray-500 text-sm font-medium">Total Tukang</p>
                <p className="text-3xl font-bold text-gray-900 mt-2">{stats.total_tukangs}</p>
                <p className="text-xs text-green-600 mt-2">✓ {stats.approved_tukangs} Terverifikasi</p>
              </div>
              <div className="bg-purple-100 p-4 rounded-lg">
                <Briefcase className="w-8 h-8 text-purple-600" />
              </div>
            </div>
          </div>

          {/* Total Orders */}
          <div className="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition border-l-4 border-green-500">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-gray-500 text-sm font-medium">Total Pesanan</p>
                <p className="text-3xl font-bold text-gray-900 mt-2">{stats.orders.total}</p>
                <p className="text-xs text-green-600 mt-2">✓ {stats.orders.completed} Selesai</p>
              </div>
              <div className="bg-green-100 p-4 rounded-lg">
                <CheckCircle className="w-8 h-8 text-green-600" />
              </div>
            </div>
          </div>

          {/* Pending Orders */}
          <div className="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition border-l-4 border-orange-500">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-gray-500 text-sm font-medium">Pesanan Pending</p>
                <p className="text-3xl font-bold text-gray-900 mt-2">{stats.orders.pending}</p>
                <p className="text-xs text-orange-600 mt-2">⚠ Perlu Perhatian</p>
              </div>
              <div className="bg-orange-100 p-4 rounded-lg">
                <AlertCircle className="w-8 h-8 text-orange-600" />
              </div>
            </div>
          </div>
        </div>

        {/* Charts Section */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          {/* Order Status Chart */}
          <div className="bg-white rounded-xl shadow-md p-6">
            <h2 className="text-xl font-bold text-gray-900 mb-6">Status Pesanan</h2>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={orderData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, value }) => `${name}: ${value}`}
                  outerRadius={100}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {orderData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.fill} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>

          {/* Order Status Bar Chart */}
          <div className="bg-white rounded-xl shadow-md p-6">
            <h2 className="text-xl font-bold text-gray-900 mb-6">Breakdown Pesanan</h2>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={orderStatusData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="status" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="count" fill="#3b82f6" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Top Rated Tukangs, Top Users, & Recent Orders */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Top Rated Tukangs */}
          <div className="bg-white rounded-xl shadow-md p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-bold text-gray-900">Tukang Terbaik (Top Rating)</h2>
              <Star className="w-5 h-5 text-yellow-500" />
            </div>
            <div className="space-y-4">
              {stats.top_rated_tukangs && stats.top_rated_tukangs.length > 0 ? (
                stats.top_rated_tukangs.map((tukang, index) => (
                  <div key={tukang.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition">
                    <div className="flex items-center gap-4 flex-1">
                      <div className="flex items-center justify-center w-10 h-10 bg-gradient-to-br from-yellow-400 to-yellow-600 text-white rounded-full font-bold text-sm">
                        #{index + 1}
                      </div>
                      <div>
                        <p className="font-semibold text-gray-900">{tukang.name}</p>
                        <p className="text-xs text-gray-500">{tukang.category}</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="flex items-center gap-1 justify-end">
                        <Star className="w-4 h-4 text-yellow-500 fill-current" />
                        <span className="font-bold text-gray-900">{tukang.rating}</span>
                      </div>
                      <p className="text-xs text-gray-500">{tukang.total_orders} pesanan</p>
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-gray-500 text-center py-8">Belum ada data tukang</p>
              )}
            </div>
            <button
              onClick={() => onNavigateTo('analytics')}
              className="w-full mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-semibold"
            >
              Lihat Semua Analitik
            </button>
          </div>

          {/* Top Users Ranking */}
          <div className="bg-white rounded-xl shadow-md p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-bold text-gray-900">Ranking Pengguna Terbaik</h2>
              <Users className="w-5 h-5 text-blue-500" />
            </div>
            <div className="space-y-4">
              {stats.top_users && stats.top_users.length > 0 ? (
                stats.top_users.map((user, index) => (
                  <div key={user.id} className="p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition">
                    <div className="flex items-center justify-between gap-4">
                      <div className="flex items-center gap-3">
                        <div className="flex items-center justify-center w-10 h-10 bg-gradient-to-br from-blue-400 to-sky-600 text-white rounded-full font-bold text-sm">
                          #{index + 1}
                        </div>
                        <div>
                          <p className="font-semibold text-gray-900">{user.name}</p>
                          <p className="text-xs text-gray-500">{user.completed_orders} pesanan selesai</p>
                        </div>
                      </div>
                      <div className="text-right">
                        <p className="text-sm font-semibold text-gray-900">{user.total_orders} total</p>
                        <p className="text-xs text-gray-500">Rp {Number(user.total_spent).toLocaleString('id-ID')}</p>
                      </div>
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-gray-500 text-center py-8">Belum ada data pengguna</p>
              )}
            </div>
            <button
              onClick={() => onNavigateTo('analytics')}
              className="w-full mt-4 px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition font-semibold"
            >
              Lihat Semua Analitik
            </button>
          </div>

          {/* Recent Orders */}
          <div className="bg-white rounded-xl shadow-md p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-bold text-gray-900">Pesanan Terbaru</h2>
              <Clock className="w-5 h-5 text-blue-500" />
            </div>
            <div className="space-y-3">
              {stats.recent_orders && stats.recent_orders.length > 0 ? (
                stats.recent_orders.map((order) => (
                  <div key={order.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg hover:bg-gray-100 transition border-l-4 border-blue-400">
                    <div className="flex-1">
                      <p className="font-semibold text-gray-900 text-sm">{order.user_name}</p>
                      <p className="text-xs text-gray-500">untuk {order.tukang_name}</p>
                      <p className="text-xs text-gray-400 mt-1">{order.created_at}</p>
                    </div>
                    <div className="text-right">
                      <span className={`px-3 py-1 rounded-full text-xs font-semibold ${
                        order.status === 'completed' ? 'bg-green-100 text-green-800' :
                        order.status === 'accepted' ? 'bg-blue-100 text-blue-800' :
                        order.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-red-100 text-red-800'
                      }`}>
                        {order.status === 'completed' ? 'Selesai' :
                         order.status === 'accepted' ? 'Diterima' :
                         order.status === 'pending' ? 'Pending' :
                         'Dibatalkan'}
                      </span>
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-gray-500 text-center py-8">Belum ada pesanan</p>
              )}
            </div>
            <button
              onClick={() => onNavigateTo('orders')}
              className="w-full mt-4 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-semibold"
            >
              Lihat Semua Pesanan
            </button>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="mt-8 bg-gradient-to-r from-blue-600 to-purple-600 rounded-xl shadow-lg p-8 text-white">
          <h3 className="text-2xl font-bold mb-6">Aksi Cepat</h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <button
              onClick={() => onNavigateTo('verification')}
              className="bg-white bg-opacity-20 hover:bg-opacity-30 backdrop-blur-lg px-6 py-3 rounded-lg font-semibold transition flex items-center justify-center gap-2"
            >
              <Shield className="w-5 h-5" />
              Verifikasi Tukang
            </button>
            <button
              onClick={() => onNavigateTo('manage')}
              className="bg-white bg-opacity-20 hover:bg-opacity-30 backdrop-blur-lg px-6 py-3 rounded-lg font-semibold transition flex items-center justify-center gap-2"
            >
              <Users className="w-5 h-5" />
              Kelola Tukang
            </button>
            <button
              onClick={() => onNavigateTo('analytics')}
              className="bg-white bg-opacity-20 hover:bg-opacity-30 backdrop-blur-lg px-6 py-3 rounded-lg font-semibold transition flex items-center justify-center gap-2"
            >
              <TrendingUp className="w-5 h-5" />
              Lihat Analitik
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

export default DashboardHome;
