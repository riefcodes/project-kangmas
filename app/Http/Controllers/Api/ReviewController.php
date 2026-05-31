<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Review;
use App\Models\TukangProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->role !== 'user') {
            return response()->json([
                'success' => false,
                'message' => 'Only users can submit reviews',
                'data'    => null,
            ], 403);
        }

        $validated = $request->validate([
            'order_id' => 'required|exists:orders,id',
            'rating'   => 'required|integer|min:1|max:5',
            'comment'  => 'nullable|string|max:500',
        ]);

        $order = Order::find($validated['order_id']);

        if ($order->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'You can only review your own orders',
                'data'    => null,
            ], 403);
        }

        if ($order->status !== 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'Only completed orders can be reviewed',
                'data'    => null,
            ], 422);
        }

        if ($order->review) {
            return response()->json([
                'success' => false,
                'message' => 'This order has already been reviewed',
                'data'    => null,
            ], 422);
        }

        $review = Review::create([
            'order_id'  => $order->id,
            'user_id'   => $user->id,
            'tukang_id' => $order->tukang_id,
            'rating'    => $validated['rating'],
            'comment'   => $validated['comment'] ?? null,
        ]);

        $this->recalculateTukangRating($order->tukang_id);

        $review->load(['user:id,name', 'order:id,description']);

        return response()->json([
            'success' => true,
            'message' => 'Review submitted successfully',
            'data'    => $review,
        ], 201);
    }

    public function byTukang(string $tukangId): JsonResponse
    {
        $profile = TukangProfile::where('user_id', $tukangId)->first();

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Tukang not found',
                'data'    => null,
            ], 404);
        }

        $reviews = Review::with(['user:id,name', 'order:id,description'])
            ->where('tukang_id', $tukangId)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Reviews for tukang',
            'data'    => [
                'tukang_name'   => $profile->user->name ?? '-',
                'avg_rating'    => $profile->avg_rating,
                'total_reviews' => $profile->total_reviews,
                'reviews'       => $reviews,
            ],
        ]);
    }

    private function recalculateTukangRating(int $tukangUserId): void
    {
        $reviews = Review::where('tukang_id', $tukangUserId);
        $count   = $reviews->count();
        $avg     = $count > 0 ? round($reviews->avg('rating'), 2) : 0;

        TukangProfile::where('user_id', $tukangUserId)->update([
            'avg_rating'    => $avg,
            'total_reviews' => $count,
        ]);
    }
}
