# Team Streem Realm - iOS App Setup Guide

## 🎮 Overview

This iOS app lets your kids track your Minecraft mega-build progress! Features two modes:
- **Kids Mode** (iPad): Spectator dashboard showing build progress, zones, sessions, and materials
- **Dad Mode** (iPhone): Command center with Claude AI integration for database management

## 📱 Requirements

- Xcode 14.0+
- iOS 15.0+ target (supports older iPads)
- Swift 5.7+
- Apple Developer account (for device deployment)

## 🚀 Quick Start

### 1. Open the Project
```bash
open "/Users/matthewstreem/Development/TeamStreemRealm/Team Streem Realm/Team Streem Realm.xcodeproj"
```

### 2. Add New Files to Xcode

Since files were created outside Xcode, you need to add them to the project:

1. In Xcode, right-click on the **Team Streem Realm** folder in the navigator
2. Select **Add Files to "Team Streem Realm"...**
3. Navigate to the project folder and select these folders:
   - `Services/` (contains AirtableService.swift, ClaudeService.swift)
   - `Theme/` (contains MinecraftTheme.swift)
   - `Views/` (contains Kids/ and Dad/ subfolders)
4. Check ✅ "Copy items if needed"
5. Check ✅ "Create groups"
6. Click **Add**

### 3. Project Structure

After adding files, your project should look like:

```
Team Streem Realm/
├── Team_Streem_RealmApp.swift     # Main app entry point
├── ContentView.swift               # (Can delete - unused)
├── Models/
│   ├── Zone.swift
│   ├── Structure.swift
│   ├── BuildSession.swift
│   ├── Material.swift
│   └── AirtableRecord.swift
├── Services/
│   ├── AirtableService.swift       # Airtable API
│   └── ClaudeService.swift         # Claude AI integration
├── Theme/
│   └── MinecraftTheme.swift        # Colors, styles, haptics
├── Views/
│   ├── Kids/
│   │   ├── KidsDashboardView.swift
│   │   ├── KidsZonesView.swift
│   │   ├── KidsSessionsView.swift
│   │   └── KidsMaterialsView.swift
│   └── Dad/
│       ├── DadDashboardView.swift
│       ├── DadCommandCenterView.swift
│       ├── DadChatView.swift
│       ├── DadDatabaseView.swift
│       └── DadSettingsView.swift
└── Assets.xcassets/
    ├── AccentColor.colorset/
    ├── AppIcon.appiconset/
    ├── Prismarine.colorset/
    ├── Diamond.colorset/
    ├── Emerald.colorset/
    ├── Gold.colorset/
    ├── Amethyst.colorset/
    ├── Stone.colorset/
    ├── Redstone.colorset/
    └── Lapis.colorset/
```

### 4. Configure Signing

1. Select the project in the navigator
2. Select the **Team Streem Realm** target
3. Go to **Signing & Capabilities**
4. Select your Team
5. Change Bundle Identifier to something unique (e.g., `com.yourname.teamstreemrealm`)

### 5. Set Deployment Target

1. In project settings, ensure **iOS Deployment Target** is set to **15.0**
2. This ensures compatibility with older iPads

## 🔐 API Configuration

### Airtable (Already Configured)

The Airtable credentials are already in `AirtableService.swift`:
- Base ID: `appmul5QQ7fC0RlfB`
- API Key: Already embedded

### Claude API (Dad Mode Only)

To enable Claude AI chat features:

1. Get an API key from [console.anthropic.com](https://console.anthropic.com)
2. In the app, go to **Dad Mode** → **Settings**
3. Enter your Claude API key
4. It's stored locally on the device

## 🎯 App Modes

### Switching Modes

- **Shake the device** to toggle between Kids and Dad modes
- The current mode is saved between app launches

### Kids Mode Features
- 📊 Dashboard with overall progress
- 🗺️ Zone cards with progress tracking
- 📝 Build session timeline
- 🧱 Materials database with block info

### Dad Mode Features
- 🎮 Command Center for quick actions
- 🤖 Claude AI chat for natural language database updates
- 💾 Full database viewer
- 👁️ Kids preview mode

## 📲 Deploying to Devices

### For Development Testing

1. Connect your iPhone/iPad via USB
2. Select your device in Xcode's device selector
3. Click ▶️ Run
4. Trust the developer on the device: Settings → General → VPN & Device Management

### For Family Deployment (Ad Hoc)

1. Archive the app: Product → Archive
2. Distribute App → Ad Hoc
3. Export the IPA
4. Use Apple Configurator 2 or Xcode to install on family devices

### For TestFlight (Recommended)

1. Archive the app
2. Upload to App Store Connect
3. Add family members to internal testing
4. They can install via TestFlight app

## 🐛 Troubleshooting

### "Cannot find type 'Color' in scope"
Make sure `import SwiftUI` is at the top of each file.

### Color assets not found
Check that all colorset folders are properly added to Assets.xcassets.

### API errors
Check Airtable credentials and ensure you have internet connectivity.

### Build errors about missing files
Re-add the files to the project using the steps in section 2.

## 🎨 Customization

### Adding New Block Images

Block images are fetched from URLs. To add new blocks, edit `Material.swift`:

```swift
"New Block": BlockData(
    imageUrl: "https://mc.nerothe.com/img/1.21.4/new_block.png",
    emoji: "🆕",
    description: "Description for kids",
    trivia: "Fun fact about the block",
    rarity: .common // .uncommon, .rare, .epic, .legendary
)
```

### Changing Colors

Edit the colorsets in Assets.xcassets or modify the Color extensions in `MinecraftTheme.swift`.

## 📞 Support

If you run into issues:
1. Check the Console in Xcode for error messages
2. Ensure all files are added to the project
3. Clean build folder: Product → Clean Build Folder
4. Delete derived data: ~/Library/Developer/Xcode/DerivedData

---

Happy Building! 🏗️⛏️🎮
