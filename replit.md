# Electrocom - Flutter Mobile App

## Project Overview

**Electrocom** is a modern employee management mobile application built with Flutter for both Android and iOS platforms. The app features a dark theme and follows modern, minimal UI/UX design principles.

## Current Status

This project contains the **frontend UI implementation only**. All screens are fully designed with placeholder data and ready for backend integration.

## Tech Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider
- **Secure Storage**: flutter_secure_storage
- **UI Theme**: Material Design 3
- **Typography**: Google Fonts (Inter)

## Architecture

### Screens Implemented

1. **Authentication**
   - Login Screen with mobile number (10-digit) and password validation
   - Client-side form validation
   - Secure token storage using flutter_secure_storage
   - Forgot Password and Help links (UI only, not functional yet)

2. **Main Navigation**
   - Bottom Navigation Bar with 5 tabs:
     - Home (Dashboard)
     - Attendance
     - Tasks
     - Notifications
     - Profile

3. **Home/Dashboard**
   - Welcome card with user info
   - Quick stats (Present, Absent, Pending, Completed)
   - Recent activity feed

4. **Attendance**
   - Today's check-in/check-out status
   - Attendance history with status badges
   - Check-out button (UI only)

5. **Tasks**
   - Tabbed interface (All, Pending, Completed)
   - Task cards with priority levels
   - Floating action button to add tasks (UI only)

6. **Notifications**
   - Notification feed with read/unread status
   - Different notification types (tasks, messages, events)
   - Mark all as read option (UI only)

7. **Profile**
   - User avatar and basic info
   - Personal information section
   - Work information section
   - Settings, Help, Privacy, About links (UI only)
   - Logout functionality with confirmation dialog

## Key Features

- **Dark Theme**: Custom dark color palette optimized for readability
- **Responsive Design**: Works on various screen sizes
- **Form Validation**: Client-side validation for login inputs
- **State Management**: Provider pattern for authentication state
- **Secure Storage**: Token storage using flutter_secure_storage
- **Modern UI**: Material Design 3 with rounded corners, cards, and icons

## Project Structure

```
lib/
├── config/
│   └── theme.dart                  # Dark theme configuration
├── providers/
│   └── auth_provider.dart          # Authentication state
├── screens/
│   ├── auth/
│   │   └── login_screen.dart       # Login
│   ├── main/
│   │   └── main_navigation.dart    # Bottom nav wrapper
│   ├── home/
│   │   └── home_screen.dart        # Dashboard
│   ├── attendance/
│   │   └── attendance_screen.dart  # Attendance tracking
│   ├── tasks/
│   │   └── tasks_screen.dart       # Task management
│   ├── notifications/
│   │   └── notifications_screen.dart
│   └── profile/
│       └── profile_screen.dart     # User profile
├── utils/
│   └── validators.dart             # Form validators
└── main.dart                       # App entry point
```

## Important Notes

### Replit Environment Limitations

- **Flutter is NOT natively supported in Replit** - This project contains Flutter code that must be run in a local development environment
- No workflow has been configured because Flutter cannot run in the Replit web environment
- Users must download the project files and run them locally with Flutter SDK

### Running the Project Locally

1. Install Flutter SDK (3.0+)
2. Download all project files
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` on an Android emulator, iOS simulator, or physical device

### Current Implementation Status

✅ **Completed**:
- Project structure and configuration
- Dark theme with custom color palette
- Login screen with validation
- Main navigation with bottom navigation bar
- All 5 main screens (Home, Attendance, Tasks, Notifications, Profile)
- Form validators utility
- Authentication provider with secure storage
- Complete UI/UX for all screens

⏳ **Not Implemented** (Next Phase):
- Backend API integration
- Actual authentication flow
- Real data fetching
- Forgot Password screen
- Help & Support screens
- Settings functionality
- Task creation/editing
- Push notifications
- Biometric authentication

## Color Palette

- **Primary**: `#6C63FF` (Purple)
- **Secondary**: `#03DAC6` (Teal)
- **Background**: `#121212` (Black)
- **Surface**: `#1E1E1E` (Dark Gray)
- **Card**: `#2C2C2C` (Medium Gray)
- **Error**: `#CF6679` (Pink)
- **Success**: `#4CAF50` (Green)
- **Warning**: `#FFA726` (Orange)

## User Preferences

- Dark theme by default
- Modern, minimal design
- Clean and simple navigation
- Focus on employee management features

## Recent Changes

- **Nov 3, 2025**: Initial project creation with all core screens and navigation
