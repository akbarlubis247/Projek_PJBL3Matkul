<?php

namespace Database\Seeders;

use App\Models\Campus;
use App\Models\CampusLocation;
use App\Models\Conversation;
use App\Models\Report;
use App\Models\User;
use App\Models\ApiToken;
use App\Models\AppNotification;
use App\Models\Message;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        collect([
            ApiToken::class,
            AppNotification::class,
            Message::class,
            Conversation::class,
            Report::class,
            CampusLocation::class,
            User::class,
            Campus::class,
        ])->each(fn (string $model) => $model::query()->delete());

        $campus = Campus::create([
            'name' => 'IPB',
            'domain' => 'apps.ipb.ac.id',
            'status' => 'approved',
        ]);

        $locations = collect([
            'CB Prog, Kampus Vokasi IPB University',
            'CB KOM 2, Kampus Vokasi IPB University',
            'Gedung Bengkel, Kampus Vokasi IPB University',
            'Perpustakaan, Kampus Vokasi IPB University',
            'Kantin, Kampus Vokasi IPB University',
        ])->map(fn ($name) => $campus->locations()->create(['name' => $name]));

        User::create([
            'campus_id' => $campus->id,
            'name' => 'Admin Kampus',
            'email' => 'admin@apps.ipb.ac.id',
            'username' => 'adminipb',
            'role' => 'admin',
            'status' => 'active',
            'password' => Hash::make('password'),
        ]);

        User::create([
            'name' => 'Super Admin',
            'email' => 'superadmin@campuslapor.test',
            'username' => 'superadmin',
            'role' => 'superadmin',
            'status' => 'active',
            'password' => Hash::make('password'),
        ]);

        collect([
            ['Universitas Indonesia', 'ui.ac.id', 'pending', 'Jajang Najmudin', 'jajang@ui.ac.id'],
            ['Universitas Gadjah Mada', 'ugm.ac.id', 'pending', 'Jajang Najmudin', 'jajang@ugm.ac.id'],
            ['IPB', 'mail.ipb.ac.id', 'pending', 'Jajang Najmudin', 'jajang2@ipb.ac.id'],
            ['Universitas Gadjah Mada', 'mail.ugm.ac.id', 'rejected', 'Jajang Najmudin', 'jajang2@ugm.ac.id'],
            ['IPB', 'admin.ipb.ac.id', 'banned', 'Jajang Najmudin', 'jajang3@ipb.ac.id'],
        ])->each(function ($item, $index): void {
            $extraCampus = Campus::create([
                'name' => $item[0],
                'domain' => $item[1],
                'status' => $item[2],
            ]);

            User::create([
                'campus_id' => $extraCampus->id,
                'name' => $item[3],
                'email' => $item[4],
                'username' => 'adminkampus'.$index,
                'role' => 'admin',
                'status' => $item[2] === 'banned' ? 'banned' : 'active',
                'password' => Hash::make('password'),
            ]);
        });

        $students = collect([
            ['Siti Nurbaya', 'siti432'],
            ['Adam Terry', 'adamterry15'],
            ['Santi Rock', 'santirock'],
            ['Rani Maharani', 'rani111'],
            ['Dika Pratama', 'dika07'],
            ['Nabila Putri', 'nabila23'],
        ])->map(fn ($student, $index) => User::create([
            'campus_id' => $campus->id,
            'name' => $student[0],
            'email' => $student[1].'@apps.ipb.ac.id',
            'username' => $student[1],
            'role' => 'student',
            'status' => $index === 5 ? 'banned' : 'active',
            'password' => Hash::make('password'),
        ]));

        foreach (range(1, 4) as $index) {
            Report::create([
                'campus_id' => $campus->id,
                'campus_location_id' => $locations->random()->id,
                'user_id' => $students->random()->id,
                'category' => 'lost_item',
                'status' => $index === 4 ? 'found' : 'lost',
                'title' => 'Botol tumbler hilang',
                'description' => 'Dicari botol tumbler hilang, hilang di C1 Rogo. Botol berwarna putih dan tutupnya hitam. Dengan botol bergambar kemerdekaan 70.',
                'tags' => ['Botol', 'Tumbler', 'CB Prog'],
            ]);
        }

        $facilityImages = collect([
            'reports/vhRsV9HvDjLCom05MkUwWNZ2TY22X3hyFHsIXvRY.png',
            'reports/hWZ9WVTsa26D3N2VPJuZvRvDdXMFOSzdWYd4HLT6.jpg',
            'reports/BxLlsUNdLQdXucC7A6rHbEZXgxefvJgMXrBJfsDj.jpg',
        ]);

        foreach (range(1, 5) as $index) {
            Report::create([
                'campus_id' => $campus->id,
                'campus_location_id' => $locations->random()->id,
                'user_id' => $students->random()->id,
                'category' => 'damaged_facility',
                'status' => $index === 5 ? 'repaired' : 'damaged',
                'title' => 'Bangku rusak',
                'description' => 'Bangku rusak, penyangga depan bawah dari kiri di ruangan C1 003.',
                'tags' => ['Fasilitas', 'Bangku', 'Rusak'],
                'image_path' => $facilityImages->get(($index - 1) % $facilityImages->count()),
            ]);
        }

        $siti = $students->firstWhere('username', 'siti432');
        $santi = $students->firstWhere('username', 'santirock');
        $admin = User::where('email', 'admin@apps.ipb.ac.id')->first();

        collect([
            ['Pesan baru dari Santi', 'Barangnya ketemu di Cb Prog, Cilibend..'],
            ['Barang anda ditemukan!', 'Silahkan ambil di bengkong'],
            ['Pesan baru dari Admin', 'Barangnya ketemu silahkan diambil'],
        ])->each(fn ($notification) => $siti->notifications()->create([
            'title' => $notification[0],
            'body' => $notification[1],
        ]));

        collect([$santi, $admin])->filter()->each(function (User $participant) use ($campus, $siti): void {
            $conversation = Conversation::create([
                'campus_id' => $campus->id,
                'subject' => 'Percakapan '.$siti->name.' dan '.$participant->name,
                'participant_ids' => [(string) $siti->id, (string) $participant->id],
            ]);

            $conversation->messages()->create([
                'sender_id' => $participant->id,
                'body' => $participant->role === 'admin'
                    ? 'Barangnya ketemu silahkan diambil'
                    : 'Barangnya ketemu di Cb Prog, Cilibend..',
            ]);
            $conversation->messages()->create([
                'sender_id' => $siti->id,
                'body' => 'Oke Terimakasih infonya',
            ]);
        });
    }
}
