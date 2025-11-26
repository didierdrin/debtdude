# DebtDude - Smart Debt Management App

A Flutter-based mobile application that automatically tracks financial transactions through SMS parsing and provides intelligent debt management features.

## Overview

DebtDude is an innovative financial management application that leverages SMS message parsing to automatically track money transactions from popular mobile money services in Rwanda (M-Money, Mokash, AirtelMoney). The app provides users with real-time insights into their financial activities and helps manage debts effectively.

## Key Features

### 📱 Automatic SMS Parsing
- Real-time SMS monitoring for financial transactions
- Support for M-Money, Mokash, and AirtelMoney services
- Automatic categorization of incoming/outgoing money
- Balance tracking from SMS notifications

### 💰 Transaction Management
- Automatic transaction categorization (received, sent, vendor payments, loans)
- Real-time balance updates
- Transaction history with detailed information
- Firebase cloud storage for data persistence

### 🔔 Smart Notifications
- Categorized notifications (Withdraw, Received, Tracking)
- Real-time transaction alerts
- Payment due reminders
- Overdue payment warnings

### 💬 AI-Powered Chat
- Intelligent financial advice
- Transaction queries and insights
- Debt management recommendations
- Natural language processing for financial queries

### 📊 Analytics & Insights
- Spending pattern analysis
- Income vs expense tracking
- Visual charts and statistics
- Financial health monitoring

## Technical Architecture

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: BLoC/Cubit pattern
- **UI Components**: Material Design
- **Navigation**: Flutter Navigator 2.0

### Backend Services
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Cloud Functions**: Firebase Functions
- **Real-time Updates**: Firebase Realtime Database

### SMS Processing
- **SMS Reading**: flutter_sms_inbox package
- **Permissions**: permission_handler
- **Pattern Matching**: RegExp for transaction parsing
- **Real-time Processing**: SMS broadcast receivers

## Project's File Structure


lib/
├── cubits/                 # State management
│   ├── auth_cubit.dart
│   ├── chat_cubit.dart
│   ├── conversation_cubit.dart
│   └── save_firebase_cubit.dart
├── screens/                # UI screens
│   ├── home_screen.dart
│   ├── notifications_screen.dart
│   ├── chat_screen.dart
│   ├── profile_screen.dart
│   └── stats_screen.dart
├── services/               # Business logic
│   ├── sms_service.dart
│   └── api_service.dart
├── widgets/                # Reusable components
└── main.dart              # App entry point


## Installation & Setup

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio / VS Code
- Firebase project setup
- Android device/emulator (API level 21+)

### Setup Steps

1. **Clone the repository**
```bash
git clone https://github.com/didierdrin/debtdude.git
cd debtdude
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Configuration**
- Create a Firebase project
- Add Android app to Firebase
- Download `google-services.json` to `android/app/`
- Enable Firestore, Authentication, and Functions

4. **Android Permissions**
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.RECEIVE_SMS" />
```

5. **Run the application**
```bash
flutter run
```

## SMS Integration

### Supported Services
- **M-Money**: Rwanda's mobile money service
- **Mokash**: Micro-lending platform
- **AirtelMoney**: Airtel's mobile money service

### Transaction Types Detected
- Money received from contacts
- Money sent to contacts
- Vendor payments
- Loan disbursements
- Loan repayments
- Balance inquiries

## Security & Privacy

- SMS data is processed locally on device
- Only financial transaction SMS are parsed
- User data encrypted in Firebase
- No SMS content stored permanently
- Secure authentication with Firebase Auth

## Future Enhancements

- [ ] Machine learning for spending predictions
- [ ] Integration with bank APIs
- [ ] Multi-currency support
- [ ] Expense categorization AI
- [ ] Social debt sharing features
- [ ] Advanced analytics dashboard

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

**Developer**: Group 22 
**Email**: [your-email@example.com]  
**GitHub**: [@didierdrin](https://github.com/didierdrin)

---

*DebtDude - Making financial management smarter, one SMS at a time.*