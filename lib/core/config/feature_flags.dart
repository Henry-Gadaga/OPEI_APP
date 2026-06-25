/// Central app-level feature toggles.
///
/// Keep old flows in code while controlling visibility/availability at runtime.
class FeatureFlags {
  FeatureFlags._();

  /// Classic marketplace-style P2P (`/p2p`).
  ///
  /// Default is hidden for production rollout while keeping the full feature
  /// codepath available. Re-enable by either:
  /// - changing this default to `true`, or
  /// - building with `--dart-define=ENABLE_CLASSIC_P2P=true`.
  static const bool enableClassicP2P = bool.fromEnvironment(
    'ENABLE_CLASSIC_P2P',
    defaultValue: false,
  );
}
