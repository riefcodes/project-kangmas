<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TukangProfile;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $rules = [
            'name'                  => 'required|string|max:255',
            'email'                 => 'required|string|email|max:255|unique:users',
            'password'              => ['required', 'confirmed', Password::min(8)],
            'role'                  => 'required|in:user,tukang',
            'phone_number'          => 'nullable|string|max:20',
        ];

        if ($request->input('role') === 'tukang') {
            $rules['category']   = 'required|in:listrik,air,bangunan';
            $rules['latitude']   = 'required|numeric|between:-90,90';
            $rules['longitude']  = 'required|numeric|between:-180,180';
            $rules['address']    = 'required|string|max:255';
            $rules['base_price'] = 'required|integer|min:0';
        }

        $validated = $request->validate($rules);

        $user = User::create([
            'name'         => $validated['name'],
            'email'        => $validated['email'],
            'password'     => Hash::make($validated['password']),
            'role'         => $validated['role'],
            'phone_number' => $validated['phone_number'] ?? null,
        ]);

        if ($validated['role'] === 'tukang') {
            TukangProfile::create([
                'user_id'    => $user->id,
                'category'   => $validated['category'],
                'latitude'   => $validated['latitude'],
                'longitude'  => $validated['longitude'],
                'address'    => $validated['address'],
                'base_price' => $validated['base_price'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Registration successful',
            'data'    => [
                'user'  => $user->load('tukangProfile'),
                'token' => $token,
            ],
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email'    => 'required|string|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials',
                'data'    => null,
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data'    => [
                'user'  => $user->load('tukangProfile'),
                'token' => $token,
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
            'data'    => null,
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load('tukangProfile');

        return response()->json([
            'success' => true,
            'message' => 'User profile',
            'data'    => $user,
        ]);
    }
}
