## Responsive Retrofit · Phase 1 (Discovery & Breakpoints)

> Constraints: no visual redesigns, no business-logic changes, no new features. Responsiveness must feel intentional, not stretched.

### 1. Target Viewports & Breakpoints

| Label | Width Range (dp) | Primary Devices | Layout Intent |
| --- | --- | --- | --- |
| Compact | `< 360` | Small phones, split-screen slivers | Single column, condensed paddings/typography, hiding decorative elements |
| Phone | `360 – 599` | Standard phones (portrait) | Current baseline layouts with adaptive spacing |
| Large Phone / Fold Portrait | `600 – 839` | Plus-sized phones, foldables unfolded, portrait tablets | Wider cards, dual-column lists where safe, increased gutters |
| Tablet / Desktop | `≥ 840` | Tablets (landscape), desktop/web windows, foldables landscape | Max-width content columns, side-by-side list/detail, persistent side rails |

Implementation: derive from `MediaQuery.size.width` or a `LayoutBuilder` constraint. Expose helpers like `context.responsiveSize` returning an enum.

### 2. Responsive Design Tokens

| Token | Compact | Phone | Large Phone | Tablet/Desktop |
| --- | --- | --- | --- | --- |
| Base font size | 13 | 14 | 15 | 16 |
| Heading scale | `*1.15` | `*1.2` | `*1.3` | `*1.4` |
| Horizontal padding | 16 | 20 | 24 | 32 (capped at max-width shells) |
| Vertical spacing unit | 6 | 8 | 10 | 12 |
| Card max-width | full | full | 560 | 640 center-aligned |
| Bottom sheet max-width | full | full | 600 | 720 with center positioning |

Tokens will live in a new `responsive.dart` helper (Phase 2) and feed `ThemeData` extensions (e.g., `OpeiSpacing`).

### 3. Screen Inventory & Issues

| Module | Screens | Current Constraints | Responsive Work |
| --- | --- | --- | --- |
| Auth | Login, Signup, Verify Email, Password Reset | Fixed-width columns with hardcoded spacers, image banners assume ~400dp width. Bottom sheets (e.g., OTP) full-width even on tablets. | Introduce `ConstrainedBox` + `Align` wrappers, allow max-width of 480–520dp centered on large screens, adapt button widths, ensure OTP inputs scale. |
| Dashboard | Home overview, wallets, transactions | Mixed `SizedBox` heights; transaction list assumes full width, hero cards clipped on small phones. | Wrap hero cards in `LayoutBuilder` to adjust heights, enable multi-column transaction grid on tablets, responsive typography for stats. |
| Cards | Card list, create-card flow, card detail | `VirtualCardHero` height fixed (220) and `SingleChildScrollView` with nested `SizedBox` spaces. Loading screens centered via fixed constraints. | Use max-width container, adjust hero scaling with `AspectRatio`, ensure CTA stays visible without forced paddings. |
| Deposits/Withdrawals | Fiat/crypto flows, select network, address display | Step stacks rely on `SizedBox(height: X)`. Dialogs float edge-to-edge on tablets, causing “stretched” feel. | Convert to responsive paddings, center content, ensure transitions maintain consistent aspect on larger widths. |
| P2P | Marketplace tabs, trade sheets, proof upload, dispute dialogs | Trade sheet is ~ full-screen bottom sheet with long single column; proof previews fixed 88px; dispute sheet recently updated but still single-column. | Introduce breakpoints to split list/detail (e.g., active trade vs. instructions) on ≥600dp, keep proof grid responsive, cap sheet width to 600dp. |
| Settings/Profile | Account, notifications, support screens | Vertical stacks with fixed paddings; bottom sheets 100% width. | Use shared responsive scaffolds & side rails for tablets, ensure forms respect multi-column spacing. |

### 4. Shared Components to Refactor Early

1. **Scaffolds/App bars** – adopt responsive gutters & max widths.
2. **Bottom sheets/dialogs** – add max-width + centered behavior on large screens.
3. **Primary buttons** – convert to width-aware (full-width on phones, intrinsic on tablets).
4. **Hero cards/panels** – use `AspectRatio` + `LayoutBuilder` for consistent feel.
5. **Lists/grids** – add responsive `SliverGridDelegate` for 1→2 column transitions ≥600dp.

### 5. Implementation Checklist (Phase 2 Prep)

