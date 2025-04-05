# 🌍 Country Dashboard - Flutter Firebase App

![App Screenshot](https://via.placeholder.com/800x500?text=Country+Dashboard+App) *(Replace with actual screenshot)*

A production-ready Flutter application with Firebase authentication, real-time Firestore CRUD operations, and advanced state management using GetX.

## 🚀 Key Features

### 📱 Core Functionality
- **Phone OTP Authentication** using Firebase Auth
- **Country Data Listing** from REST Countries API
- **Search & Filter** with debounce (300ms delay)
- **Sorting** by population (Ascending/Descending)
- **Firestore CRUD** for custom country data
- **Responsive UI** works on mobile & tablet

### ✨ Bonus Features
- Onboarding screens for first-time users
- Light/Dark theme support
- Shimmer loading effects
- Comprehensive error handling
- Pagination (10 items per page)
- Confirmation dialogs for delete actions

## 🛠 Tech Stack

**Frontend**:
- Flutter 3.13.0
- Dart 3.1.0

**Backend**:
- Firebase Authentication
- Cloud Firestore (NoSQL)
- REST Countries API v2

**Packages**:
| Package | Version | Usage |
|---------|---------|-------|
| `get` | 4.6.5 | State management |
| `firebase_core` | 2.15.0 | Firebase core |
| `cloud_firestore` | 4.9.1 | Firestore DB |
| `dio` | 5.3.2 | HTTP requests |
| `intl_phone_field` | 3.1.0 | Phone input |

## 📂 Project Structure
lib/
├── controllers/
│ ├── auth_controller.dart # Auth logic
│ ├── country_controller.dart # API operations
│ └── firestore_controller.dart # Firestore CRUD
├── models/
│ ├── country_model.dart # API response model
│ └── custom_country_model.dart # Firestore model
├── services/
│ ├── api_service.dart # REST API calls
│ └── firestore_service.dart # DB operations
├── utils/
│ ├── constants.dart # App constants
│ └── theme.dart # Light/dark themes
└── views/
├── auth/ # Login/OTP screens
├── dashboard/ # Main app screens
└── onboarding/ # Onboarding flow

### 🛠 Installation

1. **Clone with SSH**:
   ```bash
   git clone git@github.com:yourusername/country-dashboard-app.git

## 🎥 Demo

Key Features Showcased:
- OTP Authentication flow
- Real-time search filtering
- Firestore CRUD operations

## 🏗 Architecture Diagram

```mermaid
graph TD
    A[UI Layer] -->|Calls| B[Controller]
    B -->|Manages| C[Services]
    C -->|Fetch Data| D[Firebase/Firestore]
    C -->|API Calls| E[REST Countries]
    D -->|Updates| B
    E -->|Returns Data| B
    B -->|Updates| A

