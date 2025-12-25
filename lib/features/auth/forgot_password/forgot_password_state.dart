class ForgotPasswordState {
  final String email;
  final String? emailError;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  ForgotPasswordState({
    this.email = '',
    this.emailError,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  ForgotPasswordState copyWith({
    String? email,
    String? emailError,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      emailError: emailError,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
