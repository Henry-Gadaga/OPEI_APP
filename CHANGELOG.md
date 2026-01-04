# Changelog

All notable changes to the Opei app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-04

### Added - Initial Release
- **Authentication System**
  - User signup with email verification
  - Login with email/password
  - Quick authentication with PIN and biometrics
  - Forgot password and reset functionality
  - Session management with auto-lock

- **Wallet Features**
  - View balance in multiple currencies
  - Transaction history with filtering
  - Deposit funds via multiple methods
  - Withdraw to bank accounts
  - Send money to other users

- **Virtual Cards**
  - Create USD virtual cards
  - Fund cards from wallet
  - View card details and transactions
  - Top-up existing cards
  - Withdraw funds from cards

- **P2P Exchange**
  - Buy cryptocurrency (BTC, USDT, USDC)
  - Sell cryptocurrency
  - Create buy/sell ads
  - View active orders
  - Rate trading partners

- **KYC & Compliance**
  - Identity verification flow
  - Document upload (ID, selfie)
  - Address verification
  - Terms & Conditions
  - Privacy Policy

- **Profile Management**
  - View and edit personal information
  - Update address
  - Security settings (PIN/biometric)
  - Account actions (logout)

- **Security**
  - End-to-end HTTPS encryption
  - Secure token storage (Keychain/Encrypted)
  - Biometric authentication
  - Automatic session timeout
  - Sentry error tracking

- **UI/UX**
  - Clean, minimalist design
  - Smooth animations and transitions
  - Responsive layout system
  - Loading states and error handling
  - Success/error notifications

### Technical
- Built with Flutter 3.6.0
- Riverpod 3.0 for state management
- GoRouter for navigation
- Dio HTTP client with interceptors
- Sentry integration for monitoring

### Fixed
- UnmountedRefException in authentication flows
- FocusScope lifecycle issues
- API error handling improvements

---

## [Unreleased]

### Added
- Environment-aware configuration (`lib/core/config/environment.dart`) with support for dev/staging/prod API URLs and Sentry DSNs.
- Android build flavors (`dev`, `staging`, `prod`) with distinct application IDs and launcher labels.
- Continuous integration workflow (`.github/workflows/flutter-ci.yml`) that runs analyze/tests on every push or PR.
- Automated test coverage for quick auth flows, card creation, and login-to-dashboard navigation.
- Widget tests for verify-email inputs and address onboarding, covering validation, error messaging, and legal navigation.
- Dashboard/wallet controller unit tests to assert balance refresh, error propagation, and transaction hydration logic.
- Repository-level tests for `P2PRepository` covering ad parsing, trade cancellation responses, and proof upload presign headers.
- End-to-end smoke test that drives dashboard ➝ P2P navigation and ensures every tab triggers its respective controller loads.

### Changed
- `ApiConfig` now derives its base URL/version from the active environment instead of hardcoded production values.
- README updated with instructions for running different environments and flavors.

## [1.1.0] - 2025-01-04

### Added
- Multi-environment support derived from `APP_ENV` or `--dart-define` overrides.
- Android product flavors and CI workflow (analyze/test on push/PR).

### Changed
- Updated dependencies (riverpod, go_router, local_auth, permission_handler, flutter_secure_storage, sentry_flutter, etc.).
- Raised Dart SDK constraint to ^3.8.0 and introduced a formal changelog.

### Planned
- Multi-language support
- Dark mode
- Push notifications
- In-app chat support
- Advanced analytics dashboard
- Transaction export (PDF/CSV)
