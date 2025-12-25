import 'package:tt1/data/models/full_profile_response.dart';

class ProfileState {
  final bool isLoading;
  final bool isLoggingOut;
  final FullProfileResponse? profile;
  final String? error;
  final String selectedLanguage;

  ProfileState({
    this.isLoading = false,
    this.isLoggingOut = false,
    this.profile,
    this.error,
    this.selectedLanguage = 'English',
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isLoggingOut,
    FullProfileResponse? profile,
    String? error,
    String? selectedLanguage,
  }) => ProfileState(
        isLoading: isLoading ?? this.isLoading,
        isLoggingOut: isLoggingOut ?? this.isLoggingOut,
        profile: profile ?? this.profile,
        error: error,
        selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      );
}
