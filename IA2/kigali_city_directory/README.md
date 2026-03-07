# Kigali City Services & Places Directory

A Flutter mobile application that helps Kigali residents locate and navigate to essential public services and leisure/lifestyle locations such as hospitals, police stations, public libraries, utility offices, restaurants, cafés, parks, and tourist attractions.

## Features

- **User Authentication**: Sign up, login, logout with Firebase Authentication and email verification
- **Location Listings (CRUD)**: Create, read, update, and delete service/place listings stored in Cloud Firestore
- **Real-Time Updates**: All listing changes are reflected immediately via Firestore real-time streams
- **Search & Filter**: Search listings by name and filter by category with dynamic results
- **Map Integration**: Embedded Google Maps with markers for each listing, plus turn-by-turn navigation launch
- **Bottom Navigation**: Directory, My Listings, Map View, and Settings screens
- **State Management**: Provider pattern with dedicated service layer (no direct Firestore calls from UI)
- **Notification Preferences**: Toggle for location-based notification settings

## Architecture

### State Management: Provider
The app uses the **Provider** package for state management. All Firestore interactions are handled through dedicated service classes, and the UI is updated via `ChangeNotifier` providers.

### Folder Structure
```
lib/
├── main.dart                          # App entry point, Firebase init, Provider setup
├── firebase_options.dart              # Firebase configuration
├── models/
│   ├── user_model.dart                # User profile data model
│   └── listing_model.dart             # Listing data model
├── services/
│   ├── auth_service.dart              # Firebase Auth + Firestore user profile operations
│   └── listing_service.dart           # Firestore CRUD operations for listings
├── providers/
│   ├── auth_provider.dart             # Authentication state management
│   └── listing_provider.dart          # Listings state management (CRUD, search, filter)
└── screens/
    ├── auth/
    │   ├── login_screen.dart
    │   ├── signup_screen.dart
    │   └── email_verification_screen.dart
    ├── home/
    │   └── home_screen.dart           # BottomNavigationBar container
    ├── directory/
    │   └── directory_screen.dart      # Browse all listings with search & filter
    ├── listings/
    │   ├── my_listings_screen.dart    # User's own listings with edit/delete
    │   ├── listing_form_screen.dart   # Create/Edit listing form
    │   └── listing_detail_screen.dart # Detail view with embedded map
    ├── map/
    │   └── map_view_screen.dart       # Full map view with all listing markers
    └── settings/
        └── settings_screen.dart       # User profile & notification toggle
```

### Data Flow
```
UI Widgets → Provider (ChangeNotifier) → Service Layer → Firebase (Auth / Firestore)
```
- **UI widgets** never call Firebase APIs directly
- **Providers** manage loading, success, and error states
- **Services** handle all Firebase interactions
- Firestore streams provide **real-time updates** that automatically rebuild the UI

## Firestore Database Structure

### Collection: `users`
| Field               | Type      | Description                    |
|---------------------|-----------|--------------------------------|
| uid                 | String    | Firebase Auth UID              |
| email               | String    | User email address             |
| displayName         | String    | User's full name               |
| createdAt           | Timestamp | Account creation date          |
| notificationsEnabled| Boolean   | Notification preference toggle |

### Collection: `listings`
| Field         | Type      | Description                                    |
|---------------|-----------|------------------------------------------------|
| name          | String    | Place or service name                          |
| category      | String    | Category (Hospital, Restaurant, Park, etc.)    |
| address       | String    | Physical address                               |
| contactNumber | String    | Contact phone number                           |
| description   | String    | Description of the place/service               |
| latitude      | Number    | Geographic latitude                            |
| longitude     | Number    | Geographic longitude                           |
| createdBy     | String    | UID of the user who created the listing        |
| timestamp     | Timestamp | Creation timestamp                             |

## Setup Instructions

### Prerequisites
- Flutter SDK (3.10+)
- Firebase project with Authentication and Cloud Firestore enabled
- Google Maps API key (for Android/iOS)

### Step 1: Firebase Setup
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable **Email/Password** authentication in Firebase Console → Authentication → Sign-in method
3. Create a **Cloud Firestore** database in Firebase Console → Firestore Database
4. Install the FlutterFire CLI and run:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
5. This will generate the `lib/firebase_options.dart` file with your project's configuration
6. Place the `google-services.json` file in `android/app/`

### Step 2: Google Maps API Key
1. Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable the **Maps SDK for Android** and **Maps SDK for iOS**
3. Replace `YOUR_GOOGLE_MAPS_API_KEY` in `android/app/src/main/AndroidManifest.xml`

### Step 3: Firestore Security Rules
Set up the following Firestore rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && resource.data.createdBy == request.auth.uid;
    }
  }
}
```

### Step 4: Run the App
```bash
flutter pub get
flutter run
```

## Categories
- Hospital
- Police Station
- Library
- Restaurant
- Café
- Park
- Tourist Attraction
- Utility Office
