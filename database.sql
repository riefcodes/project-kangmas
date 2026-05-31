-- KANGMAS WEB Database Dump
-- Generated on: 2026-05-31 16:06:30

SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `cache`;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `cache_locks`;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `failed_jobs`;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `job_batches`;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `jobs`;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `migrations`;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `migrations` VALUES 
('1', '0001_01_01_000000_create_users_table', '1'),
('2', '0001_01_01_000001_create_cache_table', '1'),
('3', '0001_01_01_000002_create_jobs_table', '1'),
('4', '2024_01_01_000003_create_tukang_profiles_table', '1'),
('5', '2024_01_01_000004_create_orders_table', '1'),
('6', '2024_01_01_000005_create_reviews_table', '1'),
('7', '2026_03_16_111752_create_personal_access_tokens_table', '1'),
('8', '2026_04_13_121552_add_management_fields_to_tukang_profiles', '1'),
('9', '2026_05_30_000001_add_document_paths_to_tukang_profiles', '1'),
('10', '2026_05_30_000002_add_experience_to_tukang_profiles', '1');

DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `tukang_id` bigint unsigned NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `image_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('pending','accepted','completed','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `total_price` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `orders_user_id_foreign` (`user_id`),
  KEY `orders_tukang_id_foreign` (`tukang_id`),
  CONSTRAINT `orders_tukang_id_foreign` FOREIGN KEY (`tukang_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `password_reset_tokens`;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `personal_access_tokens`;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `tukang_id` bigint unsigned NOT NULL,
  `rating` tinyint NOT NULL,
  `comment` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reviews_order_id_foreign` (`order_id`),
  KEY `reviews_user_id_foreign` (`user_id`),
  KEY `reviews_tukang_id_foreign` (`tukang_id`),
  CONSTRAINT `reviews_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_tukang_id_foreign` FOREIGN KEY (`tukang_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `sessions` VALUES 
