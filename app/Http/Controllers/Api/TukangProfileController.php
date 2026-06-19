<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TukangProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TukangProfileController extends Controller
{
    /**
     * View a tukang's public profile (public).
     */
    public function show(string $id): JsonResponse
    {
        $profile = TukangProfile::with('user:id,name,phone_number')->where('user_id', $id)->first();

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Tukang not found',
                'data'    => null,
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Tukang profile',
            'data'    => $profile,
        ]);
    }

    /**
     * Update own tukang profile (tukang role only).
     */
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->role !== 'tukang') {
            return response()->json([
                'success' => false,
                'message' => 'Only tukangs can update their profile',
                'data'    => null,
            ], 403);
        }

        $profile = TukangProfile::where('user_id', $user->id)->first();

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Tukang profile not found',
                'data'    => null,
            ], 404);
        }

        $validated = $request->validate([
            'category'   => 'sometimes|in:listrik,air,bangunan',
            'latitude'   => 'sometimes|numeric|between:-90,90',
            'longitude'  => 'sometimes|numeric|between:-180,180',
            'address'    => 'sometimes|string|max:255',
            'base_price' => 'sometimes|integer|min:0',
        ]);

        $profile->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data'    => $profile->fresh()->load('user:id,name,phone_number'),
        ]);
    }

    /**
     * Toggle is_active status (tukang role only).
     */
    public function toggleActive(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->role !== 'tukang') {
            return response()->json([
                'success' => false,
                'message' => 'Only tukangs can toggle active status',
                'data'    => null,
            ], 403);
        }

        $profile = TukangProfile::where('user_id', $user->id)->first();

        if (! $profile) {
            return response()->json([
                'success' => false,
                'message' => 'Tukang profile not found',
                'data'    => null,
            ], 404);
        }

        $profile->is_active = ! $profile->is_active;
        $profile->save();

        return response()->json([
            'success' => true,
            'message' => $profile->is_active ? 'You are now active' : 'You are now inactive',
            'data'    => $profile,
        ]);
    }
}
