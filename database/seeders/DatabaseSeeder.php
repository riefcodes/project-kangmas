<?php

namespace Database\Seeders;

use App\Models\TukangProfile;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    private const CENTER_LAT = -6.9730;
    private const CENTER_LNG = 107.6307;

    public function run(): void
    {
        User::create([
            'name'         => 'Admin KANGMAS',
            'email'        => 'admin@kangmas.com',
            'password'     => Hash::make('password'),
            'role'         => 'admin',
            'phone_number' => '081200000000',
        ]);

        $users = [
            ['name' => 'Budi Santoso',   'email' => 'user1@kangmas.com', 'phone_number' => '081200000001'],
            ['name' => 'Siti Nurhaliza', 'email' => 'user2@kangmas.com', 'phone_number' => '081200000002'],
            ['name' => 'Andi Prasetyo',  'email' => 'user3@kangmas.com', 'phone_number' => '081200000003'],
        ];

        foreach ($users as $u) {
            User::create([
                'name'         => $u['name'],
                'email'        => $u['email'],
                'password'     => Hash::make('password'),
                'role'         => 'user',
                'phone_number' => $u['phone_number'],
            ]);
        }

        $tukangData = [
            ['name' => 'Pak Udin Listrik', 'category' => 'listrik', 'base_price' => 150000, 'experience' => 8, 'address' => 'Jl. Sukabirus No. 12, Bojongsoang, Bandung'],
            ['name' => 'Mas Joko Electrical', 'category' => 'listrik', 'base_price' => 200000, 'experience' => 5, 'address' => 'Jl. Sukapura No. 45, Dayeuhkolot, Bandung'],
            ['name' => 'Pak Soleh Listrik', 'category' => 'listrik', 'base_price' => 100000, 'experience' => 12, 'address' => 'Jl. Mengger Hilir No. 8, Bandung'],
            ['name' => 'Mas Budi Setiawan', 'category' => 'listrik', 'base_price' => 180000, 'experience' => 4, 'address' => 'Jl. Telekomunikasi No. 15, Bandung'],
            ['name' => 'Pak Hendra Kelistrikan', 'category' => 'listrik', 'base_price' => 220000, 'experience' => 9, 'address' => 'Jl. Ciganitri Tengah No. 34, Bandung'],
            ['name' => 'Mas Ridwan Teknik', 'category' => 'listrik', 'base_price' => 170000, 'experience' => 6, 'address' => 'Jl. PGA No. 10, Bojongsoang, Bandung'],
            ['name' => 'Pak Bambang Listrik', 'category' => 'listrik', 'base_price' => 120000, 'experience' => 15, 'address' => 'Jl. Sukabirus Gg. Slamet No. 3, Bandung'],
            ['name' => 'Mas Yanto Kabel', 'category' => 'listrik', 'base_price' => 130000, 'experience' => 3, 'address' => 'Jl. Radio Palasari No. 22, Dayeuhkolot, Bandung'],
            ['name' => 'Pak Slamet Instalasi', 'category' => 'listrik', 'base_price' => 160000, 'experience' => 11, 'address' => 'Jl. Sukabirus Indah No. 50, Bandung'],
            ['name' => 'Mas Dani Listrik', 'category' => 'listrik', 'base_price' => 140000, 'experience' => 2, 'address' => 'Jl. Adipura No. 9, Bojongsoang, Bandung'],

            ['name' => 'Pak Agus Plumbing', 'category' => 'air', 'base_price' => 120000, 'experience' => 7, 'address' => 'Jl. Sukabirus No. 88, Bojongsoang, Bandung'],
            ['name' => 'Mas Dedi Pipa', 'category' => 'air', 'base_price' => 175000, 'experience' => 4, 'address' => 'Jl. Sukapura Raya No. 19, Bandung'],
            ['name' => 'Pak Hasan Air', 'category' => 'air', 'base_price' => 80000, 'experience' => 10, 'address' => 'Jl. Dayeuhkolot No. 142, Bandung'],
            ['name' => 'Mas Wahyu Saluran Pompa', 'category' => 'air', 'base_price' => 190000, 'experience' => 5, 'address' => 'Jl. Ciganitri Gg. Mesjid No. 2, Bandung'],
            ['name' => 'Pak Supardi Pompa Air', 'category' => 'air', 'base_price' => 150000, 'experience' => 12, 'address' => 'Jl. Mengger Girang No. 11, Bandung'],
            ['name' => 'Mas Ari Plumbing', 'category' => 'air', 'base_price' => 110000, 'experience' => 3, 'address' => 'Jl. PGA Gg. H. Gofur No. 7, Bandung'],
            ['name' => 'Pak Toto Saniter', 'category' => 'air', 'base_price' => 210000, 'experience' => 9, 'address' => 'Jl. Sukabirus Gg. Mukti No. 4, Bandung'],
            ['name' => 'Mas Guntur Pipa Bocor', 'category' => 'air', 'base_price' => 130000, 'experience' => 6, 'address' => 'Jl. Sukabirus Baru No. 15, Bandung'],
            ['name' => 'Pak Anwar Sumur Bor', 'category' => 'air', 'base_price' => 250000, 'experience' => 14, 'address' => 'Jl. Sukapura Gg. Melati No. 18, Bandung'],
            ['name' => 'Mas Bagus Water Filter', 'category' => 'air', 'base_price' => 165000, 'experience' => 2, 'address' => 'Jl. Bojongsoang Raya No. 200, Bandung'],

            ['name' => 'Pak Rudi Bangunan', 'category' => 'bangunan', 'base_price' => 250000, 'experience' => 10, 'address' => 'Jl. Sukabirus No. 104, Bojongsoang, Bandung'],
            ['name' => 'Mas Eko Konstruksi', 'category' => 'bangunan', 'base_price' => 300000, 'experience' => 8, 'address' => 'Jl. Sukapura No. 58, Dayeuhkolot, Bandung'],
            ['name' => 'Pak Wahyu Builder', 'category' => 'bangunan', 'base_price' => 200000, 'experience' => 11, 'address' => 'Jl. Telekomunikasi No. 8, Bandung'],
            ['name' => 'Mas Fajar Bangunan', 'category' => 'bangunan', 'base_price' => 180000, 'experience' => 5, 'address' => 'Jl. Ciganitri Mukti No. 12, Bandung'],
            ['name' => 'Pak Kusno Renovasi', 'category' => 'bangunan', 'base_price' => 220000, 'experience' => 15, 'address' => 'Jl. Mengger Asri No. 4, Bandung'],
            ['name' => 'Mas Sigit Kusen', 'category' => 'bangunan', 'base_price' => 170000, 'experience' => 6, 'address' => 'Jl. Sukabirus Gg. Karyawan No. 2, Bandung'],
            ['name' => 'Pak Karjo Tembok', 'category' => 'bangunan', 'base_price' => 190000, 'experience' => 13, 'address' => 'Jl. Radio Palasari Baru No. 6, Bandung'],
            ['name' => 'Mas Edi Plafon', 'category' => 'bangunan', 'base_price' => 160000, 'experience' => 4, 'address' => 'Jl. Sukabirus Asri No. 12, Bandung'],
            ['name' => 'Pak Sutrisno Cat & Kayu', 'category' => 'bangunan', 'base_price' => 210000, 'experience' => 9, 'address' => 'Jl. Sukapura Gg. H. Kurdi No. 5, Bandung'],
            ['name' => 'Mas Heri Las Kanopi', 'category' => 'bangunan', 'base_price' => 280000, 'experience' => 7, 'address' => 'Jl. Bojongsoang Gg. Dahlia No. 1, Bandung'],
        ];

        foreach ($tukangData as $index => $t) {
            $tukangUser = User::create([
                'name'         => $t['name'],
                'email'        => 'tukang' . ($index + 1) . '@kangmas.com',
                'password'     => Hash::make('password'),
                'role'         => 'tukang',
                'phone_number' => '08120000' . str_pad($index + 10, 4, '0', STR_PAD_LEFT),
            ]);

            [$lat, $lng] = $this->randomCoordinateWithinRadius(
                self::CENTER_LAT,
                self::CENTER_LNG,
                20
            );

            $avgRating = round(mt_rand(300, 500) / 100, 2);
            $totalReviews = mt_rand(5, 50);

            TukangProfile::create([
                'user_id'         => $tukangUser->id,
                'category'        => $t['category'],
                'experience'      => $t['experience'],
                'latitude'        => $lat,
                'longitude'       => $lng,
                'lat'             => $lat,
                'lng'             => $lng,
                'address'         => $t['address'],
                'status'          => 'approved',
                'is_blacklisted'  => false,
                'is_active'       => true,
                'avg_rating'      => $avgRating,
                'total_reviews'   => $totalReviews,
                'base_price'      => $t['base_price'],
                'ktp_path'        => 'documents/ktp/seed_ktp.jpg',
                'selfie_path'     => 'documents/selfie/seed_selfie.jpg',
                'portofolio_path' => mt_rand(0, 1) ? 'documents/portfolios/seed_portfolio.pdf' : null,
            ]);
        }
    }

    private function randomCoordinateWithinRadius(float $lat, float $lng, float $radiusKm): array
    {
        $latOffset = $radiusKm / 111.32;
        $lngOffset = $radiusKm / (111.32 * cos(deg2rad($lat)));

        $newLat = $lat + (mt_rand(-10000, 10000) / 10000) * $latOffset;
        $newLng = $lng + (mt_rand(-10000, 10000) / 10000) * $lngOffset;

        return [round($newLat, 7), round($newLng, 7)];
    }
}
