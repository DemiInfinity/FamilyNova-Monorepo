# FamilyNova Logo Integration

The FamilyNova logo has been integrated across all platforms!

## Logo File
- **Source**: `App_Icon-web.png` (root directory)
- **Description**: Vibrant, cartoonish logo with Earth character, moon, and "FAMILY NOVA" text

## Integration Status

### ✅ iOS Kids App
- Logo added to Assets.xcassets as "Logo"
- Used in LoginView
- Path: `apps/ios-kids/FamilyNovaKids/Resources/Assets.xcassets/Logo.imageset/`

### ✅ iOS Parent App
- Logo added to Assets.xcassets as "Logo"
- Used in LoginView
- Path: `apps/ios-parent/FamilyNovaParent/Resources/Assets.xcassets/Logo.imageset/`

### ✅ Android Kids App
- Logo copied to drawable resources
- Used in LoginActivity
- Path: `apps/android-kids/app/src/main/res/drawable/familynova_logo.png`

### ✅ Android Parent App
- Logo copied to drawable resources
- Path: `apps/android-parent/app/src/main/res/drawable/familynova_logo.png`

### ✅ Web App
- Logo added to public directory
- Used in Logo component
- Path: `apps/web/public/logo.png`

## Usage

### iOS
```swift
Image("Logo")
    .resizable()
    .scaledToFit()
    .frame(width: 200, height: 200)
```

### Android
```xml
<ImageView
    android:src="@drawable/familynova_logo"
    android:scaleType="fitCenter" />
```

### Web (Next.js)
```tsx
<Image
    src="/logo.png"
    alt="FamilyNova Logo"
    width={200}
    height={200}
/>
```

## Next Steps

1. **Replace App Icons**: Update the launcher icons in Android and iOS to use the logo
2. **Add to More Screens**: Consider adding logo to headers, splash screens, etc.
3. **Create Variants**: Consider creating different sizes/versions for different use cases

