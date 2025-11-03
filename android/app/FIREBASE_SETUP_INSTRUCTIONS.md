# Firebase Setup Instructions

## ⚠️ IMPORTANT: Replace google-services.json

The current `google-services.json` file is a **TEMPLATE**. You MUST replace it with your actual Firebase configuration file.

## Steps to Get Your Real google-services.json:

### 1. Go to Firebase Console
Visit: https://console.firebase.google.com/

### 2. Create or Select Your Project
- Click "Add project" (or select existing project)
- Enter project name: "Electrocom" (or your preferred name)
- Follow the setup wizard

### 3. Add Android App to Your Project
- Click the Android icon to add an Android app
- **Package name**: `com.example.electrocom` (MUST match exactly)
  - This is defined in `android/app/build.gradle`
- App nickname: "Electrocom" (optional)
- Click "Register app"

### 4. Download google-services.json
- Firebase will generate your `google-services.json` file
- Click "Download google-services.json"
- **Replace** the template file at `android/app/google-services.json` with this downloaded file

### 5. Enable Firebase Services (Optional)
In Firebase Console, enable services you need:
- **Cloud Messaging** (for push notifications) - Already configured in the app
- **Analytics** - Already configured in the app
- **Authentication** - If you plan to use Firebase Auth
- **Firestore** - If you need a database

### 6. Verify Setup
After replacing the file, run:
```bash
flutter clean
flutter pub get
flutter run
```

## Common Issues:

### Issue: "google-services.json not found"
- **Solution**: Make sure the file is at `android/app/google-services.json`
- Check the file path is correct

### Issue: "Package name mismatch"
- **Solution**: The package name in Firebase Console MUST be `com.example.electrocom`
- If you changed the package name in `build.gradle`, update Firebase accordingly

### Issue: "Firebase initialization failed"
- **Solution**: 
  1. Verify `google-services.json` is the real file from Firebase (not the template)
  2. Check internet connection
  3. Run `flutter clean && flutter pub get`

## Security Note:
- **Never commit** the real `google-services.json` to public repositories
- Add it to `.gitignore` if your project is public
- Use different Firebase projects for development and production

## Need Help?
- Firebase Documentation: https://firebase.google.com/docs/android/setup
- Flutter Firebase Setup: https://firebase.flutter.dev/docs/overview
