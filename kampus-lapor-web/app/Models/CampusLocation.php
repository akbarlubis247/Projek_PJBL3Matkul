<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use MongoDB\Laravel\Eloquent\Model;

class CampusLocation extends Model
{
    use HasFactory;

    protected $fillable = [
        'campus_id',
        'name',
    ];

    public function campus(): BelongsTo
    {
        return $this->belongsTo(Campus::class);
    }

    public function reports(): HasMany
    {
        return $this->hasMany(Report::class);
    }
}
