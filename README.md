# Opei

**Opei** is a modern fintech mobile application that provides seamless access to USD financial tools, including currency exchange, P2P trading, virtual cards, and wallet management.

## Features

### ✅ Implemented
- **User Authentication** - Secure signup, login, email verification
- **Quick Auth** - PIN and biometric authentication for fast access
- **Wallet Management** - View balance, transaction history
- **Virtual Cards** - Create and manage USD virtual cards
- **P2P Exchange** - Buy and sell cryptocurrency peer-to-peer
- **Deposits & Withdrawals** - Multiple payment methods
- **Send Money** - Transfer funds to other users
- **KYC Verification** - Identity verification for compliance
- **Profile Management** - Address, security settings, logout
- **Legal Documents** - Terms & Conditions, Privacy Policy

### 🔐 Security
- Secure token storage (Keychain/Encrypted storage)
- Biometric authentication support
- Session management with auto-lock
- Sentry error tracking and monitoring
- End-to-end HTTPS communication

### 🎨 Design
- Clean, minimalist Apple-inspired UI
- Monochrome color palette (Black, White, Grey)
- Smooth animations and transitions
- Responsive layout system
- Custom Outfit font family

## Architecture

Built with **Clean Architecture** principles:

```
lib/
├── core/          # Infrastructure (API, storage, providers)
├── data/          # Models and repositories
├── features/      # Feature modules (auth, cards, p2p, etc.)
└── widgets/       # Reusable UI components
```

### Tech Stack
- **Framework**: Flutter 3.6+
- **State Management**: Riverpod 3.0
- **Routing**: GoRouter
- **HTTP Client**: Dio
- **Secure Storage**: flutter_secure_storage
- **Error Tracking**: Sentry
- **Authentication**: local_auth (biometrics)

## Getting Started

### Prerequisites
- Flutter SDK 3.6.0 or higher
- Dart SDK 3.6.0 or higher
- Android Studio / Xcode for respective platforms

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Opei-App-Flutter-main
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Development
   flutter run --flavor dev --dart-define=APP_ENV=dev

   # Staging
   flutter run --flavor staging --dart-define=APP_ENV=staging

   # Production
   flutter run --flavor prod --dart-define=APP_ENV=prod --dart-define=SENTRY_DSN=<your-sentry-dsn>
   ```

## Environment Configuration

Environment-specific values live in `lib/core/config/environment.dart`. The active environment defaults to `prod` but can be overridden with `--dart-define=APP_ENV=<dev|staging|prod>`.

- `APP_ENV` selects which config block (base URL, API version, default Sentry DSN) to load.
- Optional overrides: `--dart-define=API_BASE_URL=...` or `--dart-define=SENTRY_DSN=...` take precedence.
- Android build flavors (`dev`, `staging`, `prod`) are available with distinct `applicationId` suffixes and launcher labels.

Update the placeholder dev/staging URLs and DSNs before releasing.

## Project Structure

```
lib/
├── core/
│   ├── config/              # API configuration
│   ├── network/             # HTTP client, interceptors
│   ├── providers/           # Riverpod providers
│   ├── services/            # Business services
│   └── storage/             # Secure storage
├── data/
│   ├── models/              # Data models (JSON serializable)
│   └── repositories/        # API repositories
├── features/
│   ├── auth/                # Authentication flows
│   ├── cards/               # Virtual cards
│   ├── dashboard/           # Main dashboard
│   ├── deposit/             # Deposit funds
│   ├── kyc/                 # Identity verification
│   ├── legal/               # Terms & Privacy
│   ├── p2p/                 # P2P exchange
│   ├── profile/             # User profile
│   ├── send_money/          # Money transfers
│   ├── transactions/        # Transaction history
│   └── withdraw/            # Withdraw funds
├── responsive/              # Responsive design system
├── theme.dart               # App theming
├── widgets/                 # Reusable widgets
└── main.dart                # App entry point
```

## Development

### Code Generation
Run build_runner for JSON serialization:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting
```bash
flutter analyze
```

### Testing
```bash
flutter test
```

## Building for Release

### Android
```bash
flutter build apk --release --dart-define=SENTRY_DSN=<your-dsn>
flutter build appbundle --release --dart-define=SENTRY_DSN=<your-dsn>
```

### iOS
```bash
flutter build ios --release --dart-define=SENTRY_DSN=<your-dsn>
```

## Contributing

1. Create a feature branch (`git checkout -b feature/amazing-feature`)
2. Commit your changes (`git commit -m 'Add amazing feature'`)
3. Push to the branch (`git push origin feature/amazing-feature`)
4. Open a Pull Request

## License

Copyright © 2025 Yege Technologies LLC. All rights reserved.

## Support

For issues or questions, contact:
- **Email**: info@yegetechnologies.com
- **Phone**: +1 (202) 773-8179

---

**Built with ❤️ by Yege Technologies LLC**
