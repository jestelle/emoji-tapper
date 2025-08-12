# Emoji Tapper Android

An Android port of the Emoji Tapper game, built with Kotlin and Jetpack Compose.

## Game Description

Emoji Tapper is a fast-paced tapping game where players must tap emojis to score points and earn time. The Android version features two game modes:

- **Classic Mode**: Tap emojis to score points and extend your time. Avoid the skull emoji!
- **Penguin Ball Mode**: Find the penguin among many emojis in 5 rounds (coming soon)

## Features

- **Modern Android UI** with Material Design 3 and Jetpack Compose
- **Responsive gameplay** with smooth animations and touch handling  
- **High score tracking** with persistent storage using SharedPreferences
- **Multiple game modes** supporting different play styles
- **Comprehensive testing** with unit tests and UI tests

## Setup Instructions

### Prerequisites

1. **Android Studio** (latest stable version recommended)
   - Download from [https://developer.android.com/studio](https://developer.android.com/studio)
   
2. **Android SDK** (automatically installed with Android Studio)
   - Minimum SDK: API 24 (Android 7.0)
   - Target SDK: API 34 (Android 14)

3. **Java Development Kit (JDK)**
   - JDK 8 or higher
   - Usually bundled with Android Studio

### Local Development Setup

1. **Clone and Navigate to Android Project**
   ```bash
   cd EmojiTapperAndroid
   ```

2. **Configure Android SDK Path**
   - Create/edit `local.properties` file in the project root
   - Add your Android SDK path:
     ```properties
     sdk.dir=/path/to/your/Android/Sdk
     ```
   - On macOS: Usually `/Users/[username]/Library/Android/sdk`
   - On Windows: Usually `C:\Users\[username]\AppData\Local\Android\Sdk`
   - On Linux: Usually `/home/[username]/Android/Sdk`

3. **Open Project in Android Studio**
   ```bash
   open -a "Android Studio" .
   # Or launch Android Studio and open the EmojiTapperAndroid folder
   ```

4. **Sync Project**
   - Android Studio will automatically sync Gradle dependencies
   - If not, click "Sync Now" or go to File → Sync Project with Gradle Files

### Building the Project

#### Using Android Studio
1. Select your build variant (debug/release) from the Build Variants panel
2. Build → Make Project (Ctrl+F9 / Cmd+F9)

#### Using Command Line
```bash
# Debug build
./gradlew assembleDebug

# Release build  
./gradlew assembleRelease

# Clean and build
./gradlew clean assembleDebug
```

### Running the App

#### On Emulator
1. **Create Android Virtual Device (AVD)**
   - Tools → AVD Manager → Create Virtual Device
   - Choose a device (Pixel 6 recommended)
   - Select API 34 (Android 14) system image
   - Follow setup wizard

2. **Run the App**
   - Click the green play button in Android Studio
   - Or use: `./gradlew installDebug`

#### On Physical Device
1. **Enable Developer Options**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. **Connect Device**
   - Connect via USB cable
   - Accept USB debugging prompt on device

3. **Install and Run**
   - Click the green play button in Android Studio
   - Or use: `./gradlew installDebug`

### Testing

#### Unit Tests
```bash
./gradlew test
```

#### Instrumentation Tests (UI Tests)
```bash
./gradlew connectedAndroidTest
```

#### Run Tests in Android Studio
- Right-click on test files/folders → Run Tests
- View → Tool Windows → Test Results

### Troubleshooting

#### Common Issues

1. **Gradle Sync Issues**
   ```bash
   ./gradlew --refresh-dependencies
   ```

2. **Build Cache Issues**
   ```bash
   ./gradlew clean
   ```

3. **SDK Path Issues**
   - Verify `local.properties` has correct SDK path
   - In Android Studio: File → Project Structure → SDK Location

4. **Emulator Performance Issues**
   - Enable Hardware Acceleration in AVD settings
   - Increase allocated RAM for emulator
   - Use x86_64 system images when possible

5. **Device Connection Issues**
   - Try different USB cable/port
   - Restart ADB: `adb kill-server && adb start-server`
   - Check device is authorized: `adb devices`

#### Performance Tips

- Use x86_64 emulator images for better performance
- Enable instant run in Android Studio settings  
- Close unnecessary apps when testing on device
- Use debug builds for development (faster compilation)

### Project Structure

```
app/src/main/java/com/emojitapper/
├── MainActivity.kt              # App entry point
├── game/                       # Game logic
│   ├── ClassicGameEngine.kt    # Classic mode implementation  
│   └── GameState.kt           # Game state management
├── models/                     # Data models
│   ├── GameMode.kt            # Game mode definitions
│   ├── GameEmoji.kt           # Emoji data structures
│   └── GameLevel.kt           # Level configurations
├── ui/                        # UI components
│   ├── EmojiTapperApp.kt      # Main app composable
│   ├── screens/               # Screen composables
│   ├── components/            # Reusable UI components
│   └── theme/                 # App theming
└── utils/                     # Utility classes
    └── EmojiPositioner.kt     # Emoji positioning logic
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and add tests
4. Run tests: `./gradlew test connectedAndroidTest`
5. Commit changes: `git commit -am 'Add feature'`
6. Push to branch: `git push origin feature-name`
7. Submit a Pull Request

## License

This project is part of the Emoji Tapper game suite. See the main project LICENSE file for details.