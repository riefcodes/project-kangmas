<?php

use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\RecommenderController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\TukangProfileController;
use App\Http\Controllers\Api\TukangController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| All routes are prefixed with /api automatically.
|
*/

// ── Public Routes ───────────────────────────────────────────
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/recommend', [RecommenderController::class, 'recommend']);
Route::get('/reviews/tukang/{tukangId}', [ReviewController::class, 'byTukang']);
Route::get('/tukang/{id}', [TukangProfileController::class, 'show']);

// New Tukang Management Routes
Route::post('/tukang/register', [TukangController::class, 'registerTukang']);
Route::get('/tukang', [TukangController::class, 'getApprovedTukangs']);

// ── Protected Routes (require Bearer token) ────────────────
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);

    // Orders CRUD
    Route::apiResource('orders', OrderController::class);

    // Reviews
    Route::post('/reviews', [ReviewController::class, 'store']);

    // Tukang Profile Management
    Route::put('/tukang/profile', [TukangProfileController::class, 'update']);
    Route::patch('/tukang/toggle-active', [TukangProfileController::class, 'toggleActive']);

    // ── Admin-only Routes ───────────────────────────────
    Route::middleware('admin')->prefix('admin')->group(function () {
        Route::get('/dashboard', [AdminController::class, 'dashboard']);
        Route::get('/users', [AdminController::class, 'users']);
        Route::get('/orders', [AdminController::class, 'orders']);
        Route::get('/tukang/analytics', [AdminController::class, 'tukangAnalytics']);

        // Tukang Verification & Management
        Route::get('/tukang/pending', [TukangController::class, 'getPendingTukangs']);
        Route::post('/tukang/approve/{id}', [TukangController::class, 'approveTukang']);
        Route::post('/tukang/reject/{id}', [TukangController::class, 'rejectTukang']);
        Route::post('/tukang/blacklist/{id}', [TukangController::class, 'blacklistTukang']);
        Route::post('/tukang/unblacklist/{id}', [TukangController::class, 'unblacklistTukang']);
    });
});
