# Project KANGMAS - Full Technical Analysis

This document provides a comprehensive technical analysis of the **KANGMAS** project based on the current repository structure.

> **Note:** KANGMAS appears to be a digital marketplace platform for hiring handymen or workers (*tukang*) specializing in electricity (*listrik*), water/plumbing (*air*), and construction/building (*bangunan*).

## 1. Overall Architecture & Tech Stack

The system is a modern multi-client application using a monolithic backend API serving both a Web Frontend and a Mobile Application.

### Backend (API Server)
- **Framework:** Laravel 11 (PHP 8.2+)
- **Authentication:** Laravel Sanctum (Token-based authentication for API, mobile, and web)
- **Routing:** API endpoints are defined in `routes/api.php`
- **Key Modules/Controllers:**
  - `AuthController`: Registration, Login, Logout, Session management.
  - `TukangController` & `TukangProfileController`: Managing worker profiles, onboarding, and availability.
  - `OrderController`: Handling service bookings.
  - `ReviewController`: Handling ratings and feedback.
  - `RecommenderController`: An endpoint `/api/recommend` that likely uses Collaborative Filtering/Matrix Factorization algorithms to recommend *tukangs* to users based on past ratings.
  - `AdminController`: Analytics, user management, and worker moderation.

### Web Frontend (Admin / Web Portal)
- **Library:** React 19
- **Build Tool:** Vite 6
- **Styling:** Tailwind CSS v3 & PostCSS
- **Routing:** React Router v7
- **Key Dependencies:** `@heroicons/react`, `lucide-react`, `@react-google-maps/api` (used for rendering maps to locate *tukangs* or users).
- **Location:** Managed in the root folder via `package.json`, with source files likely inside `resources/js/main.jsx` and `resources/css/app.css`.

### Mobile Application
- **Framework:** Flutter (Dart SDK ^3.11.1)
- **Location:** The `mobile/` directory.
- **Key Packages:**
  - `provider`: State management.
  - `http`: REST API communication with the Laravel backend.
  - `shared_preferences`: Local storage (likely for auth tokens and user data).
  - `url_launcher`: For opening external links or maps.

---

## 2. Database Location & Configuration

### Where is the database?
1. **Configuration:** The project configuration is managed via `.env` (referencing `.env.example`). By default, it is configured to use a local **SQLite** database (`DB_CONNECTION=sqlite`). In a default Laravel setup, this file would be located at `database/database.sqlite`.
2. **Schema & Seed Data:** There is a raw MySQL dump file located at the root of the project: `database.sql` (KANGMAS WEB Database Dump). This file contains the exact schema and sample seed data used to populate the system.

### Core Database Schema & How It Works

The database is structured around four primary entities:

1. **`users` Table:**
   - Stores all accounts.
   - Has a `role` column which dictates permissions: `admin`, `user` (customer), or `tukang` (worker).
   
2. **`tukang_profiles` Table:**
   - Linked to the `users` table via `user_id`.
   - **Fields:** `category` (listrik, air, bangunan), `experience` (years), `base_price` (starting rate).
   - **Geolocation:** Stores `latitude`, `longitude`, and `address` to pinpoint where the worker is based.
   - **Verification:** Includes document paths (`ktp_path`, `selfie_path`, `portofolio_path`) and a `status` field (`pending`, `approved`, `rejected`) controlled by the Admin.
   - **Metrics:** Tracks `avg_rating` and `total_reviews`.

3. **`orders` Table:**
   - Connects a `user_id` (customer) with a `tukang_id` (worker).
   - **Fields:** `description`, `image_path` (for the problem being reported), `status` (pending, accepted, completed, cancelled), and `total_price`.

4. **`reviews` Table:**
   - Linked to a specific `order_id`.
   - Allows users to leave a `rating` (1-5) and a `comment` for the *tukang*.

---

## 3. Core Operational Flows

### 1. Tukang Onboarding & Moderation
- A worker registers via the app/web and submits their KTP (ID card), a selfie, and a portfolio.
- Their profile is created in `tukang_profiles` with a `status` of `pending`.
- An Admin logs into the dashboard, hits the `/api/admin/tukang/pending` route, reviews the documents, and triggers the `/api/admin/tukang/approve/{id}` endpoint to make them active.

### 2. User Ordering a Service
- A user browses the app and can view a list of approved workers (`/api/tukang`).
- They can also receive smart recommendations (`/api/recommend`), which likely analyzes the `reviews` table to find the best match based on previous interactions.
- The user creates an order (`/api/orders`), the *tukang* gets notified, and the status changes from `pending` -> `accepted` -> `completed`.

### 3. Review & Reputation System
- Once an order is `completed`, the user leaves a review (`/api/reviews`).
- This rating is aggregated and updates the `avg_rating` in the `tukang_profiles` table, directly influencing their visibility and future recommendations.

## Summary

You have a very solid, well-structured marketplace application. The backend (Laravel) handles the heavy lifting of data management, authentication, and the recommendation engine. The web portal (React) likely serves as an admin dashboard and booking site, while the mobile app (Flutter) serves as the primary tool for customers and workers on the go.
