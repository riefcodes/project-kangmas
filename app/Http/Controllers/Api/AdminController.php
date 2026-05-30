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
     * Dashboard statistics.
     */
    public function dashboard(): JsonResponse
    {
        $stats = [
            'total_users'   => User::where('role', 'user')->count(),
            'total_tukangs' => User::where('role', 'tukang')->count(),
            'orders' => [
                'pending'   => Order::where('status', 'pending')->count(),
                'accepted'  => Order::where('status', 'accepted')->count(),
                'completed' => Order::where('status', 'completed')->count(),
                'cancelled' => Order::where('status', 'cancelled')->count(),
                'total'     => Order::count(),
            ],
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
 }
