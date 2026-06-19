import React, { useState, useEffect } from 'react';
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer, BarChart, Bar, XAxis, YAxis, CartesianGrid } from 'recharts';
import { Users, Briefcase, CheckCircle, AlertCircle, Star, Clock, ShieldAlert } from 'lucide-react';
import api from '../../services/api';

/* ───────── Color Palette ───────── */
const COLORS = {
  emerald: '#10b981',
  blue:    '#3b82f6',
  amber:   '#f59e0b',
  rose:    '#ef4444',
  violet:  '#8b5cf6',
  cyan:    '#06b6d4',
  pink:    '#ec4899',
  indigo:  '#6366f1',
  teal:    '#14b8a6',
  orange:  '#f97316',
};

const PIE_COLORS = [COLORS.emerald, COLORS.blue, COLORS.amber, COLORS.rose];
const CATEGORY_COLORS = [
  COLORS.blue, COLORS.violet, COLORS.cyan, COLORS.pink,
  COLORS.indigo, COLORS.teal, COLORS.orange, COLORS.emerald,
];

/* ───────── Custom Tooltip Components ───────── */
function OrderPieTooltip({ active, payload }) {
  if (!active || !payload?.length) return null;
  const { name, value, fill } = payload[0];
  return (
    <div className="bg-white/95 backdrop-blur-sm rounded-lg shadow-lg border border-gray-200/60 px-4 py-3">
      <div className="flex items-center gap-2 mb-1">
        <span className="w-2.5 h-2.5 rounded-full inline-block" style={{ backgroundColor: fill }} />
        <span className="text-sm font-semibold text-gray-800">{name}</span>
      </div>
      <p className="text-lg font-bold text-gray-900">{value} pesanan</p>
    </div>
  );
}

function CategoryBarTooltip({ active, payload }) {
  if (!active || !payload?.length) return null;
  return (
    <div className="bg-white/95 backdrop-blur-sm rounded-lg shadow-lg border border-gray-200/60 px-4 py-3">
      <p className="text-sm font-semibold text-gray-800">{payload[0].payload.category}</p>
      <p className="text-lg font-bold text-gray-900">{payload[0].value} tukang</p>
    </div>
  );
}

/* ───────── Pie Chart Label ───────── */
function renderPieLabel({ name, value, percent }) {
  return `${name}: ${value} (${(percent * 100).toFixed(0)}%)`;
}

