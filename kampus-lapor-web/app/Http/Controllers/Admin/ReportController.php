<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CampusLocation;
use App\Models\Conversation;
use App\Models\Report;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\View\View;

class ReportController extends Controller
{
    public function lostItems(Request $request): View
    {
        $status = $request->query('status', 'lost');
        $tag = $request->query('tag');
        $itemTags = $this->itemTags();

        $reports = Report::with(['user', 'location', 'campus'])
            ->where('campus_id', Auth::user()->campus_id)
            ->where('category', 'lost_item')
            ->where('status', $status)
            ->when($tag, fn ($query) => $query->where('tags', $tag))
            ->latest()
            ->paginate(5)
            ->withQueryString();

        return view('admin.lost-items', compact('reports', 'status', 'tag', 'itemTags'));
    }

    public function lostItemReport(Request $request): View
    {
        $status = $request->query('status', 'lost');
        $status = in_array($status, ['lost', 'found'], true) ? $status : 'lost';
        $tag = $request->query('tag');

        $reports = Report::with(['user', 'location', 'campus'])
            ->where('campus_id', Auth::user()->campus_id)
            ->where('category', 'lost_item')
            ->where('status', $status)
            ->when($tag, fn ($query) => $query->where('tags', $tag))
            ->latest()
            ->get();

        $reportImages = $this->reportImageDataUris($reports);
        $statusLabel = $status === 'found' ? 'Barang Ditemukan' : 'Barang Hilang';

        return view('admin.lost-item-report', compact('reports', 'reportImages', 'status', 'statusLabel', 'tag'));
    }

    public function damagedFacilities(Request $request): View
    {
        $status = $request->query('status', 'damaged');
        $locationId = $request->query('location');

        $reports = Report::with(['user', 'location', 'campus'])
            ->where('campus_id', Auth::user()->campus_id)
            ->where('category', 'damaged_facility')
            ->where('status', $status)
            ->when($locationId, fn ($query) => $query->where('campus_location_id', $locationId))
            ->latest()
            ->paginate(5)
            ->withQueryString();

        $locations = CampusLocation::where('campus_id', Auth::user()->campus_id)->orderBy('name')->get();

        return view('admin.damaged-facilities', compact('reports', 'locations', 'status', 'locationId'));
    }

    public function updateStatus(Request $request, Report $report): RedirectResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'in:damaged,repaired,lost,found'],
        ]);

        abort_unless($report->campus_id === Auth::user()->campus_id, 404);

        $report->update($validated);
        $this->notifyOwnerWhenResolved($report->refresh());

        return back()->with('success', 'Status laporan berhasil diperbarui.');
    }

    public function destroy(Report $report): RedirectResponse
    {
        abort_unless($report->campus_id === Auth::user()->campus_id, 404);

        if ($report->image_path) {
            Storage::disk('public')->delete($report->image_path);
        }

        $report->delete();

        return back()->with('success', 'Laporan berhasil dihapus permanen.');
    }

    public function facilityReport(): View
    {
        $reports = Report::with(['location', 'campus'])
            ->where('campus_id', Auth::user()->campus_id)
            ->where('category', 'damaged_facility')
            ->where('status', 'damaged')
            ->latest()
            ->get();

        $reportImages = $this->reportImageDataUris($reports);

        return view('admin.facility-report', compact('reports', 'reportImages'));
    }

    private function itemTags(): array
    {
        return [
            'HP',
            'Dompet',
            'Botol',
            'Laptop',
            'Kunci',
            'Kartu Mahasiswa',
            'Charger',
            'Headset',
            'Buku',
            'Peralatan Tulis',
            'Tas',
            'Payung',
            'Jaket',
            'Sepatu',
            'Jam Tangan',
            'Flashdisk',
            'Kacamata',
        ];
    }

    private function reportImageDataUris($reports)
    {
        return $reports
            ->filter(fn (Report $report) => filled($report->image_path) && Storage::disk('public')->exists($report->image_path))
            ->mapWithKeys(function (Report $report): array {
                $image = Storage::disk('public')->get($report->image_path);
                $mime = Storage::disk('public')->mimeType($report->image_path) ?? 'image/jpeg';

                return [$report->id => 'data:'.$mime.';base64,'.base64_encode($image)];
            });
    }

    private function notifyOwnerWhenResolved(Report $report): void
    {
        if (! $report->user) {
            return;
        }

        $isLostItemFound = $report->category === 'lost_item' && $report->status === 'found';
        $isFacilityRepaired = $report->category === 'damaged_facility' && $report->status === 'repaired';

        if (! $isLostItemFound && ! $isFacilityRepaired) {
            return;
        }

        $admin = Auth::user();
        $title = $isLostItemFound ? 'Barang anda sudah ditemukan!' : 'Fasilitas sudah diperbaiki!';
        $body = $isLostItemFound
            ? 'Admin mengonfirmasi barang di laporan kamu sudah ditemukan. Silahkan cek menu pesan atau ambil ke lokasi kampus.'
            : 'Admin mengonfirmasi fasilitas di laporan kamu sudah diperbaiki.';

        $report->user->notifications()->create([
            'title' => $title,
            'body' => $body,
        ]);

        if ($admin && $admin->id !== $report->user_id) {
            $conversation = Conversation::where('campus_id', $admin->campus_id)
                ->where('participant_ids', (string) $admin->id)
                ->where('participant_ids', (string) $report->user_id)
                ->first();

            if (! $conversation) {
                $conversation = Conversation::create([
                    'campus_id' => $admin->campus_id,
                    'subject' => 'Percakapan '.$admin->name.' dan '.$report->user->name,
                    'participant_ids' => [(string) $admin->id, (string) $report->user_id],
                ]);
            }

            $conversation->messages()->create([
                'sender_id' => $admin->id,
                'body' => $body,
            ]);
            $conversation->touch();
        }
    }
}