- [x] Create `lib/responsive/responsive_breakpoints.dart` with enums/helpers.
- [x] Extend `ThemeData` with responsive typography/spacing getters.
- [x] Build reusable `ResponsiveScaffold`/`ResponsiveSheet` wrappers handling max widths & gutters.
- [ ] Add logging guard for `RenderFlex overflow` to surface regressions early.
- [ ] Update global padding constants (`AppSpacing`, etc.) to reference breakpoint-aware tokens.

### 6. Acceptance Criteria for Phase 1

- Breakpoint/tokens document approved (this file).
- Prioritized screen list agreed with product/design.
- No runtime code changes yet; plan ready for implementation.
- “Intentional, not stretched” principle captured via max-width + token strategy.

### 7. Next Steps

1. Implement helpers & tokens (Phase 2).
2. Refactor shared scaffolds and dialogs to consume helpers.
3. Proceed module-by-module per priority table, verifying on compact/phone/tablet breakpoints.

### 8. Phase 2 Deliverables (Dec 29, 2025)

- Added `ResponsiveSize` + breakpoint resolver (no platform heuristics).
- Added theme extension `OpeiResponsiveTheme` (base font scale, gutters, sheet widths, button heights).
- Created helpers:
  - `ResponsiveScaffold` – constrains content width + gutters, opt-in SafeArea.
  - `ResponsiveSheet` + `showResponsiveBottomSheet`.
  - `ResponsiveSliverGridDelegate` for automatic column changes ≥600dp.
- Introduced `context.responsiveTokens`, `context.responsiveSpacingUnit`, etc., for gradual adoption.
- No feature UIs touched yet; existing layouts render identically on phones, while tablets now respect max-width tokens once wrappers are used.

### 9. Phase 3 Progress (Auth Forms – Dec 29, 2025)

- Login, Signup, Forgot Password, and Reset Password screens now use `ResponsiveScaffold`, token-based gutters, and adaptive button heights.
- Existing spacing translated into token multiples so phones look unchanged while large screens gain breathing room.
- Shared auth field widgets (email/password inputs) derive spacing from `context.responsiveSpacingUnit`.
- Remaining auth surfaces (Verify Email flow, Quick Auth screens) are next up—tracked separately before tackling dashboard/cards.

### 10. Phase 3 Progress (Verify Email & Quick Auth – Dec 29, 2025)

- `VerifyEmailScreen` now runs inside `ResponsiveScaffold`; OTP inputs sit in a centered max-width row with token-based vertical rhythm and overlay spinners positioned via the same wrapper.
- Quick Auth PIN entry and Quick Auth setup screens share responsive scaffolds, with avatars/keypads centered within the content width and vertical spacing driven by `responsiveSpacingUnit`.
- Loading states (`BouncingDots`, verifying overlays) also use `ResponsiveScaffold` so tablets render consistent gutters.
- Auth module is fully migrated; next focus shifts to dashboard/wallets and cards per Phase 3 plan.

### 11. Phase 3 Progress (Dashboard & Cards – Dec 29, 2025)

- `DashboardHomeScreen` now lives inside `ResponsiveScaffold`; hero cards, quick actions, and transaction lists respect token gutters and spacing, and skeleton/refresh states stay centered even on tablets.
- Quick actions + deposit/withdraw sheets call `showResponsiveBottomSheet`, so large devices see capped, centered modals.
- `CardsScreen` (list + empty state) now uses responsive scaffolds, tokenized vertical rhythm, and max-width constraints for virtual-card hero + CTA. Card top-up/withdraw/address sheets also use `showResponsiveBottomSheet`.
- Next up: deposits/withdrawals, P2P, and settings/profile per the Phase 3 rollout plan.

### 12. Phase 3 Progress (Money Movement, P2P, Settings/Profile – Dec 30, 2025)

- **Deposits & Withdrawals:** Crypto/fiat select flows, network pickers, address displays, and success screens now run inside `ResponsiveScaffold`. Every step uses token-based spacing, and their dialogs (select network, success states) are driven by `showResponsiveBottomSheet`.
- **P2P Marketplace:** All four tabs (Home, Orders, My Ads, Profile) and their modals use responsive scaffolds/sheets. Tabs share the token gutters so large devices see centered columns, and every trade/ad sheet/proof upload/dispute dialog is capped by `showResponsiveBottomSheet`. Bottom nav now honors responsive padding.
- **Settings/Profile:** The profile screen (header, KYC prompt, address cards, preferences, logout) is constrained by `ResponsiveScaffold` with token spacing. Language selector and logout confirmation both consume `showResponsiveBottomSheet`, keeping sheets centered on tablets. Error/loading states share the same responsive shell.
- With these modules complete, the Phase 3 retrofit now covers all user-facing surfaces, and modules inherit consistent breakpoints, gutters, and centered sheets. Remaining work shifts to Phase 4 tasks.

