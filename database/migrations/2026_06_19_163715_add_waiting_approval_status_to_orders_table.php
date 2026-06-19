<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // MySQL specific: Alter the enum to include waiting_approval
        DB::statement("ALTER TABLE orders MODIFY COLUMN status ENUM('pending', 'accepted', 'completed', 'cancelled', 'waiting_approval') DEFAULT 'pending'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement("ALTER TABLE orders MODIFY COLUMN status ENUM('pending', 'accepted', 'completed', 'cancelled') DEFAULT 'pending'");
    }
};
