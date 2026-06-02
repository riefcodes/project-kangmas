<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TukangProfile;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class TukangController extends Controller
{
    public function registerTukang(Request $request): JsonResponse
    {
        $request->validate([
            'name'           => 'required|string|max:255',
            'email'          => 'required|string|email|max:255|unique:users',
            'phone'          => 'required|string|max:20',
            'password'       => 'required|string|min:8',
            'kategori'       => 'required|string',
            'experience'     => 'required|numeric',
            'locationDetail' => 'nullable|string',
            'lat'            => 'nullable|numeric',
            'lng'            => 'nullable|numeric',
            'ktp'            => 'required|file|mimes:jpg,jpeg,png,pdf|max:2048',
            'selfie'         => 'required|file|mimes:jpg,jpeg,png|max:2048',
            'portofolio'     => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:5120',
        ]);

        $user = User::create([
            'name'         => $request->name,
            'email'        => $request->email,
            'password'     => Hash::make($request->password),
            'role'         => 'tukang',
            'phone_number' => $request->phone,
        ]);

        $ktpPath = $request->file('ktp')->store('documents/ktp', 'public');
        $selfiePath = $request->file('selfie')->store('documents/selfie', 'public');
        $portfolioPath = $request->hasFile('portofolio') 
            ? $request->file('portofolio')->store('documents/portfolios', 'public') 
            : null;

        $profile = TukangProfile::create([
            'user_id'         => $user->id,
            'category'        => $this->mapCategory($request->kategori),
            'experience'      => $request->experience ?? 0,
            'latitude'        => $request->lat ?? 0,
            'longitude'       => $request->lng ?? 0,
            'lat'             => $request->lat ?? 0,
            'lng'             => $request->lng ?? 0,
            'address'         => $request->locationDetail ?? '-',
            'status'          => 'pending',
            'is_blacklisted'  => false,
            'is_active'       => true,
            'base_price'      => 0,
            'ktp_path'        => $ktpPath,
            'selfie_path'     => $selfiePath,
            'portofolio_path' => $portfolioPath,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pendaftaran berhasil dikirim. Menunggu verifikasi admin.',
            'data'    => [
                'user'    => $user,
                'profile' => $profile
            ]
        ], 201);
    }

    public function getPendingTukangs(): JsonResponse
    {
        $pending = TukangProfile::with('user')
            ->where('status', 'pending')
            ->get()
            ->map(function($p) {
                return [
                    'id'             => $p->id,
                    'nama'           => $p->user->name,
                    'email'          => $p->user->email,
                    'skill'          => $p->category,
                    'experience'     => $p->experience,
                    'phone'          => $p->user->phone_number,
                    'address'        => $p->address,
                    'lat'            => $p->lat,
                    'lng'            => $p->lng,
                    'ktp_url'        => $p->ktp_path ? asset('storage/' . $p->ktp_path) : null,
                    'selfie_url'     => $p->selfie_path ? asset('storage/' . $p->selfie_path) : null,
                    'portofolio_url' => $p->portofolio_path ? asset('storage/' . $p->portofolio_path) : null,
                ];
            });

        return response()->json([
            'success' => true,
            'data'    => $pending
        ]);
    }

    public function approveTukang(string $id): JsonResponse
    {
        $profile = TukangProfile::findOrFail($id);
        $profile->status = 'approved';
        $profile->save();

        return response()->json([
            'success' => true,
            'message' => 'Tukang berhasil disetujui.'
        ]);
    }

    public function rejectTukang(string $id): JsonResponse
    {
        $profile = TukangProfile::findOrFail($id);
        $profile->status = 'rejected';
        $profile->save();

        return response()->json([
            'success' => true,
            'message' => 'Tukang berhasil ditolak.'
        ]);
    }

    public function blacklistTukang(string $id): JsonResponse
    {
        $profile = TukangProfile::findOrFail($id);
        $profile->is_blacklisted = true;
        $profile->save();

        return response()->json([
            'success' => true,
            'message' => 'Tukang berhasil di-blacklist.'
        ]);
    }

    public function unblacklistTukang(string $id): JsonResponse
    {
        $profile = TukangProfile::findOrFail($id);
        $profile->is_blacklisted = false;
        $profile->save();

        return response()->json([
            'success' => true,
            'message' => 'Status blacklist berhasil dicabut.'
        ]);
    }

    public function getApprovedTukangs(): JsonResponse
    {
        $tukangs = TukangProfile::with('user')
            ->where('status', 'approved')
            ->where('is_blacklisted', false)
            ->get()
            ->map(function($p) {
                return [
                    'id'     => $p->id,
                    'nama'   => $p->user->name,
                    'lat'    => $p->lat,
                    'lng'    => $p->lng,
                    'status' => $p->is_active ? 'Available' : 'Busy',
                    'rating' => $p->avg_rating
                ];
            });

        return response()->json([
            'success' => true,
            'data'    => $tukangs
        ]);
    }

    private function mapCategory($category)
    {
        $map = [
            'Kelistrikan & Kabel'   => 'listrik',
            'Pembangunan Bangunan'  => 'bangunan',
            'Service AC'            => 'air',
            'Sistem Keamanan'       => 'bangunan',
            'Pengecatan & Dekorasi' => 'bangunan',
        ];

        return $map[$category] ?? 'bangunan';
    }
}
