<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        $query = Order::with(['user:id,name,phone_number', 'tukang:id,name,phone_number'])
            ->latest();

        if ($user->role === 'user') {
            $query->where('user_id', $user->id);
        } elseif ($user->role === 'tukang') {
            // Tukang melihat pesanan miliknya ATAU pesanan yang belum ada tukangnya (tersedia)
            $query->where(function($q) use ($user) {
                $q->where('tukang_id', $user->id)
                  ->orWhereNull('tukang_id');
            });
        }

        $orders = $query->get();

        return response()->json([
            'success' => true,
            'message' => 'List of orders',
            'data'    => $orders,
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json(['success' => false, 'message' => 'Silakan login kembali'], 401);
            }

            // Ambil harga dan pastikan menjadi angka
            $rawPrice = $request->price ?? '0';
            $cleanPrice = (int) preg_replace('/[^0-9]/', '', (string)$rawPrice);

            // Simpan menggunakan query builder agar lebih aman dan cepat
            $order = new Order();
            $order->user_id = $user->id;
            $order->tukang_id = $request->tukang_id ?? null;
            // Pastikan category tidak null sebelum simpan
            $order->category = $request->category ?: 'Lainnya';
            $order->description = $request->description ?: '-';
            $order->address = $request->address ?: '-';
            $order->job_date = $request->job_date;
            $order->job_time = $request->job_time;
            $order->total_price = $cleanPrice > 0 ? $cleanPrice : 0;
            $order->status = 'pending';

            $order->save();

            return response()->json([
                'success' => true,
                'message' => 'Pesanan berhasil dibuat',
                'data'    => $order
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal Simpan Database: ' . $e->getMessage(),
            ], 500);
        }
    }

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

    public function update(Request $request, string $id): JsonResponse
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

        if ($user->role === 'tukang' && $order->tukang_id === $user->id) {
            $validated = $request->validate([
                'status'      => 'required|in:accepted,completed',
                'total_price' => 'nullable|integer|min:0',
            ]);

            if ($validated['status'] === 'accepted' && $order->status !== 'pending') {
                return response()->json([
                    'success' => false,
                    'message' => 'Only pending orders can be accepted',
                    'data'    => null,
                ], 422);
            }

            if ($validated['status'] === 'completed' && $order->status !== 'accepted') {
                return response()->json([
                    'success' => false,
                    'message' => 'Only accepted orders can be completed',
                    'data'    => null,
                ], 422);
            }

            $order->status = $validated['status'];
            if (isset($validated['total_price'])) {
                $order->total_price = $validated['total_price'];
            }
            $order->save();

            return response()->json([
                'success' => true,
                'message' => 'Order updated successfully',
                'data'    => $order->load(['user:id,name,phone_number', 'tukang:id,name,phone_number']),
            ]);
        }

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
                'data'    => $order->load(['user:id,name,phone_number', 'tukang:id,name,phone_number']),
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Unauthorized',
            'data'    => null,
        ], 403);
    }

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
