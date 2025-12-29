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

_Prepared for Opei App Flutter – Dec 29, 2025._
