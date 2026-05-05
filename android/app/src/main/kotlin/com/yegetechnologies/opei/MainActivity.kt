package com.yegetechnologies.opei

import io.flutter.embedding.android.FlutterFragmentActivity

// Use FlutterFragmentActivity (instead of FlutterActivity) so the
// `local_auth` plugin can present the Android biometric prompt. The
// plugin requires the host activity to be a FragmentActivity; using
// FlutterActivity throws `LocalAuthException(uiUnavailable)` at runtime.
class MainActivity : FlutterFragmentActivity()
