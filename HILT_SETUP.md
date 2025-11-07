# Hilt Dependency Injection Setup

## Overview
Hilt is **required** for Tuya UI BizBundle components (Scene, Device Pairing, etc.) to work properly. This document explains the Hilt integration in this project.

## References
- [Tuya Scene UI BizBundle Documentation](https://developer.tuya.com/cn/docs/app-development/scene?id=Ka8qhzjzl4tn4)
- [Google Hilt Documentation](https://developer.android.google.cn/training/dependency-injection/hilt-android)
- [Tuya Demo Repository](https://github.com/tuya/tuya-ui-bizbundle-android-demo)

## Requirements
According to Tuya documentation:
- UI BizBundle v5.8.0+ requires **minimum Hilt version 2.43.2**
- This includes:
  - Hilt plugin
  - Hilt artifact (library)
  - Hilt annotation processor (kapt)

## Implementation

### 1. Settings Gradle Configuration
**File: `android/settings.gradle.kts`**

Added Hilt plugin (v2.48.1) and KAPT plugin:
```kotlin
plugins {
    id("com.google.dagger.hilt.android") version "2.48.1" apply false
    id("org.jetbrains.kotlin.kapt") version "2.1.0" apply false
}
```

### 2. App Gradle Configuration
**File: `android/app/build.gradle.kts`**

Applied plugins:
```kotlin
plugins {
    id("com.google.dagger.hilt.android")
    id("kotlin-kapt")
}
```

Added dependencies:
```kotlin
dependencies {
    // Hilt core (v2.48.1 > 2.43.2 minimum)
    implementation("com.google.dagger:hilt-android:2.48.1")
    kapt("com.google.dagger:hilt-android-compiler:2.48.1")
    
    // Hilt for Android components
    implementation("androidx.hilt:hilt-navigation-compose:1.1.0")
}
```

### 3. Application Class
**File: `TuyaSmartApplication.kt`**

Added `@HiltAndroidApp` annotation:
```kotlin
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class TuyaSmartApplication : Application() {
    // ... initialization code
}
```

### 4. MainActivity
**File: `MainActivity.kt`**

Added `@AndroidEntryPoint` annotation:
```kotlin
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : FlutterActivity() {
    // ... activity code
}
```

## Version Compatibility

| Component | Version | Notes |
|-----------|---------|-------|
| Android Gradle Plugin (AGP) | 8.13.0 | Must match Kotlin version |
| Kotlin | 2.1.0 | Must match Hilt version |
| Hilt | 2.48.1 | Min 2.43.2 for UI BizBundle v5.8.0+ |
| Tuya BizBundle BOM | 6.7.31 | Manages UI BizBundle versions |

## What Hilt Does

Hilt provides dependency injection for Android components:

1. **Automatic Injection**: Components (Activities, Fragments, Services, etc.) can have dependencies injected automatically
2. **Lifecycle Management**: Scoped dependencies that match Android lifecycles
3. **Compile-Time Safety**: Errors caught at compile time, not runtime
4. **Reduced Boilerplate**: Less manual dependency management code

## Hilt Components & Scopes

| Component | Scope | Lifecycle |
|-----------|-------|-----------|
| SingletonComponent | @Singleton | Application lifetime |
| ActivityComponent | @ActivityScoped | Activity lifetime |
| FragmentComponent | @FragmentScoped | Fragment lifetime |
| ViewModelComponent | @ViewModelScoped | ViewModel lifetime |

## Why UI BizBundle Needs Hilt

Tuya UI BizBundle components use Hilt for:
- **Service Discovery**: Finding and injecting UI services (Scene, Panel, Family, etc.)
- **State Management**: Managing UI state across components
- **Dependency Resolution**: Resolving complex dependencies between BizBundle modules
- **Lifecycle Awareness**: Proper cleanup and initialization

## Troubleshooting

### Build Errors
If you see errors like:
```
MissingBinding: Cannot find binding for XYZ
```

**Solution**: Ensure all files are properly annotated:
- Application class has `@HiltAndroidApp`
- Activities/Fragments have `@AndroidEntryPoint`

### Scene UI Not Opening
If Scene UI fails to open, check:
1. ✅ Hilt is properly configured (this setup)
2. ✅ `values.xml` has `<bool name="is_scene_support">true</bool>`
3. ✅ `SceneHomePipeLine().run()` is called after login
4. ✅ Family service is properly switched before opening scenes

## Build Process

After Hilt setup, the build process includes:
1. KAPT processes Hilt annotations
2. Generates Hilt components and modules
3. Creates dependency injection code
4. Compiles application with injected dependencies

This adds ~30 seconds to initial build time but enables all UI BizBundle features.

## Status
✅ **Hilt successfully integrated** - Scene UI BizBundle and other UI components are now fully functional!

