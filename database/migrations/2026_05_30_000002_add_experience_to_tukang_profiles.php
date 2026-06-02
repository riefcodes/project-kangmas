<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {

    public function up(): void
    {
        Schema::table('tukang_profiles', function (Blueprint $table) {
            if (!Schema::hasColumn('tukang_profiles', 'experience')) {
                $table->integer('experience')->default(0)->after('category');
            }
        });
    }

    public function down(): void
    {
        Schema::table('tukang_profiles', function (Blueprint $table) {
            $table->dropColumn('experience');
        });
    }
};
