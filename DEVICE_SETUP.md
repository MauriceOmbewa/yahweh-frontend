# Running on Physical Devices

## 1. Start the backend
```bash
cd /Users/apple/Desktop/Github/Yahweh-backend
./mvnw spring-boot:run
```
Backend runs at http://localhost:8080

## 2. Set the correct API URL in the Flutter app

Open `lib/services/api_config.dart` and change `baseUrl`:

| Where you're running | baseUrl value |
|---|---|
| Android emulator | `http://10.0.2.2:8080` |
| iOS simulator | `http://localhost:8080` |
| Physical Android/iOS on same WiFi | `http://YOUR_MAC_IP:8080` |
| Production | `https://api.yahweh.app` |

### Find your Mac's local IP
```bash
ipconfig getifaddr en0
# e.g. 192.168.1.45
# → set baseUrl = 'http://192.168.1.45:8080'
```

## 3. Run the Flutter app

### Android (emulator or physical)
```bash
flutter run
```

### iOS (simulator or physical)
```bash
flutter run
```

### Both simultaneously
```bash
flutter run -d all
```

## 4. Testing on physical device (iOS)
- Connect iPhone via USB
- Trust the Mac on the phone
- Run `flutter devices` to confirm it's detected
- Run `flutter run`

## 5. Testing on physical device (Android)
- Enable Developer Options → USB Debugging on the phone
- Connect via USB
- Run `flutter devices` then `flutter run`
