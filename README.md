Welcome to the **EV Charging App**, an open-source iOS application built with UIKit for discovering and managing electric vehicle (EV) charging stations. This app is designed to be white-labeled, allowing companies to customize it with their branding, configure backend services (e.g., Firebase), and publish it to the App Store.

## Features
- **Charger Locator**: Find nearby EV charging stations using an interactive map.
- **User Authentication**: Sign in/out with Email.
- **Station Details**: View charger availability, type, and pricing.
- **White-Label Ready**: Easily customize UI, colors, and logos for your brand.

## Prerequisites
- **Xcode**: Version 15.0 or later.
- **iOS**: Minimum deployment target of iOS 13.0.
- **Firebase Account**: Required for analytics.
- **CocoaPods**: Dependency manager (or use Swift Package Manager if preferred).

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/powerly-ev/open-ev-charge-ios-app.git
cd <your-repo-name>

### 2. Install Dependencies
Using CocoaPods:
```bash
pod install
```
Open the `.xcworkspace` file in Xcode.

### 3. Configure Firebase
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Download the `GoogleService-Info.plist` file.
3. Add it to the root of your Xcode project.
4. Enable Firebase services (e.g., Authentication, Firestore) in the Firebase console.
5. Update `AppDelegate.swift` or equivalent to initialize Firebase:
   ```swift
   import Firebase
   FirebaseApp.configure()
   ```

### 4. White-Labeling
To customize the app for your company:
- **Branding**: Replace assets in `Assets.xcassets` (e.g., app icon, logo).
- **Colors**: Update `UIColor` values in `Assets.xcassets/Color` or equivalent.
- **Strings**: Modify `Localizable.strings` for app-specific text.
- **Bundle ID**: Change the bundle identifier in `Config/OpenSource` to match your App Store account.

### 5. Build and Run
- Open `Powerly.xcworkspace` in Xcode.
- Select your target device/simulator.
- Press `Cmd + R` to build and run.

## Contributing
We welcome contributions! Please follow these steps:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/<your-feature>`).
3. Commit changes using the [commit message guidelines](#commit-message-guidelines).
4. Push to your fork (`git push origin feature/<your-feature>`).
5. Open a pull request.

### Commit Message Guidelines
Use this format: `<type>(<scope>): <description>`. Examples:
- `feat(map): add charger filtering by type`
- `fix(firestore): handle null data gracefully`
See [COMMIT_GUIDELINES.md](COMMIT_GUIDELINES.md) for details.

## White-Labeling Guide
Companies can use this app as a base for their own branded EV charging solution:
1. **Firebase Setup**: Replace `GoogleService-Info.plist` with your own.
2. **API Keys**: Configure any third-party APIs (e.g., Google Maps) in `Config/OpenSource`.
3. **App Store**: Update provisioning profiles and submit under your account.
4. **Analytics**: Enable Firebase Analytics or integrate your preferred tool.

## License Information
This project is released under a [dual-license model](LICENSE):
1. **Apache 2.0 License** (for open-source usage):
   - You are free to use, modify, and distribute this software under Apache 2.0.
   - You must remove all Powerly branding (name, logo, API keys) if you fork or modify the software.
   - Read the full [Apache 2.0 License](LICENSE) file for details.
2. **Enterprise Commercial License** (for premium features & business use):
   - AI-powered analytics, priority API access, and enterprise support require a paid subscription.
   - Commercial use of Powerly’s backend requires explicit approval and an Enterprise License.
   - To request an Enterprise License, contact [sales@powerly.app](mailto:sales@powerly.app).

## Support
For issues or questions:
- Open an issue on GitHub.
- Contact the maintainers at jaydeep@powerly.app.
