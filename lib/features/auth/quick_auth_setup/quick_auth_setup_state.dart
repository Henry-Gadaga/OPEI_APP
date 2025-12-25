sealed class QuickAuthSetupState {}

class QuickAuthSetupInitial extends QuickAuthSetupState {}

class QuickAuthSetupLoading extends QuickAuthSetupState {}

class QuickAuthSetupPinEntry extends QuickAuthSetupState {
  final String pin;
  final bool isConfirming;
  final String? firstPin;
  final String? errorMessage;

  QuickAuthSetupPinEntry({
    this.pin = '',
    this.isConfirming = false,
    this.firstPin,
    this.errorMessage,
  });

  QuickAuthSetupPinEntry copyWith({
    String? pin,
    bool? isConfirming,
    String? firstPin,
    String? errorMessage,
  }) => QuickAuthSetupPinEntry(
        pin: pin ?? this.pin,
        isConfirming: isConfirming ?? this.isConfirming,
        firstPin: firstPin ?? this.firstPin,
        errorMessage: errorMessage,
      );
}

class QuickAuthSetupSuccess extends QuickAuthSetupState {
  final String message;
  QuickAuthSetupSuccess(this.message);
}

class QuickAuthSetupError extends QuickAuthSetupState {
  final String message;
  QuickAuthSetupError(this.message);
}
