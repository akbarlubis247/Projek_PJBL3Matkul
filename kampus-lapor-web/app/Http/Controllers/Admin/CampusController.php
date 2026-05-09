<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Campus;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use Illuminate\View\View;

class CampusController extends Controller
{
    public function profile(): View
    {
        $campus = Campus::with('locations')->findOrFail(Auth::user()->campus_id);

        return view('admin.campus-profile', compact('campus'));
    }

    public function update(Request $request): RedirectResponse
    {
        $campus = Campus::findOrFail(Auth::user()->campus_id);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'domain' => ['required', 'string', 'max:255'],
            'locations' => ['nullable', 'string'],
            'image' => ['nullable', 'image', 'max:2048'],
            'cropped_image' => ['nullable', 'string'],
        ]);

        $imagePath = $this->storeProfileImage($request);
        $oldImagePath = $campus->image_path;

        DB::transaction(function () use ($campus, $validated, $imagePath): void {
            $updates = [
                'name' => $validated['name'],
                'domain' => $validated['domain'],
            ];

            if ($imagePath) {
                $updates['image_path'] = $imagePath;
            }

            $campus->update($updates);

            $campus->locations()->delete();

            collect(explode("\n", $validated['locations'] ?? ''))
                ->map(fn ($location) => trim($location))
                ->filter()
                ->each(fn ($location) => $campus->locations()->create(['name' => $location]));
        });

        if ($imagePath && $oldImagePath) {
            Storage::disk('public')->delete($oldImagePath);
        }

        return back()->with('success', 'Profil kampus berhasil diperbarui.');
    }

    private function storeProfileImage(Request $request): ?string
    {
        if ($request->filled('cropped_image')) {
            return $this->storeCroppedImage($request->input('cropped_image'));
        }

        return $request->hasFile('image')
            ? $request->file('image')->store('campus-profiles', 'public')
            : null;
    }

    private function storeCroppedImage(string $dataUri): string
    {
        if (! preg_match('/^data:image\/(png|jpe?g|webp);base64,/', $dataUri, $matches)) {
            throw ValidationException::withMessages([
                'image' => 'Format gambar hasil crop tidak valid.',
            ]);
        }

        $encoded = substr($dataUri, strpos($dataUri, ',') + 1);
        $image = base64_decode($encoded, true);

        if ($image === false) {
            throw ValidationException::withMessages([
                'image' => 'Gambar hasil crop tidak bisa dibaca.',
            ]);
        }

        if (strlen($image) > 2 * 1024 * 1024) {
            throw ValidationException::withMessages([
                'image' => 'Ukuran gambar hasil crop maksimal 2 MB.',
            ]);
        }

        $extension = match ($matches[1]) {
            'jpg', 'jpeg' => 'jpg',
            'webp' => 'webp',
            default => 'png',
        };
        $path = 'campus-profiles/'.Str::uuid().'.'.$extension;

        Storage::disk('public')->put($path, $image);

        return $path;
    }
}
