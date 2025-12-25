import 'package:tt1/data/models/auth_response.dart';

sealed class SignupState {}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {
  final AuthResponse authResponse;
  
  SignupSuccess(this.authResponse);
}

class SignupError extends SignupState {
  final String message;
  final Map<String, String> fieldErrors;
  
  SignupError(this.message, {this.fieldErrors = const {}});
}
