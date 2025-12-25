sealed class QuickAuthState {}

class QuickAuthInitial extends QuickAuthState {}

class QuickAuthLoading extends QuickAuthState {}

class QuickAuthPinEntry extends QuickAuthState {
  final String pin;
  final String? errorMessage;

  QuickAuthPinEntry({
    this.pin = '',
    this.errorMessage,
  });

  QuickAuthPinEntry copyWith({
    String? pin,
    String? errorMessage,
  }) => QuickAuthPinEntry(
        pin: pin ?? this.pin,
        errorMessage: errorMessage,
      );
}

class QuickAuthSuccess extends QuickAuthState {}

class QuickAuthFailed extends QuickAuthState {
  final String message;
  QuickAuthFailed(this.message);
}
