<?php

namespace App\Http\Controllers\SuperAdmin;

use App\Http\Controllers\Controller;
use App\Models\Campus;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class ApprovalController extends Controller
{
    public function index(Request $request): View
    {
        $status = $request->query('status', 'pending');
        $documentCampus = $request->query('document')
            ? Campus::with('admins')->find($request->query('document'))
            : null;

        $campuses = Campus::with('admins')
            ->where('status', $status)
            ->latest()
            ->paginate(6)
            ->withQueryString();

        return view('superadmin.approvals', compact('campuses', 'status', 'documentCampus'));
    }

    public function updateCampusStatus(Request $request, Campus $campus): RedirectResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'in:pending,approved,rejected,banned'],
        ]);

        $campus->update($validated);

        return back()->with('success', 'Status pendaftaran kampus berhasil diperbarui.');
    }

    public function admins(Request $request): View
    {
        $status = $request->query('status', 'active');

        $admins = User::with('campus')
            ->where('role', 'admin')
            ->where('status', $status)
            ->latest()
            ->paginate(6)
            ->withQueryString();

        return view('superadmin.admins', compact('admins', 'status'));
    }

    public function showAdmin(User $user): View
    {
        abort_unless($user->role === 'admin', 404);

        $user->load(['campus.locations']);

        $stats = [
            'users' => User::where('role', 'student')
                ->where('campus_id', $user->campus_id)
                ->count(),
            'reports' => $user->campus?->reports()->count() ?? 0,
            'locations' => $user->campus?->locations()->count() ?? 0,
        ];

        return view('superadmin.admin-profile', compact('user', 'stats'));
    }

    public function updateAdminStatus(Request $request, User $user): RedirectResponse
    {
        $validated = $request->validate([
            'status' => ['required', 'in:active,banned'],
        ]);

        $user->update($validated);

        return back()->with('success', 'Status admin berhasil diperbarui.');
    }
}
