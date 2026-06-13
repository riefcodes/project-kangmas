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

        $query = Order::with(['user:id,name,phone_number', 'tukang:id,name,phone_number', 'locationImages'])
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

            // Validasi Input
            $request->validate([
                'tukang_id'   => 'nullable|exists:users,id',
                'category'    => 'required|string',
                'description' => 'required|string',
                'address'     => 'required|string',
                'job_date'    => 'nullable|date',
                'job_time'    => 'nullable',
                'price'       => 'nullable',
                'image'       => 'nullable|image|max:20480', // Foto masalah utama
                'location_images'   => 'nullable|array',
                'location_images.*' => 'image|max:20480',
            ]);

            // Ambil harga dan pastikan menjadi angka
            $rawPrice = $request->price ?? '0';
            $cleanPrice = (int) preg_replace('/[^0-9]/', '', (string)$rawPrice);

            // Parsing tanggal agar aman masuk ke database
            $jobDate = null;
            if ($request->job_date) {
                try {
                    // Coba parse format yyyy-MM-dd (standar) atau dd/MM/yy (dari mobile)
                    $jobDate = \Illuminate\Support\Carbon::parse($request->job_date)->format('Y-m-d');
                } catch (\Exception $e) {
                    $jobDate = null;
                }
            }

            $order = new Order();
            $order->user_id = $user->id;
            $order->tukang_id = $request->tukang_id ?? null;
            $order->category = $request->category ?: 'Lainnya';
            $order->description = $request->description ?: '-';
            $order->address = $request->address ?: '-';
            $order->job_date = $jobDate;
            $order->job_time = $request->job_time;
            $order->total_price = $cleanPrice > 0 ? $cleanPrice : 0;
            $order->status = 'pending';

            // Handle Main Problem Image
            if ($request->hasFile('image')) {
                $path = $request->file('image')->store('orders/problems', 'public');
                $order->image_path = $path;
            }

            $order->save();

            // Handle Multiple Location Images
            if ($request->hasFile('location_images')) {
                foreach ($request->file('location_images') as $file) {
                    $path = $file->store('orders/locations', 'public');
                    $order->locationImages()->create(['image_path' => $path]);
                }
            }

            return response()->json([
                'success' => true,
                'message' => 'Pesanan berhasil dibuat',
                'data'    => $order->load('locationImages')
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
        $order = Order::with(['user:id,name,phone_number', 'tukang:id,name,phone_number', 'review', 'locationImages'])
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

        if ($user->role === 'tukang') {
            // Tukang bisa mengupdate jika:
            // 1. Dia adalah tukang yang sudah ditunjuk (untuk complete)
            // 2. Pesanan masih pending dan belum ada tukangnya (untuk accept)
            if ($order->tukang_id !== null && $order->tukang_id !== $user->id) {
                return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
            }

            $validated = $request->validate([
                'status'          => 'required|in:accepted,completed,waiting_approval',
                'total_price'     => 'nullable|integer|min:0',
                'proof_image'     => 'nullable|image|max:20480', // Naikkan ke 20MB
                'location_images'   => 'nullable|array',
                'location_images.*' => 'image|max:20480', // Naikkan ke 20MB
            ]);

            if ($validated['status'] === 'accepted') {
                if ($order->status !== 'pending' || $order->tukang_id !== null) {
                    return response()->json(['success' => false, 'message' => 'Pekerjaan sudah diambil orang lain'], 422);
                }
                $order->tukang_id = $user->id;
            }

            if ($validated['status'] === 'completed' || $validated['status'] === 'waiting_approval') {
                if ($order->status !== 'accepted') {
                    return response()->json(['success' => false, 'message' => 'Hanya pekerjaan aktif yang bisa diselesaikan'], 422);
                }

                // Handle Proof Image Upload
                if ($request->hasFile('proof_image')) {
                    $path = $request->file('proof_image')->store('orders/proofs', 'public');
                    $order->proof_image = $path;
                }

                // Handle Multiple Location Images
                if ($request->hasFile('location_images')) {
                    foreach ($request->file('location_images') as $file) {
                        $path = $file->store('orders/locations', 'public');
                        $order->locationImages()->create(['image_path' => $path]);
                    }
                }
            }

            $order->status = $validated['status'];
            if (isset($validated['total_price'])) {
                $order->total_price = $validated['total_price'];
            }
            $order->save();

            return response()->json([
                'success' => true,
                'message' => 'Status pesanan berhasil diperbarui',
                'data'    => $order->load(['user:id,name,phone_number', 'tukang:id,name,phone_number', 'locationImages']),
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

    public function approve(Request $request, string $id): JsonResponse
    {
        $user = $request->user();
        $order = Order::find($id);

        if (!$order) {
            return response()->json(['success' => false, 'message' => 'Order not found'], 404);
        }

        if ($order->user_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
        }

        if ($order->status !== 'waiting_approval') {
            return response()->json(['success' => false, 'message' => 'Order is not waiting for approval'], 422);
        }

        $order->status = 'completed';
        $order->save();

        return response()->json([
            'success' => true,
            'message' => 'Pekerjaan berhasil disetujui dan selesai',
            'data' => $order
        ]);
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
