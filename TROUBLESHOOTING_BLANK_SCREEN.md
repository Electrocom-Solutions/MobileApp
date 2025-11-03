# 🔧 Troubleshooting: App Installed But Shows Blank Screen

## ✅ Good News: Your App Built Successfully!

Your terminal shows:
```
✓ Built build/app/outputs/flutter-apk/app-debug.apk
Installing build/app/outputs/flutter-apk/app-debug.apk... 4.6s
```

This means the app compiled and installed on your device (AC2001).

## 🚨 Why You Might See a Blank Screen

### Most Common Cause: Template google-services.json

If you haven't replaced the template `google-services.json` with your real Firebase configuration file, the app will:
1. Try to initialize Firebase
2. Fail (because the template has dummy values)
3. Continue running (we have error handling)
4. **But might show blank or crash**

### Solution:

1. **Check your google-services.json:**
   ```bash
   cat android/app/google-services.json
   ```
   
   If you see values like `"YOUR_PROJECT_NUMBER"` or `"YOUR_API_KEY_HERE"`, it's still the template.

2. **Get your REAL google-services.json:**
   - Go to https://console.firebase.google.com/
   - Select your project (or create one)
   - Click Settings (⚙️) → Project settings
   - Scroll to "Your apps" section
   - Click on your Android app (or add one if needed)
   - Package name: `com.example.electrocom`
   - Download `google-services.json`
   - **Replace** `android/app/google-services.json` with the downloaded file

3. **Rebuild the app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## 📱 Check What's Happening

### View Real-Time Logs

Open a new terminal and run:
```bash
flutter logs
```

Or use Android Studio/VS Code debugger to see console output.

### Look for These Messages in Logs:

**✅ Good (Firebase working):**
```
✅ Firebase initialized successfully
```

**⚠️ Problem (Firebase failed):**
```
⚠️ Firebase initialization failed: [SOME ERROR]
```

---

## 🐛 Other Possible Causes

### 1. App Takes Time to Load
- **Wait 10-30 seconds** after installation
- The app might be doing initial setup
- Check device screen - don't close it

### 2. Check Device Connection
```bash
# List connected devices
flutter devices

# If device not showing, reconnect USB or restart ADB
adb kill-server
adb start-server
flutter devices
```

### 3. App Crashed on Startup

Check logs for errors:
```bash
flutter logs | grep -i error
```

Common errors:
- Firebase initialization failed
- Network permission denied
- Missing permissions

### 4. Hot Restart vs Fresh Install

Try a fresh install:
```bash
# Uninstall from device first
adb uninstall com.example.electrocom

# Then reinstall
flutter run
```

---

## 🎯 Quick Checklist

Before reporting issues, verify:

- [ ] **Real google-services.json** in place (not template)
- [ ] Device connected and authorized (check `flutter devices`)
- [ ] Internet connection active on device
- [ ] App has permissions (Internet, Network State)
- [ ] Checked logs with `flutter logs`
- [ ] Tried clean rebuild: `flutter clean && flutter pub get && flutter run`
- [ ] Waited at least 30 seconds after install

---

## 🔍 Debug Mode

Run with verbose logging:
```bash
flutter run --verbose
```

This will show detailed information about:
- Build process
- Installation
- App startup
- Firebase initialization
- Any errors or warnings

---

## ✅ Expected Behavior

When everything works correctly:

1. App installs on device
2. Login screen appears with dark theme
3. You see:
   - "Electrocom" logo
   - "Employee Management System" text
   - Mobile number input field
   - Password input field
   - "Sign In" button
   - "Forgot Password?" and "Help" links

If you see this, the app is working! 🎉

---

## 🆘 Still Having Issues?

### Check These Files:

1. **android/app/google-services.json**
   - Must be REAL file from Firebase (not template)
   - Package name must match: `com.example.electrocom`

2. **android/app/src/main/AndroidManifest.xml**
   - Should have Internet permissions ✅ (already added)

3. **lib/main.dart**
   - Should have Firebase error handling ✅ (already there)

### Get Full Error Details:

```bash
# Terminal 1: Run the app
flutter run --verbose

# Terminal 2: Watch logs
flutter logs

# Or combine:
flutter run --verbose 2>&1 | tee app-debug.log
```

Then check `app-debug.log` file for errors.

---

## 💡 Quick Test Without Firebase

If you want to test the app WITHOUT Firebase temporarily:

1. Open `lib/main.dart`
2. Comment out the Firebase initialization:
   ```dart
   // try {
   //   await Firebase.initializeApp();
   //   ...
   // } catch (e) {
   //   ...
   // }
   ```

3. Rebuild and run:
   ```bash
   flutter run
   ```

This will let you see if the UI works without Firebase.

---

## 📞 Next Steps

1. ✅ **Replace google-services.json** with real file
2. ✅ **Run** `flutter clean && flutter pub get && flutter run`
3. ✅ **Wait 30 seconds** after installation
4. ✅ **Check logs** with `flutter logs`
5. ✅ **Report specific errors** if it still doesn't work

---

**Remember:** The app DID build successfully. The blank screen is likely due to the template google-services.json file. Once you replace it with the real Firebase configuration, everything should work!
