# Kigali City Directory App

## 1. Introduction
The Kigali City Directory is a mobile application developed using Flutter. Its main goal is to help users in Kigali easily find essential services such as hospitals, police stations, restaurants, and more. The app provides live directions, user reviews, and a bookmarking feature for quick access to favorite listings.

## 2. Features
- **Live Directions:** Users can view their current location and get directions to any listed service using OpenStreetMap.
- **Bookmarks:** Users can bookmark their favorite services for easy access later.
- **Reviews and Ratings:** Users can rate and review services, helping others make informed decisions.
- **Authentication:** Secure login and registration using Firebase Authentication for a personalized experience.

## 3. Technologies Used
- **Flutter:** For cross-platform mobile app development.
- **Firebase:** For authentication, Firestore database, and real-time updates.
- **OpenStreetMap:** For displaying maps and directions.

## 4. Implementation Details
- The app is structured using the Provider pattern for state management.
- Listings, bookmarks, and reviews are managed using Firestore collections.
- Location permissions are handled using the `location` package.
- The UI is designed for clarity and ease of use, with separate screens for home, bookmarks, reviews, and settings.

## 5. Challenges Faced
- Handling real-time location updates and permissions on both emulator and real devices.
- Ensuring smooth data synchronization with Firebase.
- Providing a seamless user experience for authentication and navigation.

## 6. Testing
- The app was tested on both Android emulators and real devices.
- Manual testing was performed for all features, including login, bookmarking, reviewing, and navigation.

## 7. Conclusion
The Kigali City Directory app successfully enables users to find, review, and navigate to essential services in Kigali. The bookmarking and review features enhance user engagement and utility. Future improvements could include push notifications, offline support, and more advanced search/filter options.

## 8. Screenshots
(Add relevant screenshots of the app here)

---

**Submitted by:** [Your Name]
**Date:** March 9, 2026
