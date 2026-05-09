<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Campus;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class WebAuthController extends Controller
{
    public function adminLogin(Request $request): RedirectResponse
    {
        return $this->attemptLogin(
            $request,
            role: 'admin',
            redirectRoute: 'lost-items',
            errorMessage: 'Email atau password admin salah.'
        );
    }

    public function superAdminLogin(Request $request): RedirectResponse
    {
        return $this->attemptLogin(
            $request,
            role: 'superadmin',
            redirectRoute: 'superadmin.approvals',
            errorMessage: 'Email atau password superadmin salah.'
        );
    }

    public function registerAdmin(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'admin_name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'campus_name' => ['required', 'string', 'max:255'],
            'domain' => ['required', 'string', 'max:255', 'unique:campuses,domain'],
            'image' => ['nullable', 'image', 'max:2048'],
            'cropped_image' => ['nullable', 'string'],
            'legal_document' => ['nullable', 'file', 'mimes:pdf,jpg,jpeg,png,webp', 'max:5120'],
        ]);

        $domain = strtolower(trim(preg_replace('/^https?:\/\//i', '', $validated['domain']), " \t\n\r\0\x0B/"));
        $imagePath = $this->storeRegistrationImage($request);
        $documentPath = $request->hasFile('legal_document')
            ? $request->file('legal_document')->store('campus-documents', 'public')
            : null;

        try {
            DB::transaction(function () use ($validated, $domain, $imagePath, $documentPath): void {
                $campus = Campus::create([
                    'name' => $validated['campus_name'],
                    'domain' => $domain,
                    'status' => 'pending',
                    'image_path' => $imagePath,
                    'legal_document_path' => $documentPath,
                ]);

                User::create([
                    'campus_id' => $campus->id,
                    'name' => $validated['admin_name'],
                    'email' => $validated['email'],
                    'username' => $this->availableUsername($validated['email']),
                    'role' => 'admin',
                    'status' => 'active',
                    'password' => Hash::make($validated['password']),
                ]);
            });
        } catch (\Throwable $exception) {
            if ($imagePath) {
                Storage::disk('public')->delete($imagePath);
            }

            if ($documentPath) {
                Storage::disk('public')->delete($documentPath);
            }

            throw $exception;
        }

        return redirect()
            ->route('login')
            ->with('success', 'Pendaftaran kampus berhasil dikirim. Tunggu validasi superadmin sebelum login.');
    }

    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();

        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect()->route('login');
    }

    private function attemptLogin(
        Request $request,
        string $role,
        string $redirectRoute,
        string $errorMessage
    ): RedirectResponse {
        $validated = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::with('campus')
            ->where('email', $validated['email'])
            ->where('role', $role)
            ->first();

        if (
            ! $user
            || ! Hash::check($validated['password'], $user->password)
            || $user->status !== 'active'
            || ($role === 'admin' && $user->campus?->status !== 'approved')
        ) {
            return back()
                ->withErrors(['email' => $errorMessage])
                ->onlyInput('email');
        }

        Auth::login($user);
        $request->session()->regenerate();

        return redirect()->route($redirectRoute);
    }

    private function storeRegistrationImage(Request $request): ?string
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

    private function availableUsername(string $email): string
    {
        $base = Str::slug(Str::before($email, '@')) ?: 'admin';
        $username = $base;
        $index = 1;

        while (User::where('username', $username)->exists()) {
            $username = $base.$index;
            $index++;
        }

        return $username;
    }
}
