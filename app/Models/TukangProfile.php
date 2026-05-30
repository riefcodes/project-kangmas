<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TukangProfile extends Model
{
    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'category',
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

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'latitude'  => 'float',
            'longitude' => 'float',
            'is_active' => 'boolean',
            'avg_rating' => 'float',
        ];
    }

    /**
     * Get the user that owns this tukang profile.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
