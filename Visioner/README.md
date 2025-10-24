# Visioner - Emotional/Spiritual Vision Board App

## 📁 Project Structure

```
Visioner/
├── VisionerApp.swift                 # Main app entry point
├── Assets.xcassets/                  # App icons, colors, images
├── Visioner.xcdatamodeld/           # Core Data model
│
├── Views/                           # SwiftUI Views
│   ├── Main/                        # Main app views
│   │   └── ContentView.swift        # Primary app interface
│   │
│   ├── Onboarding/                  # Onboarding flow views
│   │   ├── OnboardingView.swift     # Initial onboarding page
│   │   ├── EtherealOnboardingView.swift  # "Perfect 🌙" ethereal page
│   │   └── OnboardingFlowView.swift # Transition management
│   │
│   ├── Components/                  # Reusable UI components
│   │   └── (Future components)
│   │
│   └── Preview/                     # Development & testing views
│       ├── FontTestView.swift       # Font testing interface
│       └── FontDebugView.swift      # Font debugging tools
│
├── Services/                        # Business logic & data services
│   ├── OnboardingManager.swift      # Onboarding state management
│   ├── Persistence.swift           # Core Data persistence
│   ├── FontLoader.swift            # Custom font loading
│   ├── ThemeManager.swift          # App theming system
│   └── AppTypography.swift         # Typography system
│
├── Models/                          # Data models
│   └── (Future data models)
│
├── Utils/                           # Utility functions
│   └── (Future utilities)
│
├── Extensions/                      # Swift extensions
│   └── (Future extensions)
│
└── Resources/                       # App resources
    ├── Fonts/                       # Custom font files
    │   ├── Fraunces_72pt_Soft-SemiBold.ttf
    │   ├── Inter_28pt-Light.ttf
    │   ├── Inter_28pt-Medium.ttf
    │   ├── NunitoSans-VariableFont_YTLC,opsz,wdth,wght.ttf
    │   └── PlayfairDisplay-Regular.ttf
    └── Assets/                      # Additional assets
        └── (Future assets)
```

## 🎨 Design System

### Themes
- **Lavender Dreams**: Primary theme with soft, calming colors
- **Perfect 🌙**: Ethereal theme for sacred moments

### Typography
- **Fraunces SemiBold**: App branding and headers
- **Playfair Display**: Elegant quotes and ethereal text
- **Inter Light/Medium**: UI text and buttons
- **Nunito Sans**: Body text and general content

### Color Palette
- **Primary**: #7C64B2 (Lavender)
- **Secondary**: #C4B1E6 (Soft Lavender)
- **Background**: #F4EFFC (Light Lavender)
- **Accent**: #E9A8D0 (Pink)
- **Accent Strong**: #4A3A6B (Deep Plum)

## 🚀 Features

### Onboarding Flow
1. **Initial Onboarding**: Grounded, earthly introduction
2. **Transition**: Magical morphing between themes
3. **Ethereal Onboarding**: Sacred space preparation
4. **Main App**: Vision board creation interface

### Technical Features
- **MVVM Architecture**: Clean separation of concerns
- **Custom Font System**: Consistent typography
- **Theme Management**: Dynamic color theming
- **Core Data**: Local data persistence
- **iOS 16+**: Modern SwiftUI implementation

## 🛠 Development

### Building
```bash
xcodebuild -project Visioner.xcodeproj -scheme Visioner build
```

### Testing
- Use FontTestView for typography testing
- Use FontDebugView for font debugging
- Reset onboarding via ContentView button

## 📱 Deployment
- **Target**: iOS 16.0+
- **Architecture**: MVVM with SwiftUI
- **Data**: Core Data with local persistence
