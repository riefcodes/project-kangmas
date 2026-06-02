<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TukangProfile extends Model
{
    protected $fillable = [
        'user_id',
        'category',
        'experience',
        'latitude',
        'longitude',
        'lat',
        'lng',
        'address',
        'status',
        'is_active',
        'is_blacklisted',
        'avg_rating',
        'total_reviews',
        'base_price',
        'ktp_path',
        'selfie_path',
        'portofolio_path',
    ];

    protected function casts(): array
    {
        return [
            'latitude'  => 'float',
            'longitude' => 'float',
            'is_active' => 'boolean',
            'avg_rating' => 'float',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