/* ───────── Main Component ───────── */
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

  /* ── Loading State ── */
  if (loading) {
    return (
      <div className="flex justify-center items-center py-32">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-[3px] border-blue-200 border-t-blue-600 mx-auto mb-4" />
          <p className="text-gray-500 font-medium text-sm tracking-wide">Memuat dashboard…</p>
        </div>
      </div>
    );
  }

  /* ── Error State ── */
  if (!stats) {
    return (
      <div className="p-6 bg-red-50 border border-red-200 rounded-xl text-red-700 flex items-center gap-3">
        <AlertCircle className="w-5 h-5 shrink-0" />
        <span className="font-medium">Gagal memuat data dashboard. Silakan muat ulang halaman.</span>
      </div>
    );
  }

  /* ── Chart Data ── */
  const orderData = [
    { name: 'Selesai',    value: stats.orders.completed, fill: PIE_COLORS[0] },
    { name: 'Diterima',   value: stats.orders.accepted,  fill: PIE_COLORS[1] },
    { name: 'Pending',    value: stats.orders.pending,   fill: PIE_COLORS[2] },
    { name: 'Dibatalkan', value: stats.orders.cancelled, fill: PIE_COLORS[3] },
  ];

  const categoryData = (stats.category_distribution || []).map((item, i) => ({
    ...item,
    fill: CATEGORY_COLORS[i % CATEGORY_COLORS.length],
  }));

  /* ── Stat Cards Data ── */
  const statCards = [
    {
      label: 'Total Pengguna',
      value: stats.total_users,
      icon: Users,
      accent: 'blue',
      sub: null,
    },
    {
      label: 'Total Tukang',
      value: stats.total_tukangs,
      icon: Briefcase,
      accent: 'violet',
      sub: `${stats.approved_tukangs} Terverifikasi`,
      subColor: 'text-emerald-600',
    },
    {
      label: 'Total Pesanan',
      value: stats.orders.total,
      icon: CheckCircle,
      accent: 'emerald',
      sub: `${stats.orders.completed} Selesai`,
      subColor: 'text-emerald-600',
    },
    {
      label: 'Pesanan Pending',
      value: stats.orders.pending,
      icon: AlertCircle,
      accent: 'amber',
      sub: 'Perlu Perhatian',
      subColor: 'text-amber-600',
    },
  ];

  const accentMap = {
    blue:    { border: 'border-blue-500',    bg: 'bg-blue-50',    icon: 'text-blue-600' },
    violet:  { border: 'border-violet-500',  bg: 'bg-violet-50',  icon: 'text-violet-600' },
    emerald: { border: 'border-emerald-500', bg: 'bg-emerald-50', icon: 'text-emerald-600' },
    amber:   { border: 'border-amber-500',   bg: 'bg-amber-50',   icon: 'text-amber-600' },
  };

  return (
    <div className="space-y-6">
      {/* ─── Pending Verification Alert ─── */}
      {stats.pending_tukangs > 0 && (
        <button
          onClick={() => onNavigateTo('verification')}
          className="w-full flex items-center gap-4 px-5 py-4 bg-amber-50 border border-amber-200 rounded-xl hover:bg-amber-100 transition-colors group text-left"
        >
          <div className="flex items-center justify-center w-10 h-10 rounded-lg bg-amber-100 group-hover:bg-amber-200 transition-colors">
            <ShieldAlert className="w-5 h-5 text-amber-600" />
          </div>
          <div className="flex-1">
            <p className="text-sm font-bold text-amber-800">
              {stats.pending_tukangs} Tukang Menunggu Verifikasi
            </p>
            <p className="text-xs text-amber-600 mt-0.5">
              Klik untuk meninjau dan memverifikasi pendaftaran tukang baru
            </p>
          </div>
          <span className="text-amber-400 group-hover:text-amber-600 transition-colors text-lg">→</span>
        </button>
      )}

      {/* ─── Statistics Cards ─── */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
        {statCards.map((card) => {
          const a = accentMap[card.accent];
          const Icon = card.icon;
          return (
            <div
              key={card.label}
              className={`bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow p-5 border-l-4 ${a.border}`}
            >
              <div className="flex items-start justify-between">
                <div className="space-y-1">
                  <p className="text-gray-500 text-xs font-semibold uppercase tracking-wider">{card.label}</p>
                  <p className="text-3xl font-extrabold text-gray-900 tracking-tight">{card.value}</p>
                  {card.sub && (
                    <p className={`text-xs font-medium ${card.subColor || 'text-gray-500'} mt-1`}>
                      {card.accent === 'emerald' || card.accent === 'violet' ? '✓ ' : '⚠ '}{card.sub}
                    </p>
                  )}
                </div>
                <div className={`${a.bg} p-3 rounded-xl`}>
                  <Icon className={`w-6 h-6 ${a.icon}`} />
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* ─── Charts Row ─── */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        {/* Pie Chart — Status Pesanan */}
        <div className="bg-white rounded-xl shadow-sm p-6">
          <h2 className="text-base font-bold text-gray-900 mb-5">Distribusi Status Pesanan</h2>
          <ResponsiveContainer width="100%" height={280}>
            <PieChart>
              <Pie
                data={orderData}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={renderPieLabel}
                outerRadius={100}
                innerRadius={45}
                fill="#8884d8"
                dataKey="value"
                strokeWidth={2}
                stroke="#fff"
              >
                {orderData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.fill} />
                ))}
              </Pie>
              <Tooltip content={<OrderPieTooltip />} />
            </PieChart>
          </ResponsiveContainer>
          {/* Legend */}
          <div className="flex flex-wrap justify-center gap-x-5 gap-y-2 mt-3">
            {orderData.map((item) => (
              <div key={item.name} className="flex items-center gap-1.5 text-xs text-gray-600">
                <span className="w-2.5 h-2.5 rounded-full inline-block" style={{ backgroundColor: item.fill }} />
                {item.name}
              </div>
            ))}
          </div>
        </div>

        {/* Bar Chart — Distribusi Kategori Tukang */}
        <div className="bg-white rounded-xl shadow-sm p-6">
          <h2 className="text-base font-bold text-gray-900 mb-5">Distribusi Kategori Tukang</h2>
          {categoryData.length > 0 ? (
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={categoryData} layout="vertical" margin={{ left: 10, right: 20 }}>
                <CartesianGrid strokeDasharray="3 3" horizontal={false} stroke="#f1f5f9" />
                <XAxis type="number" tick={{ fontSize: 12, fill: '#94a3b8' }} axisLine={false} tickLine={false} />
                <YAxis
                  type="category"
                  dataKey="category"
                  tick={{ fontSize: 12, fill: '#475569', fontWeight: 500 }}
                  width={110}
                  axisLine={false}
                  tickLine={false}
                />
                <Tooltip content={<CategoryBarTooltip />} cursor={{ fill: '#f8fafc' }} />
                <Bar dataKey="count" radius={[0, 6, 6, 0]} barSize={22}>
                  {categoryData.map((entry, index) => (
                    <Cell key={`cat-${index}`} fill={entry.fill} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="flex flex-col items-center justify-center h-[280px] text-gray-400">
              <Briefcase className="w-10 h-10 mb-2 text-gray-300" />
              <p className="text-sm font-medium">Belum ada data kategori tukang</p>
            </div>
          )}
        </div>
      </div>

      {/* ─── Bottom Row: Top Tukangs + Recent Orders ─── */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
        {/* Top Rated Tukangs */}
        <div className="bg-white rounded-xl shadow-sm p-6">
          <div className="flex items-center justify-between mb-5">
            <h2 className="text-base font-bold text-gray-900">Tukang Rating Tertinggi</h2>
            <Star className="w-4 h-4 text-amber-500" />
          </div>
          <div className="space-y-3">
            {stats.top_rated_tukangs && stats.top_rated_tukangs.length > 0 ? (
              stats.top_rated_tukangs.map((tukang, index) => (
                <div
                  key={tukang.id}
                  className="flex items-center justify-between p-3.5 bg-gray-50/80 rounded-lg hover:bg-gray-100/80 transition-colors"
                >
                  <div className="flex items-center gap-3 flex-1 min-w-0">
                    <div className={`flex items-center justify-center w-8 h-8 rounded-lg text-white font-bold text-xs shrink-0 ${
                      index === 0 ? 'bg-gradient-to-br from-amber-400 to-amber-600' :
                      index === 1 ? 'bg-gradient-to-br from-gray-300 to-gray-500' :
                      index === 2 ? 'bg-gradient-to-br from-orange-300 to-orange-500' :
                      'bg-gray-300'
                    }`}>
                      #{index + 1}
                    </div>
                    <div className="min-w-0">
                      <p className="font-semibold text-gray-900 text-sm truncate">{tukang.name}</p>
                      <p className="text-xs text-gray-500 truncate">{tukang.category}</p>
                    </div>
                  </div>
                  <div className="text-right shrink-0 ml-3">
                    <div className="flex items-center gap-1 justify-end">
                      <Star className="w-3.5 h-3.5 text-amber-500 fill-amber-500" />
                      <span className="font-bold text-gray-900 text-sm">{tukang.rating}</span>
                    </div>
                    <p className="text-[11px] text-gray-400">{tukang.total_orders} pesanan</p>
                  </div>
                </div>
              ))
            ) : (
              <div className="text-gray-400 text-center py-10">
                <Star className="w-8 h-8 mx-auto mb-2 text-gray-300" />
                <p className="text-sm font-medium">Belum ada data tukang</p>
              </div>
            )}
          </div>
          <button
            onClick={() => onNavigateTo('analytics')}
            className="w-full mt-4 px-4 py-2.5 bg-gray-900 text-white rounded-lg hover:bg-gray-800 transition-colors text-sm font-semibold"
          >
            Lihat Semua Analitik →
          </button>
        </div>

        {/* Recent Orders */}
        <div className="bg-white rounded-xl shadow-sm p-6">
          <div className="flex items-center justify-between mb-5">
            <h2 className="text-base font-bold text-gray-900">Pesanan Terbaru</h2>
            <Clock className="w-4 h-4 text-blue-500" />
          </div>
          <div className="space-y-3">
            {stats.recent_orders && stats.recent_orders.length > 0 ? (
              stats.recent_orders.map((order) => {
                const statusConfig = {
                  completed: { label: 'Selesai',    bg: 'bg-emerald-50', text: 'text-emerald-700', border: 'border-emerald-500' },
                  accepted:  { label: 'Diterima',   bg: 'bg-blue-50',    text: 'text-blue-700',    border: 'border-blue-500' },
                  pending:   { label: 'Pending',    bg: 'bg-amber-50',   text: 'text-amber-700',   border: 'border-amber-500' },
                  cancelled: { label: 'Dibatalkan', bg: 'bg-red-50',     text: 'text-red-700',     border: 'border-red-500' },
                };
                const s = statusConfig[order.status] || statusConfig.pending;

                return (
                  <div
                    key={order.id}
                    className={`flex items-center justify-between p-3.5 bg-gray-50/80 rounded-lg hover:bg-gray-100/80 transition-colors border-l-[3px] ${s.border}`}
                  >
                    <div className="flex-1 min-w-0">
                      <p className="font-semibold text-gray-900 text-sm truncate">{order.user_name}</p>
                      <p className="text-xs text-gray-500 truncate">→ {order.tukang_name}</p>
                      <p className="text-[11px] text-gray-400 mt-0.5">{order.created_at}</p>
                    </div>
                    <span className={`${s.bg} ${s.text} px-2.5 py-1 rounded-full text-[11px] font-semibold shrink-0 ml-3`}>
                      {s.label}
                    </span>
                  </div>
                );
              })
            ) : (
              <div className="text-gray-400 text-center py-10">
                <Clock className="w-8 h-8 mx-auto mb-2 text-gray-300" />
                <p className="text-sm font-medium">Belum ada pesanan</p>
              </div>
            )}
          </div>
          <button
            onClick={() => onNavigateTo('orders')}
            className="w-full mt-4 px-4 py-2.5 bg-gray-900 text-white rounded-lg hover:bg-gray-800 transition-colors text-sm font-semibold"
          >
            Lihat Semua Pesanan →
          </button>
        </div>
      </div>
    </div>
  );
}

export default DashboardHome;
