<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TukangProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RecommenderController extends Controller
{
    private const MAX_RADIUS_KM = 20;

    private const WEIGHT_RATING   = 0.6;
    private const WEIGHT_DISTANCE = 0.4;

    public function recommend(Request $request): JsonResponse
    {
        $request->validate([
            'latitude'  => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'category'  => 'required|in:listrik,air,bangunan',
        ]);

        $userLat  = (float) $request->query('latitude');
        $userLng  = (float) $request->query('longitude');
        $category = $request->query('category');

        $tukangs = TukangProfile::with('user:id,name,phone_number')
            ->where('category', $category)
            ->where('is_active', true)
            ->get();

        $scored = $tukangs->map(function (TukangProfile $tukang) use ($userLat, $userLng) {
            $distance = $this->haversine($userLat, $userLng, $tukang->latitude, $tukang->longitude);

            if ($distance > self::MAX_RADIUS_KM) {
                return null;
            }

            $normalizedRating   = $tukang->avg_rating / 5;
            $normalizedDistance  = 1 - ($distance / self::MAX_RADIUS_KM);

            $finalScore = ($normalizedRating * self::WEIGHT_RATING)
                        + ($normalizedDistance * self::WEIGHT_DISTANCE);

            return [
                'tukang_id'     => $tukang->id,
                'user_id'       => $tukang->user_id,
                'name'          => $tukang->user->name ?? '-',
                'phone_number'  => $tukang->user->phone_number ?? '-',
                'category'      => $tukang->category,
                'address'       => $tukang->address,
                'latitude'      => $tukang->latitude,
                'longitude'     => $tukang->longitude,
                'base_price'    => $tukang->base_price,
                'avg_rating'    => $tukang->avg_rating,
                'total_reviews' => $tukang->total_reviews,
                'distance_km'   => round($distance, 2),
                'final_score'   => round($finalScore, 4),
            ];
        })
        ->filter()
        ->sortByDesc('final_score')
        ->take(3)
        ->values();

        return response()->json([
            'success' => true,
            'message' => 'Top recommended tukangs',
            'data'    => $scored,
        ]);
    }

    private function haversine(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earthRadiusKm = 6371;

        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);

        $a = sin($dLat / 2) ** 2
           + cos(deg2rad($lat1)) * cos(deg2rad($lat2))
           * sin($dLng / 2) ** 2;

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return $earthRadiusKm * $c;
    }
}
