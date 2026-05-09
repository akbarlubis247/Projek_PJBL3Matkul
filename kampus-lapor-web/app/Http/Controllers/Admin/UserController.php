<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class UserController extends Controller
{
    public function index(Request $request): View
    {
        $status = $request->query('status', 'active');
        $search = trim((string) $request->query('search', ''));

        $users = User::where('role', 'student')
            ->where('campus_id', Auth::user()->campus_id)
            ->where('status', $status)
            ->when($search !== '', function ($query) use ($search): void {
                $query->where(function ($query) use ($search): void {
                    $query
                        ->where('name', 'like', '%'.$search.'%')
                        ->orWhere('username', 'like', '%'.$search.'%')
                        ->orWhere('email', 'like', '%'.$search.'%');
                });
            })
            ->latest()
            ->paginate(8)
            ->withQueryString();

        return view('admin.users', compact('users', 'status', 'search'));
    }

    public function show(User $user): View
    {
        abort_unless($user->campus_id === Auth::user()->campus_id && $user->role === 'student', 404);

        $user->load('campus');

        $reportCounts = [
            'total' => $user->reports()->count(),
            'lost' => $user->reports()->where('category', 'lost_item')->count(),
            'facility' => $user->reports()->where('category', 'damaged_facility')->count(),
        ];

        $latestReports = $user->reports()
            ->with('location')
            ->latest()
            ->take(5)
            ->get();

        return view('admin.user-profile', compact('user', 'reportCounts', 'latestReports'));
    }

    public function updateStatus(Request $request, User $user): RedirectResponse
    {
        abort_unless($user->campus_id === Auth::user()->campus_id && $user->role === 'student', 404);

        $validated = $request->validate([
            'status' => ['required', 'in:active,banned'],
        ]);

        $user->update($validated);

        return back()->with('success', 'Status user berhasil diperbarui.');
    }
}