### 13. Phase 4 · Validation & Polish (Plan – Dec 30, 2025)

**Objective:** Validate the responsive work across real device classes, fix any edge cases discovered, and codify safeguards (docs/tests) before shipping.

#### 13.1 Device & Screen Matrix

| Breakpoint | Target Devices | Screens to Verify |
| --- | --- | --- |
| Compact (`<360dp`) | Pixel 3a (display scaled), split-screen iPhone SE | Auth stack (login/signup/OTP), quick-auth PIN, profile |
| Phone (`360–599dp`) | Pixel 5/7, iPhone 14 | Dashboard, cards, deposit/withdraw, P2P tabs, profile |
| Large Phone (`600–839dp`) | Pixel Fold portrait, Galaxy Z Fold | Dashboard, cards, P2P (ensure gutters hold), proof upload |
| Tablet/Desktop (`≥840dp`) | iPad Pro landscape, Chrome desktop window | All modules, especially multi-step flows + sheets |

For each combination capture screenshots or notes for: spacing accuracy, dialog centering, text wrapping, keyboard insets, and scroll behavior.

#### 13.2 QA Checklist

- [ ] Auth (login → signup → verify email → reset password) on compact + tablet.
- [ ] Quick Auth (PIN entry/setup), ensuring keypad spacing and overlays scale.
- [ ] Dashboard + cards (hero, create card flow) on large phone + tablet.
- [ ] Deposit/withdraw (USD + crypto) on phone + tablet, verifying sheets.
- [ ] P2P tabs (Home, Orders, My Ads, Profile) across all breakpoints; include trade sheet, proof upload, dispute dialog.
- [ ] Profile/settings (language selector, logout) on tablet (sheet max-width) and compact phone.
- [ ] Address editor / misc forms for any lingering fixed paddings.

Document findings in a shared checklist (Notion/Jira) with severity, screenshot, and fix owner.

#### 13.3 Edge-Case Fix & Regression Guard

1. **Fix loop:** Triage QA bugs (overflow, tap targets, misaligned sheets) immediately and retest affected screen.
2. **Snapshot tests:** Add golden tests for representative widgets (ProfileSection, P2P order card) under fixed width constraints to detect spacing regressions.
3. **Smoke script:** Record a flutter drive or `integration_test` smoke flow that navigates dashboard ➝ cards ➝ P2P ➝ profile on a large emulator, ensuring no runtime errors or overflow logs.
4. **Final documentation:** Summarize QA results + residual risks back in this doc and the release notes.

#### 13.4 Phase 4 Results – Dec 31, 2025

**Device coverage completed**
- **Compact / Phone:** Tecno CM5 (portrait) + Pixel 5 emulator (360 dp) – Auth stack, quick-auth flows, profile/settings.
- **Large Phone:** Android emulator secondary display (720 p) – Dashboard, cards, deposit/withdraw multi-step forms, P2P tabs.
- **Tablet/Desktop widths:** Chrome DevTools responsive (1024–1280 px) – Full regression of dashboard, cards, deposits/withdrawals, P2P trade sheets, and profile.

**Bugs discovered & fixed**
- P2P profile sheets: PIN setup overflow when keyboard shown → wrapped in scrollable `AnimatedPadding`.
- Withdraw success screen: GoRouter pop crash when stack empty → guarded with `navigator.canPop` fallback to dashboard.
- Quick-auth setup: provider reset causing visual flash on success → removed eager reset until after navigation.
- Keyboard UX: tapping between fields caused keyboard flicker → `KeyboardDismissOnTap` now ignores taps inside other `EditableText` widgets.
- P2P payment manager: excessive side gutters & missing back affordance → migrated to `ResponsiveSheet` with token padding and added back arrow; provider picker now uses a modal list instead of a cramped dropdown.

**Regression guards added**
- `test/responsive_layout_test.dart` verifies `ResponsiveScaffold`/`ResponsiveSheet` width constraints.
- Sentry integrated with `--dart-define SENTRY_DSN=…`; overflow/GoRouter errors now surface automatically (used to validate the withdraw fix above).

Remaining risks: tablet-specific multi-column layouts (Phase 4 stretch goal) and golden tests for complex widgets. These will be tracked under Phase 5.

With QA + regression guards in place, Phase 4 concludes and the responsive work can ship confidently.

_Prepared for Opei App Flutter – Dec 29, 2025._
