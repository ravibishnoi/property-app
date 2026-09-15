# PropertyApp — Luxury Property Listing Application

A modern, role-based real estate mobile application built with **Flutter**, **Clean Architecture**, **Riverpod**, **GoRouter**, and **Hive** for offline local persistence.

---

## 🔑 Demo User Accounts

Use these pre-seeded accounts to log in and test role-based behavior.

| Name | Role | Email | Password | What You Can Test |
|---|---|---|---|---|
| **Aarav Sharma** | `user` | `user@test.com` | `user123` | • Browse 11 curated properties<br>• Search by keyword / locality<br>• Multidimensional filters (Type, Price slider, Area, BHK, Status)<br>• View property details & specs<br>• Submit interest inquiry forms |
| **Priya Mehta** | `owner` | `owner@test.com` | `owner123` | • Owner Portal with KPI metrics<br>• View owned inventory (Sunrise Residency, Palm Meadows Villa, Lakeview Heights, etc.)<br>• View incoming buyer inquiries with 1-tap copy contact |
| **Rohan Kapoor** | `owner` | `owner2@test.com` | `owner123` | • View owned inventory (Green Valley Row House, City Center Studio, Royal Orchid Villa, etc.)<br>• View inquiries received for Rohan's properties |

---

## ✨ Features Overview

### 1. Modern Luxury Design System (Light & Dark Mode)
- **Theme Switcher**: Seamless toggle between Dark Mode and Light Mode.
- **Luxury Real Estate Palette**: Curated slate surfaces, emerald accents, and custom launcher icon.

### 2. User Experience & Search (`UserDashboardScreen`)
- **Real-Time Search**: Instant keyword search across property name, location, and description.
- **Property Filtering**: Filter by property type, price range, area, configuration, and status.

### 3. Property Detail Page (`PropertyDetailScreen`)
- **High-Resolution Imagery**: Displays property photos with luxury styling.
- **Detailed Specifications**: BHK, total area, and price per sqft.
- **Verified Owner Card & Action**: View owner information and submit interest.

### 4. Express Interest Inquiry Form (`InterestFormScreen`)
- **Client-Side Form Validation**: Name, 10-digit mobile number, email, and inquiry message.
- **Local Synchronization**: Inquiries are saved to local storage and reflected in real-time.

### 5. Property Owner Portal (`OwnerDashboardScreen`)
- **KPI Metrics**: Total listings, available properties, and received buyer inquiries.
- **Inventory & Inquiries**: Manage owned listings and view buyer inquiries with 1-tap contact actions.

---

## 🚀 Getting Started & Setup

### Prerequisites
- Flutter SDK `^3.0.0` (tested on Flutter `3.44.4`)
- Dart SDK `^3.0.0`

### 1. Clone & Install Dependencies
```bash
git clone <repository-url>
cd property_app
flutter pub get
```

### 2. Run the Application
```bash
# Run on connected device, emulator, or simulator
flutter run

# Run on macOS desktop
flutter run -d macos

# Run on Chrome
flutter run -d chrome
```

### 3. Run Automated Tests
```bash
flutter test
```

### 4. Code Quality & Linting
```bash
flutter analyze
```

### 5. Build Release Bundle
```bash
# Build APK
flutter build apk

# Build Web release
flutter build web

# Build macOS app
flutter build macos
```

---

## 📂 Project Structure

```
lib/
├── main.dart                    # Application entry point with Hive bootstrap
├── core/
│   ├── constants/               # Enums, currency/area formatters, box names
│   ├── di/                      # Hive initialization and db.json seed loader
│   ├── errors/                  # Failure exceptions
│   ├── router/                  # GoRouter configuration with auth-based redirect
│   ├── theme/                   # Light & dark theme palettes and ThemeMode notifier
│   └── widgets/                 # Reusable PropertyCard, EmptyState, ThemeToggleButton
└── features/
    ├── auth/                    # Login, AppUser, authentication provider
    ├── property/                # Catalog, search, filters, PropertyDetailScreen
    ├── interest/                # Interest form, validation, and submission logic
    └── owner_dashboard/         # Landlord KPI stats, inventory, and inquiries stream
```
