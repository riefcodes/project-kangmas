<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    /**
     * List orders for the authenticated user.
     *
     * - Users see their own orders.
     * - Tukangs see orders assigned to them.
     * - Admins see all orders.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = Order::with(['user:id,name,phone_number', 'tukang:id,name,phone_number'])
            ->latest();

        if ($user->role === 'user') {
            $query->where('user_id', $user->id);
        } elseif ($user->role === 'tukang') {
            $query->where('tukang_id', $user->id);
        }
        // admin → no filter, sees all

        $orders = $query->get();

        return response()->json([
            'success' => true,
            'message' => 'List of orders',
            'data'    => $orders,
        ]);
    }

    /**
     * Create a new order (user role only).
     */
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->role !== 'user') {
            return response()->json([
                'success' => false,
                'message' => 'Only users can create orders',
                'data'    => null,
            ], 403);
        }

        $validated = $request->validate([
            'tukang_id'   => 'required|exists:users,id',
            'description' => 'required|string|max:1000',
            'image_path'  => 'nullable|string|max:255',
        ]);

        $order = Order::create([
            'user_id'     => $user->id,
            'tukang_id'   => $validated['tukang_id'],
            'description' => $validated['description'],
            'image_path'  => $validated['image_path'] ?? null,
            'status'      => 'pending',
        ]);

        $order->load(['user:id,name,phone_number', 'tukang:id,name,phone_number']);

        return response()->json([
            'success' => true,
            'message' => 'Order created successfully',
            'data'    => $order,
        ], 201);
    }

    /**
     * Show a single order (owner or assigned tukang only).
     */
    public function show(Request $request, string $id): JsonResponse
    {
        $user  = $request->user();
        $order = Order::with(['user:id,name,phone_number', 'tukang:id,name,phone_number', 'review'])
            ->find($id);

        if (! $order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found',
                'data'    => null,
            ], 404);
        }

        // Authorization: owner, assigned tukang, or admin
        if ($user->role !== 'admin' && $order->user_id !== $user->id && $order->tukang_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
                'data'    => null,
            ], 403);
        }

        return response()->json([
            'success' => true,
            'message' => 'Order details',
            'data'    => $order,
        ]);
    }

    /**
     * Update order status.
     *
     * - Tukang can: accepted, completed (+ total_price).
     * - User can: cancelled.
     */
    public function update(Request $request, string $id): JsonResponse{
        $user  = $request->user();
        $order = Order::find($id);

        if (! $order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found',
                'data'    => null,
            ], 404);
        }

        return DB::transaction(function () use ($request, $user, $order) {

            // ── Tukang update ──────────────────────────────
            if ($user->role === 'tukang' && $order->tukang_id === $user->id) {

                $validated = $request->validate([
                    'status'      => 'required|in:accepted,completed',
                    'total_price' => 'required_if:status,completed|integer|min:0',
                ]);

                // pending → accepted only
                if ($validated['status'] === 'accepted' && $order->status !== 'pending') {
                    return response()->json([
                        'success' => false,
                        'message' => 'Only pending orders can be accepted',
                        'data'    => null,
                    ], 422);
                }

                // accepted → completed only
                if ($validated['status'] === 'completed' && $order->status !== 'accepted') {
                    return response()->json([
                        'success' => false,
                        'message' => 'Only accepted orders can be completed',
                        'data'    => null,
                    ], 422);
                }

                $order->status = $validated['status'];

                if ($validated['status'] === 'completed') {
                    $order->total_price = $validated['total_price'];
                }
            
                $order->save();

                return response()->json([
                    'success' => true,
                    'message' => 'Order updated successfully',
                    'data'    => $order->load([
                        'user:id,name,phone_number',
                        'tukang:id,name,phone_number'
                    ]),
                ], 200);
            }

            // ── User cancellation ──────────────────────────────
            if ($user->role === 'user' && $order->user_id === $user->id) {

                if ($order->status !== 'pending') {
                    return response()->json([
                        'success' => false,
                        'message' => 'Only pending orders can be cancelled',
                        'data'    => null,
                    ], 422);
                }

                $order->status = 'cancelled';
                $order->save();

                return response()->json([
                    'success' => true,
                    'message' => 'Order cancelled',
                    'data'    => $order->load([
                        'user:id,name,phone_number',
                        'tukang:id,name,phone_number'
                    ]),
                ], 200);
            }

            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
                'data'    => null,
            ], 403);
        });
    }

    /**
     * Delete an order (user only, pending status only).
     */
    public function destroy(Request $request, string $id): JsonResponse
    {
        $user  = $request->user();
        $order = Order::find($id);

        if (! $order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found',
                'data'    => null,
            ], 404);
        }

        if ($user->role !== 'user' || $order->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
                'data'    => null,
            ], 403);
        }

        if ($order->status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Only pending orders can be deleted',
                'data'    => null,
            ], 422);
        }

        $order->delete();

        return response()->json([
            'success' => true,
            'message' => 'Order deleted',
            'data'    => null,
        ]);
    }
}
