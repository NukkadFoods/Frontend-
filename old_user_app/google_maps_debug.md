# Google Maps Debug Checklist

## Current Status
- ✅ Maps SDK for iOS - Enabled
- ✅ Maps SDK for Android - Enabled  
- ✅ Geocoding API - Enabled
- ✅ Directions API - Enabled
- ❌ Android Maps not rendering (iOS unknown)
- ✅ Markers/Icons showing (suggests API key works)

## Common Google Cloud Console Issues

### 1. API Key Restrictions
**Check**: Go to Google Cloud Console > APIs & Services > Credentials > Your API Key

**Current API Key**: `AIzaSyCsZ1wSI0CdaLU35oH4l4dhQrz7TjBSYTw`

**Common Issues**:
- Application restrictions set too strictly
- Android package name restrictions
- Referrer restrictions blocking requests

**Fix**: Temporarily set to "None" for testing

### 2. Billing Issues
**Check**: Google Cloud Console > Billing

**Common Issues**:
- Billing disabled or suspended
- Free tier quota exceeded
- Credit card expired

**Fix**: Ensure billing is active and has available credits

### 3. API Quotas
**Check**: Google Cloud Console > APIs & Services > Dashboard

**Look for**:
- Daily quota exceeded
- Requests per minute limits
- Error rates

### 4. Android-Specific Issues

**Check these files**:
- `android/app/src/main/AndroidManifest.xml` - API key configured?
- `android/app/build.gradle` - correct package name?

**Common Android Issues**:
- SHA-1 fingerprint not added to API key
- Package name mismatch
- ProGuard stripping Maps SDK

## Quick Fixes to Try

### Fix 1: Remove API Key Restrictions (Temporary)
1. Go to Google Cloud Console
2. APIs & Services > Credentials
3. Click your API key
4. Set "Application restrictions" to "None"
5. Save and test

### Fix 2: Check Android Package Name
1. Verify package name in `android/app/build.gradle`
2. Should be: `com.nukkadfoods.user`
3. Ensure it matches in Google Cloud Console

### Fix 3: Add SHA-1 Fingerprint
```bash
cd android
./gradlew signingReport
```
Copy the SHA-1 and add to Google Cloud Console API key

### Fix 4: Clear Flutter Cache
```bash
flutter clean
cd ios && rm -rf Pods && pod install
cd ../android && ./gradlew clean
flutter pub get
```

## Debug Commands to Run
```bash
# Check API key in Android manifest
grep -r "AIzaSy" android/

# Check package name
grep "applicationId" android/app/build.gradle

# Get SHA-1 fingerprint
cd android && ./gradlew signingReport
```