class ResetPasswordState {
  final String email;
  final String code;
  final String newPassword;
  final String confirmPassword;
  final String? codeError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool isLoading;
  final String? errorMessage;

  ResetPasswordState({
    this.email = '',
    this.code = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.codeError,
    this.passwordError,
    this.confirmPasswordError,
    this.isLoading = false,
    this.errorMessage,
  });

  ResetPasswordState copyWith({
    String? email,
    String? code,
    String? newPassword,
    String? confirmPassword,
    String? codeError,
    String? passwordError,
    String? confirmPasswordError,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ResetPasswordState(
      email: email ?? this.email,
      code: code ?? this.code,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      codeError: codeError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
