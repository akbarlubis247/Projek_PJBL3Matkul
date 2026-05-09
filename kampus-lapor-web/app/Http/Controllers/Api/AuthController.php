<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Campus;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'campus_id' => ['required', 'string'],
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'username' => ['required', 'string', 'max:50', 'alpha_dash', 'unique:users,username'],
            'password' => ['required', 'confirmed', Password::min(6)],
        ]);

        $campus = Campus::findOrFail($validated['campus_id']);

        if ($campus->status !== 'approved') {
            return response()->json(['message' => 'Kampus belum disetujui superadmin.'], 422);
        }

        $emailDomain = Str::after($validated['email'], '@');
        if ($emailDomain !== $campus->domain) {
            return response()->json(['message' => 'Email harus memakai domain kampus '.$campus->domain.'.'], 422);
        }

        $user = User::create([
            'campus_id' => $campus->id,
            'name' => $validated['name'],
            'email' => $validated['email'],
            'username' => $validated['username'],
            'role' => 'student',
            'status' => 'active',
            'password' => Hash::make($validated['password']),
        ]);

        return response()->json([
            'message' => 'Registrasi berhasil.',
            'data' => [
                'user' => $this->userPayload($user->load('campus')),
                'token' => $this->createToken($user),
            ],
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::with('campus')->where('email', $validated['email'])->first();

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            return response()->json(['message' => 'Email atau password salah.'], 422);
        }

        if ($user->role !== 'student') {
            return response()->json(['message' => 'Akun ini bukan akun civitas mobile.'], 403);
        }

        if ($user->status !== 'active') {
            return response()->json(['message' => 'Akun sedang diblokir.'], 403);
        }

        return response()->json([
            'message' => 'Login berhasil.',
            'data' => [
                'user' => $this->userPayload($user),
                'token' => $this->createToken($user),
            ],
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'data' => [
                'user' => $this->userPayload($request->user()->load('campus')),
            ],
        ]);
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'username' => ['sometimes', 'required', 'string', 'max:50', 'alpha_dash', 'unique:users,username,'.$user->id],
            'email' => ['sometimes', 'required', 'email', 'max:255', 'unique:users,email,'.$user->id],
            'password' => ['nullable', 'confirmed', Password::min(6)],
        ]);

        if (isset($validated['email'])) {
            $emailDomain = Str::after($validated['email'], '@');
            if ($emailDomain !== $user->campus?->domain) {
                return response()->json(['message' => 'Email harus memakai domain kampus '.$user->campus?->domain.'.'], 422);
            }
        }

        $user->fill(collect($validated)->except('password')->all());

        if (! empty($validated['password'])) {
            $user->password = Hash::make($validated['password']);
        }

        $user->save();

        return response()->json([
            'message' => 'Profil berhasil diperbarui.',
            'data' => [
                'user' => $this->userPayload($user->refresh()->load('campus')),
            ],
        ]);
    }

    public function updateAvatar(Request $request): JsonResponse
    {
        $request->validate([
            'avatar' => ['required', 'image', 'max:2048'],
        ]);

        $user = $request->user();
        $oldAvatarPath = $user->avatar_path;
        $avatarPath = $request->file('avatar')->store('avatars', 'public');

        $user->update(['avatar_path' => $avatarPath]);

        if ($oldAvatarPath) {
            Storage::disk('public')->delete($oldAvatarPath);
        }

        return response()->json([
            'message' => 'Foto profil berhasil diperbarui.',
            'data' => [
                'user' => $this->userPayload($user->refresh()->load('campus')),
            ],
        ]);
    }

    public function avatar(User $user)
    {
        if (! $user->avatar_path || ! Storage::disk('public')->exists($user->avatar_path)) {
            abort(404);
        }

        return response()->file(Storage::disk('public')->path($user->avatar_path), [
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, OPTIONS',
            'Access-Control-Allow-Headers' => 'Content-Type, Authorization, Accept',
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->attributes->get('api_token')?->delete();

        return response()->json(['message' => 'Logout berhasil.']);
    }

    private function createToken(User $user): string
    {
        $plainToken = Str::random(80);

        $user->apiTokens()->create([
            'name' => 'mobile',
            'token' => hash('sha256', $plainToken),
        ]);

        return $plainToken;
    }

    private function userPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'campus_id' => $user->campus_id,
            'name' => $user->name,
            'email' => $user->email,
            'username' => $user->username,
            'avatar_url' => $user->avatar_path ? '/api/users/'.$user->id.'/avatar' : null,
            'role' => $user->role,
            'status' => $user->status,
            'campus' => $user->campus ? [
                'id' => $user->campus->id,
                'name' => $user->campus->name,
                'domain' => $user->campus->domain,
            ] : null,
        ];
    }
}
