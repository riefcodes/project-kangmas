<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    /**
     * Dashboard statistics with top-rated tukangs.
     */
    public function dashboard(): JsonResponse
    {
        $totalUsers = User::where('role', 'user')->count();
        $totalTukangs = User::where('role', 'tukang')->count();
        $approvedTukangs = User::where('role', 'tukang')
            ->whereHas('tukangProfile', function ($q) {
                $q->where('status', 'approved');
            })->count();

        $orderStats = [
            'pending'   => Order::where('status', 'pending')->count(),
            'accepted'  => Order::where('status', 'accepted')->count(),
            'completed' => Order::where('status', 'completed')->count(),
            'cancelled' => Order::where('status', 'cancelled')->count(),
            'total'     => Order::count(),
        ];

        // Get top-rated tukangs
        $topTukangs = User::where('role', 'tukang')
            ->whereHas('tukangProfile', function ($query) {
                $query->where('status', 'approved');
            })
            ->with('tukangProfile')
            ->withCount('tukangOrders')
            ->withAvg('tukangReviews as rating_avg', 'rating')
            ->get()
            ->map(function ($user) {
                return [
                    'id' => $user->id,
                    'name' => $user->name,
                    'category' => $user->tukangProfile?->category ?? '-',
                    'rating' => $user->rating_avg ? round($user->rating_avg, 1) : 0,
                    'total_orders' => $user->tukang_orders_count ?? 0,
                ];
            })
            ->sortByDesc('rating')
            ->take(5)
            ->values();

        // Count tukangs pending verification
        $pendingTukangs = User::where('role', 'tukang')
            ->whereHas('tukangProfile', function ($q) {
                $q->where('status', 'pending');
            })->count();

        // Get tukang category distribution
        $categoryDistribution = User::where('role', 'tukang')
            ->whereHas('tukangProfile', function ($q) {
                $q->where('status', 'approved');
            })
            ->with('tukangProfile:id,user_id,category')
            ->get()
            ->groupBy(fn ($user) => $user->tukangProfile?->category ?? 'Lainnya')
            ->map(fn ($group, $category) => [
                'category' => $category,
                'count' => $group->count(),
            ])
            ->values();

        // Get recent orders
        $recentOrders = Order::with([
            'user:id,name,phone_number',
            'tukang:id,name',
        ])
            ->latest()
            ->take(5)
            ->get()
            ->map(function ($order) {
                return [
                    'id' => $order->id,
                    'user_name' => $order->user?->name ?? '-',
                    'tukang_name' => $order->tukang?->name ?? '-',
                    'category' => $order->category ?? '-',
                    'status' => $order->status,
                    'created_at' => $order->created_at->format('Y-m-d H:i'),
                ];
            });

        $stats = [
            'total_users' => $totalUsers,
            'total_tukangs' => $totalTukangs,
            'approved_tukangs' => $approvedTukangs,
            'pending_tukangs' => $pendingTukangs,
            'orders' => $orderStats,
            'top_rated_tukangs' => $topTukangs,
            'recent_orders' => $recentOrders,
            'category_distribution' => $categoryDistribution,
        ];

        return response()->json([
            'success' => true,
            'message' => 'Dashboard statistics',
            'data'    => $stats,
        ]);
    }

    /**
     * List all users (paginated, filterable by role).
     */
    public function users(Request $request): JsonResponse
    {
        $query = User::with('tukangProfile')->latest();

        if ($request->has('role') && in_array($request->query('role'), ['admin', 'user', 'tukang'])) {
            $query->where('role', $request->query('role'));
        }

        $users = $query->paginate($request->query('per_page', 100));

        return response()->json([
            'success' => true,
            'message' => 'List of users',
            'data'    => $users,
        ]);
    }

    /**
     * List all orders (paginated, filterable by status).
     */
    public function orders(Request $request): JsonResponse
    {
        $query = Order::with([
            'user:id,name,phone_number',
            'tukang:id,name,phone_number',
            'review',
        ])->latest();

        if ($request->has('status') && in_array($request->query('status'), ['pending', 'accepted', 'completed', 'cancelled'])) {
            $query->where('status', $request->query('status'));
        }

        $orders = $query->paginate($request->query('per_page', 100));

         return response()->json([
             'success' => true,
             'message' => 'List of orders',
             'data'    => $orders,
         ]);
     }

     /**
      * Get analytics for all tukangs.
      */
     public function tukangAnalytics(Request $request): JsonResponse
     {
         $tukangs = User::where('role', 'tukang')
             ->whereHas('tukangProfile', function ($query) {
                 $query->where('status', 'approved');
             })
             ->with('tukangProfile')
             ->withCount([
                 'tukangOrders as total_orders_count',
                 'tukangOrders as completed_orders_count' => function ($query) {
                     $query->where('status', 'completed');
                 }
             ])
             ->withAvg('tukangReviews as rating_avg', 'rating')
             ->get()
             ->map(function ($user) {
                 $uniqueCustomers = Order::where('tukang_id', $user->id)
                     ->distinct()
                     ->count('user_id');

                 return [
                     'id' => $user->id,
                     'name' => $user->name,
                     'email' => $user->email,
                     'phone_number' => $user->phone_number,
                     'skill' => $user->tukangProfile?->category ?? '-',
                     'location' => $user->tukangProfile?->address ?? '-',
                     'status' => $user->tukangProfile?->status ?? 'Inactive',
                     'is_blacklisted' => $user->tukangProfile?->is_blacklisted ?? false,
                     'total_orders' => $user->total_orders_count,
                     'completed_orders' => $user->completed_orders_count,
                     'rating' => $user->rating_avg ? round($user->rating_avg, 1) : null,
                     'unique_customers' => $uniqueCustomers,
                 ];
             });

         return response()->json([
             'success' => true,
             'message' => 'Tukang analytics retrieved successfully',
             'data'    => $tukangs,
         ]);
     }

    /**
     * Verifikasi Tukang (Approve/Reject).
     */
    public function verifyTukang(Request $request, $id): JsonResponse
    {
        $request->validate([
            'status' => 'required|in:approved,rejected',
        ]);

        $user = User::where('id', $id)->where('role', 'tukang')->firstOrFail();
        $profile = $user->tukangProfile;

        if (!$profile) {
            return response()->json([
                'success' => false,
                'message' => 'Profil Tukang tidak ditemukan',
            ], 404);
        }

        $profile->status = $request->status;
        $profile->save();

        return response()->json([
            'success' => true,
            'message' => "Tukang berhasil di-{$request->status}",
            'data'    => $profile,
        ]);
    }

    /**
     * Toggle Blacklist Tukang.
     */
    public function toggleBlacklist(Request $request, $id): JsonResponse
    {
        $user = User::where('id', $id)->where('role', 'tukang')->firstOrFail();
        $profile = $user->tukangProfile;

        if (!$profile) {
            return response()->json([
                'success' => false,
                'message' => 'Profil Tukang tidak ditemukan',
            ], 404);
        }

        $profile->is_blacklisted = !$profile->is_blacklisted;
        $profile->save();

        $status = $profile->is_blacklisted ? 'diblokir' : 'dibuka blokirnya';

        return response()->json([
            'success' => true,
            'message' => "Tukang berhasil {$status}",
            'data'    => $profile,
        ]);
    }
 }
