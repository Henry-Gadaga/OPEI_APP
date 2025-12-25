class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;
  final String? emailError;
  final String? passwordError;

  LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.errorMessage,
    this.emailError,
    this.passwordError,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
    String? emailError,
    String? passwordError,
    bool clearErrors = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrors ? null : (errorMessage ?? this.errorMessage),
      emailError: clearErrors ? null : (emailError ?? this.emailError),
      passwordError: clearErrors ? null : (passwordError ?? this.passwordError),
    );
  }

  bool get isValid => email.isNotEmpty && password.isNotEmpty && password.length >= 8;
}
