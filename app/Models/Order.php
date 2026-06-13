<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Order extends Model
{
    protected $fillable = [
        'user_id',
        'tukang_id',
        'category',
        'description',
        'address',
        'job_date',
        'job_time',
        'image_path',
        'proof_image',
        'status',
        'total_price',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function tukang(): BelongsTo
    {
        return $this->belongsTo(User::class, 'tukang_id');
    }

    public function review(): HasOne
    {
        return $this->hasOne(Review::class);
    }

    public function locationImages(): \Illuminate\Database\Eloquent\Relations\HasMany
    {
        return $this->hasMany(OrderImage::class);
    }
}
