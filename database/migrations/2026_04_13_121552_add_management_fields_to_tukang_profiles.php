<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {

    public function up(): void
    {
        Schema::table('tukang_profiles', function (Blueprint $table) {
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending')->after('address');
            $table->boolean('is_blacklisted')->default(false)->after('status');
            $table->double('lat')->nullable()->after('longitude');
            $table->double('lng')->nullable()->after('lat');
        });
    }

    public function down(): void
    {
        Schema::table('tukang_profiles', function (Blueprint $table) {
            //
        });
    }
};
