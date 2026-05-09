<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CampusLocation;
use App\Models\Report;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class ReportController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'category' => ['nullable', Rule::in(['lost_item', 'damaged_facility'])],
            'status' => ['nullable', Rule::in(['lost', 'found', 'damaged', 'repaired'])],
            'location_id' => ['nullable', 'string'],
            'q' => ['nullable', 'string', 'max:100'],
        ]);

        $reports = Report::with(['user', 'location', 'campus'])
            ->where('campus_id', $request->user()->campus_id)
            ->when($validated['category'] ?? null, fn ($query, $category) => $query->where('category', $category))
            ->when($validated['status'] ?? null, fn ($query, $status) => $query->where('status', $status))
            ->when($validated['location_id'] ?? null, fn ($query, $locationId) => $query->where('campus_location_id', $locationId))
            ->when($validated['q'] ?? null, fn ($query, $keyword) => $query->where(function ($query) use ($keyword): void {
                $query->where('title', 'like', '%'.$keyword.'%')
                    ->orWhere('description', 'like', '%'.$keyword.'%')
                    ->orWhere('tags', 'like', '%'.$keyword.'%');
            }))
            ->latest()
            ->paginate(10);

        return response()->json([
            'data' => $reports->getCollection()->map(fn (Report $report) => $this->reportPayload($report)),
            'meta' => [
                'current_page' => $reports->currentPage(),
                'last_page' => $reports->lastPage(),
                'total' => $reports->total(),
            ],
        ]);
    }

    public function mine(Request $request): JsonResponse
    {
        $reports = Report::with(['user', 'location', 'campus'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate(10);

        return response()->json([
            'data' => $reports->getCollection()->map(fn (Report $report) => $this->reportPayload($report)),
            'meta' => [
                'current_page' => $reports->currentPage(),
                'last_page' => $reports->lastPage(),
                'total' => $reports->total(),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'category' => ['required', Rule::in(['lost_item', 'damaged_facility'])],
            'campus_location_id' => ['required', 'string'],
            'title' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'tags' => ['nullable', 'array'],
            'tags.*' => ['string', 'max:50'],
            'image' => ['nullable', 'image', 'max:5120'],
        ]);

        $location = CampusLocation::findOrFail($validated['campus_location_id']);

        if ($location->campus_id !== $request->user()->campus_id) {
            return response()->json(['message' => 'Lokasi tidak sesuai dengan kampus user.'], 422);
        }

        $imagePath = $request->hasFile('image')
            ? $request->file('image')->store('reports', 'public')
            : null;

        $report = Report::create([
            'campus_id' => $request->user()->campus_id,
            'campus_location_id' => $location->id,
            'user_id' => $request->user()->id,
            'category' => $validated['category'],
            'status' => $validated['category'] === 'lost_item' ? 'lost' : 'damaged',
            'title' => $validated['title'],
            'description' => $validated['description'],
            'tags' => $validated['tags'] ?? [],
            'image_path' => $imagePath,
        ])->load(['user', 'location', 'campus']);

        return response()->json([
            'message' => 'Laporan berhasil dibuat.',
            'data' => $this->reportPayload($report),
        ], 201);
    }

    public function show(Request $request, Report $report): JsonResponse
    {
        if ($report->campus_id !== $request->user()->campus_id) {
            return response()->json(['message' => 'Laporan tidak ditemukan.'], 404);
        }

        return response()->json([
            'data' => $this->reportPayload($report->load(['user', 'location', 'campus'])),
        ]);
    }

    public function image(Report $report)
    {
        if (! $report->image_path || ! Storage::disk('public')->exists($report->image_path)) {
            abort(404);
        }

        return response()->file(Storage::disk('public')->path($report->image_path), [
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, OPTIONS',
            'Access-Control-Allow-Headers' => 'Content-Type, Authorization, Accept',
        ]);
    }

    public function updateStatus(Request $request, Report $report): JsonResponse
    {
        if ($report->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Kamu hanya bisa mengubah laporan milikmu.'], 403);
        }

        $allowedStatuses = $report->category === 'lost_item'
            ? ['lost', 'found']
            : ['damaged', 'repaired'];

        $validated = $request->validate([
            'status' => ['required', Rule::in($allowedStatuses)],
        ]);

        $report->update(['status' => $validated['status']]);

        return response()->json([
            'message' => 'Status laporan berhasil diperbarui.',
            'data' => $this->reportPayload($report->refresh()->load(['user', 'location', 'campus'])),
        ]);
    }

    public function destroy(Request $request, Report $report): JsonResponse
    {
        if ($report->user_id !== $request->user()->id) {
            return response()->json(['message' => 'Kamu hanya bisa menghapus laporan milikmu.'], 403);
        }

        $this->deleteReport($report);

        return response()->json(['message' => 'Laporan berhasil dihapus.']);
    }

    private function deleteReport(Report $report): void
    {
        if ($report->image_path) {
            Storage::disk('public')->delete($report->image_path);
        }

        $report->delete();
    }

    private function reportPayload(Report $report): array
    {
        return [
            'id' => $report->id,
            'category' => $report->category,
            'status' => $report->status,
            'title' => $report->title,
            'description' => $report->description,
            'tags' => $report->tags ?? [],
            'image_url' => $report->image_path ? '/api/reports/'.$report->id.'/image' : null,
            'created_at' => $report->created_at?->toISOString(),
            'user' => [
                'id' => $report->user?->id,
                'name' => $report->user?->name,
                'username' => $report->user?->username,
            ],
            'campus' => [
                'id' => $report->campus?->id,
                'name' => $report->campus?->name,
            ],
            'location' => [
                'id' => $report->location?->id,
                'name' => $report->location?->name,
            ],
        ];
    }
}
