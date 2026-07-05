# iOS Push Notifications Setup Guide

## ✅ What's Already Configured

1. **Entitlements File** - Created at `ios/Runner/Runner.entitlements`
2. **Xcode Project** - `CODE_SIGN_ENTITLEMENTS` added to all build configurations
3. **AppDelegate** - Updated with manual APNs registration code
4. **Flutter Code** - Added APNs token waiting logic with timeout

## 📋 Required Manual Steps in Xcode

### Step 1: Open Xcode Project
```bash
cd ios
open Runner.xcworkspace
```

### Step 2: Add Push Notifications Capability

1. Select **Runner** target in the project navigator
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** button
4. Search for and add **Push Notifications**

### Step 3: Configure App ID in Apple Developer Portal

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list)
2. Find your App ID (e.g., `com.yourcompany.solarhub`)
3. Click to edit
4. Enable **Push Notifications** capability
5. Save changes

### Step 4: Configure Provisioning Profile

1. Go to [Provisioning Profiles](https://developer.apple.com/account/resources/profiles/list)
2. Edit your development provisioning profile
3. Make sure it includes the App ID with Push Notifications
4. Download and install the updated profile
5. In Xcode, select the updated provisioning profile

### Step 5: For Production (When Ready)

Edit `ios/Runner/Runner.entitlements` and change:
```xml
<key>aps-environment</key>
<string>development</string>
```
to:
```xml
<key>aps-environment</key>
<string>production</string>
```

## 🧪 Testing

After completing the setup:

1. **Clean build**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Check logs** - You should see:
   - ✅ Notification permission granted
   - ✅ APNs token received: [token]...
   - ✅ FCM token synced

3. **Test notifications** - Send a test notification from Firebase Console

## ❌ Common Issues

### "APNs token not available"
- **Cause**: Missing Push Notifications capability in Xcode
- **Fix**: Follow Step 2 above

### "No APNs environment in entitlements"
- **Cause**: Wrong or missing entitlements file
- **Fix**: Ensure `Runner.entitlements` exists and has `aps-environment` key

### "Invalid provisioning profile"
- **Cause**: Profile doesn't include Push Notifications capability
- **Fix**: Recreate provisioning profile after enabling Push Notifications in App ID

### Notifications work in development but not production
- **Cause**: Using development entitlement in production build
- **Fix**: Change `aps-environment` to `production` before building for App Store

## 🔧 Additional Configuration (Optional)

### Background Notifications
Already configured in `Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### Notification Categories (for actionable notifications)
Add to `AppDelegate.swift` if needed:
```swift
func setupNotificationCategories() {
    let acceptAction = UNNotificationAction(
        identifier: "ACCEPT",
        title: "Accept",
        options: .foreground
    )
    
    let category = UNNotificationCategory(
        identifier: "INVITATION_CATEGORY",
        actions: [acceptAction],
        intentIdentifiers: [],
        options: []
    )
    
    UNUserNotificationCenter.current().setNotificationCategories([category])
}
```

## 📚 Resources

- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Apple Push Notifications Guide](https://developer.apple.com/documentation/usernotifications/registering_your_app_with_apns)
- [Flutter Firebase Setup](https://firebase.flutter.dev/docs/installation/apple/)
