# KANGMAS Mobile App Analysis

After reviewing the Flutter mobile application codebase (`mobile/lib`), I have found several critical technical issues, missing features (compared to your backend database capabilities), and UI/UX flaws. 

Since the mobile app is the core business driver where users find *tukangs* and place orders, these issues need to be addressed before it can be used in a real-world scenario.

---

## 1. Critical Connection Issues (API)

> **WARNING:** The app cannot connect to the backend on an Emulator or Real Device.

In `services/api_service.dart`, the `baseUrl` is hardcoded to:
`static const String baseUrl = 'http://127.0.0.1:8000/api';`

- **Why it's wrong:** `127.0.0.1` refers to the mobile device itself, not your computer running Laragon. 
- **The Fix:** If you are running an Android Emulator, this must be changed to `http://10.0.2.2:8000/api`. If you are testing on a real phone, it must be changed to your computer's local Wi-Fi IP address (e.g., `http://192.168.1.5:8000/api`).

---

## 2. Hardcoded User Location

> **CAUTION:** The recommendation system is currently useless because it thinks everyone lives at Telkom University.

In `screens/user_home_screen.dart`, when fetching recommended *tukangs*, the location is hardcoded:
```dart
// Mock latitude and longitude for Telkom University
final lat = -6.9730;
final lng = 107.6307;
```
- **Why it's wrong:** Your Recommender API relies heavily on distance and proximity. Right now, no matter where the user actually is, they will only see tukangs near Telkom University.
- **The Fix:** You need to implement the `geolocator` package to fetch the user's actual GPS coordinates before calling the `/recommend` API.

---

## 3. Missing Features (Compared to Backend)

Your backend database and API are actually more advanced than what the mobile app is currently using. 

1. **Missing Image Uploads for Orders:**
   Your `orders` table in the database has an `image_path` column to store pictures of the broken pipe, electrical issue, etc. However, `create_order_screen.dart` only has a text field for the description. The user cannot upload a photo of the problem.
2. **Missing Order Location:**
   When a user creates an order, they cannot specify their address. The Tukang accepts the order but has no idea where to go to fix the issue. You need an address input field or a map pin selector in the checkout process.
3. **Missing Push Notifications / Real-time Updates:**
   When a *Tukang* accepts an order, the user's screen doesn't update automatically. They have to manually reload the page. Implementing Pusher or Firebase Cloud Messaging (FCM) would solve this.

---

## 4. UI/UX & Typography Flaws

The app currently looks like a basic prototype rather than a premium marketplace app.

- **Basic Typography:** The app is using the default Flutter Material font (Roboto). It lacks a modern typeface. Implementing a custom font via `google_fonts` (like *Inter*, *Poppins*, or *Outfit*) would drastically improve the look.
- **Color Palette:** It relies on default `Colors.blue` and `Colors.grey`. It needs a defined theme with primary, secondary, and accent colors to build brand identity.
- **Lack of Feedback:** When buttons are pressed (like "Terima Order"), there are no loading spinners on the buttons themselves, making the app feel unresponsive while the API is being called.

## Summary

The core logic (fetching orders, accepting orders, WhatsApp integration) works well. However, the hardcoded API IP, hardcoded GPS coordinates, and missing order images/locations are critical blockers that must be fixed to make the application functional for real users.