('U3DjI7WqUuZA98lpqWdhkG31Vw2RsF0kfi6lyQp5', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWkZBQkZ3MExmaVZVbVVEdFp6Qm5IeERRbnV2d3Z3ZE9nSmRGTk9jUyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MzM6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMC9hZG1pbi9sb2dpbiI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', '1780243303');

DROP TABLE IF EXISTS `tukang_profiles`;
CREATE TABLE `tukang_profiles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `category` enum('listrik','air','bangunan') COLLATE utf8mb4_unicode_ci NOT NULL,
  `experience` int NOT NULL DEFAULT '0',
  `latitude` decimal(10,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `lat` double DEFAULT NULL,
  `lng` double DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','approved','rejected') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `is_blacklisted` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `avg_rating` decimal(3,2) NOT NULL DEFAULT '0.00',
  `total_reviews` int NOT NULL DEFAULT '0',
  `base_price` int NOT NULL DEFAULT '0',
  `ktp_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `selfie_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `portofolio_path` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tukang_profiles_user_id_foreign` (`user_id`),
  CONSTRAINT `tukang_profiles_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `tukang_profiles` VALUES 
('1', '5', 'listrik', '8', '-6.8523029', '107.6475512', '-6.8523029', '107.6475512', 'Jl. Sukabirus No. 12, Bojongsoang, Bandung', 'approved', '0', '1', '4.08', '44', '150000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:44', '2026-05-31 15:50:44'),
('2', '6', 'listrik', '5', '-7.0479012', '107.5601639', '-7.0479012', '107.5601639', 'Jl. Sukapura No. 45, Dayeuhkolot, Bandung', 'approved', '0', '1', '4.16', '31', '200000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:45', '2026-05-31 15:50:45'),
('3', '7', 'listrik', '12', '-7.0889360', '107.4658986', '-7.088936', '107.4658986', 'Jl. Mengger Hilir No. 8, Bandung', 'approved', '0', '1', '3.40', '14', '100000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:45', '2026-05-31 15:50:45'),
('4', '8', 'listrik', '4', '-7.0437330', '107.7086028', '-7.043733', '107.7086028', 'Jl. Telekomunikasi No. 15, Bandung', 'approved', '0', '1', '3.15', '40', '180000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:45', '2026-05-31 15:50:45'),
('5', '9', 'listrik', '9', '-6.8190295', '107.8032664', '-6.8190295', '107.8032664', 'Jl. Ciganitri Tengah No. 34, Bandung', 'approved', '0', '1', '3.65', '18', '220000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:45', '2026-05-31 15:50:45'),
('6', '10', 'listrik', '6', '-6.8140708', '107.4719078', '-6.8140708', '107.4719078', 'Jl. PGA No. 10, Bojongsoang, Bandung', 'approved', '0', '1', '4.14', '24', '170000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:45', '2026-05-31 15:50:45'),
('7', '11', 'listrik', '15', '-6.9332048', '107.7331647', '-6.9332048', '107.7331647', 'Jl. Sukabirus Gg. Slamet No. 3, Bandung', 'approved', '0', '1', '3.32', '40', '120000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:45', '2026-05-31 15:50:45'),
('8', '12', 'listrik', '3', '-6.9646816', '107.4717268', '-6.9646816', '107.4717268', 'Jl. Radio Palasari No. 22, Dayeuhkolot, Bandung', 'approved', '0', '1', '4.59', '17', '130000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:46', '2026-05-31 15:50:46'),
('9', '13', 'listrik', '11', '-6.9325041', '107.7686771', '-6.9325041', '107.7686771', 'Jl. Sukabirus Indah No. 50, Bandung', 'approved', '0', '1', '3.36', '36', '160000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:46', '2026-05-31 15:50:46'),
('10', '14', 'listrik', '2', '-6.9038660', '107.7239879', '-6.903866', '107.7239879', 'Jl. Adipura No. 9, Bojongsoang, Bandung', 'approved', '0', '1', '3.92', '46', '140000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:46', '2026-05-31 15:50:46'),
('11', '15', 'air', '7', '-6.9174125', '107.5732684', '-6.9174125', '107.5732684', 'Jl. Sukabirus No. 88, Bojongsoang, Bandung', 'approved', '0', '1', '4.44', '49', '120000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:46', '2026-05-31 15:50:46'),
('12', '16', 'air', '4', '-6.9712393', '107.5403986', '-6.9712393', '107.5403986', 'Jl. Sukapura Raya No. 19, Bandung', 'approved', '0', '1', '4.45', '42', '175000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:46', '2026-05-31 15:50:46'),
('13', '17', 'air', '10', '-6.8809231', '107.6939418', '-6.8809231', '107.6939418', 'Jl. Dayeuhkolot No. 142, Bandung', 'approved', '0', '1', '4.59', '23', '80000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:47', '2026-05-31 15:50:47'),
('14', '18', 'air', '5', '-6.8536504', '107.4535362', '-6.8536504', '107.4535362', 'Jl. Ciganitri Gg. Mesjid No. 2, Bandung', 'approved', '0', '1', '3.19', '35', '190000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:47', '2026-05-31 15:50:47'),
('15', '19', 'air', '12', '-7.0068124', '107.7018153', '-7.0068124', '107.7018153', 'Jl. Mengger Girang No. 11, Bandung', 'approved', '0', '1', '4.67', '41', '150000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:47', '2026-05-31 15:50:47'),
('16', '20', 'air', '3', '-6.8804021', '107.7049828', '-6.8804021', '107.7049828', 'Jl. PGA Gg. H. Gofur No. 7, Bandung', 'approved', '0', '1', '3.08', '26', '110000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:47', '2026-05-31 15:50:47'),
('17', '21', 'air', '9', '-6.7980269', '107.6708460', '-6.7980269', '107.670846', 'Jl. Sukabirus Gg. Mukti No. 4, Bandung', 'approved', '0', '1', '4.42', '48', '210000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:48', '2026-05-31 15:50:48'),
('18', '22', 'air', '6', '-7.0637833', '107.7301782', '-7.0637833', '107.7301782', 'Jl. Sukabirus Baru No. 15, Bandung', 'approved', '0', '1', '4.37', '47', '130000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:48', '2026-05-31 15:50:48'),
('19', '23', 'air', '14', '-7.0525544', '107.5733408', '-7.0525544', '107.5733408', 'Jl. Sukapura Gg. Melati No. 18, Bandung', 'approved', '0', '1', '3.97', '48', '250000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:48', '2026-05-31 15:50:48'),
('20', '24', 'air', '2', '-6.9155620', '107.6244012', '-6.915562', '107.6244012', 'Jl. Bojongsoang Raya No. 200, Bandung', 'approved', '0', '1', '4.86', '27', '165000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:48', '2026-05-31 15:50:48'),
('21', '25', 'bangunan', '10', '-6.9454578', '107.5664808', '-6.9454578', '107.5664808', 'Jl. Sukabirus No. 104, Bojongsoang, Bandung', 'approved', '0', '1', '3.16', '10', '250000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:48', '2026-05-31 15:50:48'),
('22', '26', 'bangunan', '8', '-6.9954578', '107.6638232', '-6.9954578', '107.6638232', 'Jl. Sukapura No. 58, Dayeuhkolot, Bandung', 'approved', '0', '1', '3.11', '35', '300000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:49', '2026-05-31 15:50:49'),
('23', '27', 'bangunan', '11', '-7.0163166', '107.5304978', '-7.0163166', '107.5304978', 'Jl. Telekomunikasi No. 8, Bandung', 'approved', '0', '1', '3.54', '8', '200000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:49', '2026-05-31 15:50:49'),
('24', '28', 'bangunan', '5', '-7.0350014', '107.6083645', '-7.0350014', '107.6083645', 'Jl. Ciganitri Mukti No. 12, Bandung', 'approved', '0', '1', '4.94', '31', '180000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:49', '2026-05-31 15:50:49'),
('25', '29', 'bangunan', '15', '-6.8490510', '107.5776848', '-6.849051', '107.5776848', 'Jl. Mengger Asri No. 4, Bandung', 'approved', '0', '1', '3.91', '46', '220000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:49', '2026-05-31 15:50:49'),
('26', '30', 'bangunan', '6', '-6.9758566', '107.7016343', '-6.9758566', '107.7016343', 'Jl. Sukabirus Gg. Karyawan No. 2, Bandung', 'approved', '0', '1', '4.28', '23', '170000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:50', '2026-05-31 15:50:50'),
('27', '31', 'bangunan', '13', '-7.0009914', '107.4961438', '-7.0009914', '107.4961438', 'Jl. Radio Palasari Baru No. 6, Bandung', 'approved', '0', '1', '3.61', '20', '190000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:50', '2026-05-31 15:50:50'),
('28', '32', 'bangunan', '4', '-7.0476497', '107.5069677', '-7.0476497', '107.5069677', 'Jl. Sukabirus Asri No. 12, Bandung', 'approved', '0', '1', '4.41', '36', '160000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:50', '2026-05-31 15:50:50'),
('29', '33', 'bangunan', '9', '-6.8646277', '107.5926174', '-6.8646277', '107.5926174', 'Jl. Sukapura Gg. H. Kurdi No. 5, Bandung', 'approved', '0', '1', '3.43', '46', '210000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', NULL, '2026-05-31 15:50:50', '2026-05-31 15:50:50'),
('30', '34', 'bangunan', '7', '-6.9509195', '107.7010008', '-6.9509195', '107.7010008', 'Jl. Bojongsoang Gg. Dahlia No. 1, Bandung', 'approved', '0', '1', '4.91', '9', '280000', 'documents/ktp/seed_ktp.jpg', 'documents/selfie/seed_selfie.jpg', 'documents/portfolios/seed_portfolio.pdf', '2026-05-31 15:50:50', '2026-05-31 15:50:50');

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','user','tukang') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `phone_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users` VALUES 
('1', 'Admin KANGMAS', 'admin@kangmas.com', NULL, '$2y$12$/Cf4zvel0XdUK7JbBLSM2OoGyhG.1442.8s4ZyhNShdzYK5o9bg8W', 'admin', '081200000000', NULL, '2026-05-31 15:50:44', '2026-05-31 15:50:44'),
('2', 'Budi Santoso', 'user1@kangmas.com', NULL, '$2y$12$VbxClJwQKB0Q9AXl3ECwuesdoaqHWP7nDgapS4CvTVhE0gQAkXZGm', 'user', '081200000001', NULL, '2026-05-31 15:50:44', '2026-05-31 15:50:44'),
('3', 'Siti Nurhaliza', 'user2@kangmas.com', NULL, '$2y$12$0GnGqw3MpKI0d2AjnkUlY.5KZFARex4Lp1aQUxwIx2qstIowiFG.W', 'user', '081200000002', NULL, '2026-05-31 15:50:44', '2026-05-31 15:50:44'),
('4', 'Andi Prasetyo', 'user3@kangmas.com', NULL, '$2y$12$E2P5l4geYhnjCKKdbltG9ey4/f08wMfHvFlieF9K3bj3S8lclz2QW', 'user', '081200000003', NULL, '2026-05-31 15:50:44', '2026-05-31 15:50:44'),
('5', 'Pak Udin Listrik', 'tukang1@kangmas.com', NULL, '$2y$12$/LuC1EJPAnxcm.Tic4cqYenOT17Vii.MsWP6yPOsxtGFqLcCuvEfq', 'tukang', '081200000010', NULL, '2026-05-31 15:50:44', '2026-05-31 15:50:44'),
('6', 'Mas Joko Electrical', 'tukang2@kangmas.com', NULL, '$2y$12$v0wxpWDjKSTpUK.htVsz2u./2s8.Uy1We773HeNNPZfioyke6KT9K', 'tukang', '081200000011', NULL, '2026-05-31 15:50:45', '2026-05-31 15:50:45'),
('7', 'Pak Soleh Listrik', 'tukang3@kangmas.com', NULL, '$2y$12$dU6pMzzvMGmlVFAVLkpJBuCrEx4GD1NBux06fCx8T4wc.7x8v50t6', 'tukang', '081200000012', NULL, '2026-05-31 15:50:45', '2026-05-31 15:50:45'),
('8', 'Mas Budi Setiawan', 'tukang4@kangmas.com', NULL, '$2y$12$bZsZ7a9TC1lGNYKnxvAcJOYzpbXSj584l4hhpYOEu2MsPOSSWdixS', 'tukang', '081200000013', NULL, '2026-05-31 15:50:45', '2026-05-31 15:50:45'),
('9', 'Pak Hendra Kelistrikan', 'tukang5@kangmas.com', NULL, '$2y$12$qq7dUwAIN2ADncDGHR/k5ukW8m0K4A4HWBpg2DcWr9sl1eWxo4AIa', 'tukang', '081200000014', NULL, '2026-05-31 15:50:45', '2026-05-31 15:50:45'),
('10', 'Mas Ridwan Teknik', 'tukang6@kangmas.com', NULL, '$2y$12$feNdcK4LtDukVHjYY7/gUu8lq.qEdvLfpdzn.fzSvpDPD1dG9HDc.', 'tukang', '081200000015', NULL, '2026-05-31 15:50:45', '2026-05-31 15:50:45'),
('11', 'Pak Bambang Listrik', 'tukang7@kangmas.com', NULL, '$2y$12$J.vdXTi.czdZCHcYajr5Hubti/4XJyu2z27pgAR4S6WIkww8VgNX.', 'tukang', '081200000016', NULL, '2026-05-31 15:50:45', '2026-05-31 15:50:45'),
('12', 'Mas Yanto Kabel', 'tukang8@kangmas.com', NULL, '$2y$12$SsTnkgy7opqnqbfgr2zO8e6qgoWCJFIQYxgjOolxbdMkHlOWXBQiy', 'tukang', '081200000017', NULL, '2026-05-31 15:50:46', '2026-05-31 15:50:46'),
('13', 'Pak Slamet Instalasi', 'tukang9@kangmas.com', NULL, '$2y$12$1ZfBR3o8BCWTD4PbrqHmPORs3aoTiwRj8OXuBMST1jDX/PLF50POa', 'tukang', '081200000018', NULL, '2026-05-31 15:50:46', '2026-05-31 15:50:46'),
('14', 'Mas Dani Listrik', 'tukang10@kangmas.com', NULL, '$2y$12$eRfaEaXsThcHrDXt7GcPlOqVSd3Pcy85NsvfA3iDOlSaVcEcwtJWy', 'tukang', '081200000019', NULL, '2026-05-31 15:50:46', '2026-05-31 15:50:46'),
('15', 'Pak Agus Plumbing', 'tukang11@kangmas.com', NULL, '$2y$12$AsuoxVbrQ4vEJmGlq4A0VuWeUYXe.oyU8hDAyy2nBi9EVXnr5LM0S', 'tukang', '081200000020', NULL, '2026-05-31 15:50:46', '2026-05-31 15:50:46'),
('16', 'Mas Dedi Pipa', 'tukang12@kangmas.com', NULL, '$2y$12$L9jQQeH0SE.ieCIISNE6deIH9/9iCW7FkSbnJgSfxZX5PXItK.fdK', 'tukang', '081200000021', NULL, '2026-05-31 15:50:46', '2026-05-31 15:50:46'),
('17', 'Pak Hasan Air', 'tukang13@kangmas.com', NULL, '$2y$12$vkVJtDzf/PR.6B2uFJob2ujY2u5ylrplk6WxluiqO55qiV0HACh..', 'tukang', '081200000022', NULL, '2026-05-31 15:50:47', '2026-05-31 15:50:47'),
('18', 'Mas Wahyu Saluran Pompa', 'tukang14@kangmas.com', NULL, '$2y$12$nYNzq05KQl5cSJt2C6fMdOTs.me2iyZJIRgeITpEyqImACSkYjGry', 'tukang', '081200000023', NULL, '2026-05-31 15:50:47', '2026-05-31 15:50:47'),
('19', 'Pak Supardi Pompa Air', 'tukang15@kangmas.com', NULL, '$2y$12$JGnQGRQ2hstWT5Cnk5ptMua.HbWQTSOpUVk72lLIJiae5wHD3xBOi', 'tukang', '081200000024', NULL, '2026-05-31 15:50:47', '2026-05-31 15:50:47'),
('20', 'Mas Ari Plumbing', 'tukang16@kangmas.com', NULL, '$2y$12$AqtjbM/YiFlk.8m9rRvX5u8erRc7xaVOdSJn/BFWqURvCFk4jziGe', 'tukang', '081200000025', NULL, '2026-05-31 15:50:47', '2026-05-31 15:50:47'),
('21', 'Pak Toto Saniter', 'tukang17@kangmas.com', NULL, '$2y$12$o.yyh7cRzSzEcxxHecSaUeujHY4bGAyucG4TW8TO0I40/cxi6fn0y', 'tukang', '081200000026', NULL, '2026-05-31 15:50:48', '2026-05-31 15:50:48'),
('22', 'Mas Guntur Pipa Bocor', 'tukang18@kangmas.com', NULL, '$2y$12$jHXysPU076gHwpGQYePFy.QjyMEXtzRIXAr0wctsdtkEOSnZ1NXD2', 'tukang', '081200000027', NULL, '2026-05-31 15:50:48', '2026-05-31 15:50:48'),
('23', 'Pak Anwar Sumur Bor', 'tukang19@kangmas.com', NULL, '$2y$12$sVr4rU2usJkTsWcIX8ZUwOPr37xNUhk5174UfvLLQDMGduysNoAcW', 'tukang', '081200000028', NULL, '2026-05-31 15:50:48', '2026-05-31 15:50:48'),
('24', 'Mas Bagus Water Filter', 'tukang20@kangmas.com', NULL, '$2y$12$mN38aejgHCPxVctcIc3bYOZFEHyFcTJJ4vK5pNjKIKyr50IGJISaK', 'tukang', '081200000029', NULL, '2026-05-31 15:50:48', '2026-05-31 15:50:48'),
('25', 'Pak Rudi Bangunan', 'tukang21@kangmas.com', NULL, '$2y$12$bD4wJnTeikiF2VUihsb30.oMfWfitZZ7GQHONb6ECPrfi0t33kK56', 'tukang', '081200000030', NULL, '2026-05-31 15:50:48', '2026-05-31 15:50:48'),
('26', 'Mas Eko Konstruksi', 'tukang22@kangmas.com', NULL, '$2y$12$Z1U4oIzVy5eIJCWfxbZC4uWQgUso2YISxTU2eeNIqgJP0.gpsGYf6', 'tukang', '081200000031', NULL, '2026-05-31 15:50:49', '2026-05-31 15:50:49'),
('27', 'Pak Wahyu Builder', 'tukang23@kangmas.com', NULL, '$2y$12$M2m7lcAAhJksBd5A5NgqZOK94TvJQunXJpVglUEsmaY269v2rk9Jm', 'tukang', '081200000032', NULL, '2026-05-31 15:50:49', '2026-05-31 15:50:49'),
('28', 'Mas Fajar Bangunan', 'tukang24@kangmas.com', NULL, '$2y$12$63uOAYCPVOieocyL2rpH0exYvxpRAiC0RWgGFJMdX828M7ruE9hXm', 'tukang', '081200000033', NULL, '2026-05-31 15:50:49', '2026-05-31 15:50:49'),
('29', 'Pak Kusno Renovasi', 'tukang25@kangmas.com', NULL, '$2y$12$Wb55qMVOZVRpZ/dkG9C.SeZkp3UKWVh48YdgeirDzRDqTqqQPH2iq', 'tukang', '081200000034', NULL, '2026-05-31 15:50:49', '2026-05-31 15:50:49'),
('30', 'Mas Sigit Kusen', 'tukang26@kangmas.com', NULL, '$2y$12$V0a5844X1cdReENAUK0gN.xL2xkqiik/ZlIG0hDjv9aI8Ie5YVWXm', 'tukang', '081200000035', NULL, '2026-05-31 15:50:50', '2026-05-31 15:50:50'),
('31', 'Pak Karjo Tembok', 'tukang27@kangmas.com', NULL, '$2y$12$/fZ7Q9uHl37JJVX0eGAjH.8Jj2A/rRx9ATjbuou7T1ByLM5hxNSaW', 'tukang', '081200000036', NULL, '2026-05-31 15:50:50', '2026-05-31 15:50:50'),
('32', 'Mas Edi Plafon', 'tukang28@kangmas.com', NULL, '$2y$12$MYbLSaP6jvQMYju6Zi6ARe8E77iPZNyNNrDSikpxkhDd8ElIpG2zK', 'tukang', '081200000037', NULL, '2026-05-31 15:50:50', '2026-05-31 15:50:50'),
('33', 'Pak Sutrisno Cat & Kayu', 'tukang29@kangmas.com', NULL, '$2y$12$Y/sE/OjWNk4iOvUc2w6v6OUBsCAjb.DI5eoWlsdfRWRF.1VkIG/Ai', 'tukang', '081200000038', NULL, '2026-05-31 15:50:50', '2026-05-31 15:50:50'),
('34', 'Mas Heri Las Kanopi', 'tukang30@kangmas.com', NULL, '$2y$12$uDY.udpNzjzAWk.wAKLIkei2JvD2vwbnX73Rh0DjX7YnffI.L0eBi', 'tukang', '081200000039', NULL, '2026-05-31 15:50:50', '2026-05-31 15:50:50');

SET FOREIGN_KEY_CHECKS=1;
