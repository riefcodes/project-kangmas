<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('tukang_profiles', function (Blueprint $table) {
            $table->string('ktp_path')->nullable()->after('base_price');
            $table->string('selfie_path')->nullable()->after('ktp_path');
            $table->string('portofolio_path')->nullable()->after('selfie_path');
        });
    }

    public function down(): void
    {
        Schema::table('tukang_profiles', function (Blueprint $table) {
            $table->dropColumn(['ktp_path', 'selfie_path', 'portofolio_path']);
        });
    }
};
