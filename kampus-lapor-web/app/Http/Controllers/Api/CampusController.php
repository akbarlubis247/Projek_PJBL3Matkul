<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Campus;
use Illuminate\Http\JsonResponse;

class CampusController extends Controller
{
    public function index(): JsonResponse
    {
        $campuses = Campus::where('status', 'approved')
            ->orderBy('name')
            ->get()
            ->map(fn (Campus $campus) => [
                'id' => $campus->id,
                'name' => $campus->name,
                'domain' => $campus->domain,
            ]);

        return response()->json(['data' => $campuses]);
    }

    public function locations(Campus $campus): JsonResponse
    {
        if ($campus->status !== 'approved') {
            return response()->json(['message' => 'Kampus belum aktif.'], 404);
        }

        return response()->json([
            'data' => $campus->locations()
                ->orderBy('name')
                ->get(['id', 'campus_id', 'name']),
        ]);
    }
}
