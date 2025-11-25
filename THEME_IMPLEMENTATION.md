# Theme Implementation - Dark Mode & Light Mode

## Overview
DebtDude now supports both light and dark themes with automatic system theme detection.

## Features Added

### 1. Theme Management
- **ThemeCubit**: Manages theme state using BLoC pattern
- **AppTheme**: Centralized theme configuration
- **ThemeToggle**: Reusable widget for theme switching

### 2. Theme Options
- **Light Mode**: Clean white background with blue accents
- **Dark Mode**: Dark background with appropriate contrast
- **System Mode**: Follows device system theme (default)

### 3. Usage

#### Toggle Theme Programmatically
```dart
context.read<ThemeCubit>().toggleTheme();
```

#### Set Specific Theme
```dart
context.read<ThemeCubit>().setTheme(ThemeMode.dark);
context.read<ThemeCubit>().setTheme(ThemeMode.light);
context.read<ThemeCubit>().setTheme(ThemeMode.system);
```

#### Use Theme Toggle Widget
```dart
import 'package:debtdude/widgets/theme_toggle.dart';

// Add to any screen
const ThemeToggle()
```

### 4. Theme-Aware Widgets
Replace hardcoded colors with theme-aware alternatives:

```dart
// Instead of
color: Colors.white

// Use
color: Theme.of(context).cardColor

// Instead of  
color: Colors.black

// Use
color: Theme.of(context).textTheme.bodyLarge?.color
```

### 5. Implementation Locations
- **Home Screen**: Theme toggle in header
- **Profile Screen**: Dark mode switch in settings
- **All Screens**: Automatic theme adaptation

### 6. Files Modified/Added
- `lib/cubits/theme_cubit.dart` - Theme state management
- `lib/cubits/theme_state.dart` - Theme state definition
- `lib/theme/app_theme.dart` - Theme configuration
- `lib/widgets/theme_toggle.dart` - Theme toggle widget
- `lib/main.dart` - Theme integration
- `lib/screens/home_screen.dart` - Theme toggle + theme-aware colors
- `lib/screens/profile_screen.dart` - Dark mode setting

The theme system is now fully integrated and ready to use!