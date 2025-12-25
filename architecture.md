# Opei - Architecture Documentation

## Overview
Opei is a fintech mobile application built with Flutter, featuring a clean, minimalist Apple-inspired UI using only black, white, and grey colors. The app implements a 4-step onboarding flow: Signup → Email Verification → Address Submission → KYC Verification.

## Architecture Pattern
The project follows **Clean Architecture** principles with clear separation of concerns:

### Layer Structure
```
lib/
├── core/                    # Core infrastructure
│   ├── config/             # API configuration (base URL, timeouts)
│   ├── constants/          # App-wide constants
│   ├── network/            # HTTP client, error handling, API response models
│   ├── storage/            # Secure storage service
│   └── providers/          # Riverpod providers
├── data/                    # Data layer
│   ├── models/             # DTOs and data models (JSON serializable)
│   └── repositories/       # Repository implementations (API calls)
└── features/               # Feature modules
    ├── auth/
    │   ├── signup/         # Signup flow (Step 1)
    │   └── verify_email/   # Email verification (Step 2 - scaffold)
    ├── address/            # Address submission (Step 3 - scaffold)
    └── kyc/                # KYC verification (Step 4 - scaffold)
```

## Key Design Decisions

### 1. Centralized API Configuration
- **Single base URL** defined in `core/config/api_config.dart`
- All endpoints built from `ApiConfig.apiBaseUrl`
- No hard-coded URLs in UI or feature code
- Easy to switch between dev/staging/production environments

### 2. Secure Token Storage
- Uses `flutter_secure_storage` with encrypted shared preferences (Android)
- Tokens stored in Keychain (iOS) and encrypted storage (Android)
- **Never** logs full tokens in production builds
- Auto-clears on 401/403 responses

### 3. HTTP Client with Interceptors
- Dio-based `ApiClient` with automatic token injection
- Global error handling and response parsing
- Request/response logging (debug mode only)
- Automatic logout on authentication failures

### 4. State Management
- **Riverpod** for dependency injection and state management
- Controllers extend `StateNotifier<State>` with sealed state classes
- UI layer is purely reactive - no business logic in widgets
- Clear separation: UI → Controller → Repository → API Client

### 5. Error Handling Strategy
- `ApiError` class captures HTTP status codes and field-level errors
- Controllers map errors to user-friendly messages
- Field errors displayed inline on forms
- Generic errors shown via SnackBars

## Current Implementation Status

### ✅ Step 1: Signup Flow (COMPLETE)
**Endpoint:** `POST /api/v1/auth/signup`

**Features:**
- Email, phone, and password input with validation
- Password requirements: ≥8 chars, uppercase, lowercase, number, special char
- Field-level error display from API responses
- Loading spinner overlay during API calls
- Success/error handling with SnackBars
- Auto-navigation to email verification on success
- Stores `accessToken` and user data in secure storage

**Files:**
- Controller: `features/auth/signup/signup_controller.dart`
- State: `features/auth/signup/signup_state.dart`
- UI: `features/auth/signup/signup_screen.dart`
- Repository: `data/repositories/auth_repository.dart`
- Models: `data/models/signup_request.dart`, `auth_response.dart`, `user_model.dart`

**Error Handling:**
| HTTP Code | Scenario | Frontend Action |
|-----------|----------|----------------|
| 400 | Validation errors | Show field-specific errors inline |
| 409 | Email/phone conflict | Prompt user to login or use different credentials |
| 500 | Server error | Show generic "try again" message |

### 🚧 Step 2: Email Verification (SCAFFOLD)
**Status:** Placeholder screen created, awaiting implementation
**File:** `features/auth/verify_email/verify_email_screen.dart`

### 🚧 Step 3: Address Submission (SCAFFOLD)
**Status:** Placeholder screen created, awaiting implementation
**File:** `features/address/address_screen.dart`

### 🚧 Step 4: KYC Verification (SCAFFOLD)
**Status:** Placeholder screen created, awaiting implementation
**File:** `features/kyc/kyc_screen.dart`

## Design System

