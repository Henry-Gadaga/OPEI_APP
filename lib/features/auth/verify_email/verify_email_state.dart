class VerifyEmailState {
  final List<String> codeDigits;
  final bool isVerifying;
  final bool isResending;
  final String? errorMessage;
  final int resendCountdown;
  final String email;

  VerifyEmailState({
    required this.codeDigits,
    required this.isVerifying,
    required this.isResending,
    this.errorMessage,
    required this.resendCountdown,
    required this.email,
  });

  factory VerifyEmailState.initial(String email) => VerifyEmailState(
        codeDigits: List.filled(6, ''),
        isVerifying: false,
        isResending: false,
        errorMessage: null,
        resendCountdown: 5,
        email: email,
      );

  bool get canResend => resendCountdown == 0 && !isResending;
  bool get isCodeComplete => codeDigits.every((d) => d.isNotEmpty);
  String get fullCode => codeDigits.join();
  bool get isLoading => isVerifying || isResending;

  String get timerText {
    final minutes = resendCountdown ~/ 60;
    final seconds = resendCountdown % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  VerifyEmailState copyWith({
    List<String>? codeDigits,
    bool? isVerifying,
    bool? isResending,
    String? errorMessage,
    int? resendCountdown,
    String? email,
    bool clearError = false,
  }) =>
      VerifyEmailState(
        codeDigits: codeDigits ?? this.codeDigits,
        isVerifying: isVerifying ?? this.isVerifying,
        isResending: isResending ?? this.isResending,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
        resendCountdown: resendCountdown ?? this.resendCountdown,
        email: email ?? this.email,
      );
}