### Color Palette (Monochrome)
- **Pure White:** `#FFFFFF` - Background, button text
- **Pure Black:** `#000000` - Primary text, buttons
- **Grey Scale:** 50, 100, 200, 300, 400, 500, 600, 700, 800, 900
- **Accent Colors:** Error Red (`#DC2626`), Success Green (`#16A34A`)

### Typography
- **Font Family:** SF Pro Display & SF Pro Text (via Google Fonts)
- **Style:** Tight letter spacing (-0.8 to 0.1), clean hierarchy
- **Weights:** 300 (Light), 400 (Regular), 500 (Medium), 600 (Semi-Bold), 700 (Bold)

### UI Components
- **Buttons:** Rounded rectangles (16px radius), 56px height, black background, white text
- **Text Fields:** Filled style with grey background, 16px radius, 2px black focus border
- **Spacing:** Consistent 8px grid (xs:4, sm:8, md:16, lg:24, xl:32, xxl:48)
- **Transitions:** Smooth fade and slide animations for navigation (easeInOut curve)

### Loading States
- Full-screen overlay with semi-transparent black background
- Centered white card with circular spinner and message
- Prevents interaction during API calls

## Data Flow Example (Signup)

```
SignupScreen (UI)
    ↓ User taps "Continue"
SignupController.signup()
    ↓ Creates SignupRequest
AuthRepository.signup()
    ↓ Calls ApiClient.post()
ApiClient (adds token, logs request)
    ↓ Sends HTTP POST to /api/v1/auth/signup
NestJS API
    ↓ Returns AuthResponseDto
ApiClient (handles response/errors)
    ↓ Returns AuthResponse
AuthRepository (stores token & user)
    ↓ Returns AuthResponse
SignupController
    ↓ Updates state to SignupSuccess
SignupScreen (listens to state change)
    ↓ Shows success message
    ↓ Navigates to /verify-email
```

## Security Best Practices

1. **Token Management**
   - Stored in platform secure storage (Keychain/Encrypted Prefs)
   - Auto-injected via interceptor (no manual handling in features)
   - Auto-cleared on authentication failures

2. **Logging**
   - Debug logs only in non-release builds
   - Never logs passwords, tokens, or PII in production
   - Uses `debugPrint()` for controlled logging

3. **Error Messages**
   - Generic messages for server errors (don't expose internals)
   - Specific field errors for validation failures
   - User-friendly language throughout

## Navigation & Routing

- **Router:** GoRouter with declarative routing
- **Transitions:** Custom page transitions (fade, slide) for smooth UX
- **Initial Route:** `/signup`
- **Flow:** `/signup` → `/verify-email` → `/address` → `/kyc`

## Testing Strategy (Future)

### Unit Tests
- Controllers: State transitions, error handling
- Repositories: API call logic, response parsing
- Models: JSON serialization/deserialization

### Integration Tests
- End-to-end signup flow
- Error scenarios (network failures, validation errors)
- Token refresh and auto-logout

### Widget Tests
- Form validation
- Loading states
- Error message display

## Next Steps

1. **Step 2:** Implement email verification flow
   - API endpoint for resending verification email
   - OTP input screen or email link handling
   - Success state with navigation to address screen

2. **Step 3:** Implement address submission
   - Address form with autocomplete
   - Validation and submission
   - Progress indicator showing step 3/4

3. **Step 4:** Implement KYC verification
   - Document upload (ID, selfie)
   - Liveness detection (if required)
   - Submission and status tracking

4. **Post-Onboarding:** Dashboard/home screen after successful KYC

## Configuration Notes

### To Update API Base URL:
Edit `lib/core/config/api_config.dart`:
```dart
static const String baseUrl = 'https://your-production-api.com';
```

### To Add New API Endpoints:
1. Create request/response models in `data/models/`
2. Add repository method in appropriate repository
3. Create controller with state management
4. Build UI screen that consumes controller

## Dependencies

**Core:**
- `flutter_riverpod` - State management & DI
- `go_router` - Declarative routing
- `dio` - HTTP client
- `flutter_secure_storage` - Secure token storage

**UI:**
- `google_fonts` - SF Pro Display/Text fonts

**Serialization:**
- `json_annotation` - JSON serialization
- `freezed_annotation` - Immutable models (future use)
