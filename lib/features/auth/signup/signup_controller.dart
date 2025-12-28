import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/network/api_error.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/core/utils/retry_helper.dart';
import 'package:tt1/data/models/signup_request.dart';
import 'package:tt1/features/auth/signup/signup_state.dart';

class SignupController extends Notifier<SignupState> {
  @override
  SignupState build() => SignupInitial();

  Future<void> signup({
    required String email,
    required String phone,
    required String password,
  }) async {
    state = SignupLoading();

    try {
      final request = SignupRequest(
        email: email.trim(),
        phone: phone.trim(),
        password: password,
      );

      final repository = ref.read(authRepositoryProvider);
      final storage = ref.read(secureStorageServiceProvider);
      
      final response = await repository.signup(request);

      await storage.saveEmail(email.trim());
      
      // Set auth session - this will trigger dependent providers to refresh
      ref.read(authSessionProvider.notifier).setSession(
        userId: response.user.id,
        accessToken: response.accessToken,
        userStage: response.user.userStage,
      );

      state = SignupSuccess(response);
      
      debugPrint('✅ Signup successful for ${response.user.email}');
      debugPrint('User stage: ${response.user.userStage}');
      debugPrint('✅ Auth session set via signup');
    } on ApiError catch (e) {
      debugPrint('❌ Signup failed: ${e.message}');
      if (e.statusCode == 429) {
        final retryInfo = parseRetryInfo(e.errors);
        state = SignupError(buildRetryMessage(e.message, retryInfo));
        return;
      }
      
      final fieldErrors = <String, String>{};
      if (e.errors != null) {
        e.errors!.forEach((key, value) {
          if (value is String) {
            fieldErrors[key] = value;
          } else if (value is List && value.isNotEmpty) {
            fieldErrors[key] = value.first.toString();
          }
        });
      }
      
      state = SignupError(e.message, fieldErrors: fieldErrors);
    } catch (e) {
      debugPrint('❌ Unexpected error during signup: $e');
      state = SignupError('An unexpected error occurred. Please try again.');
    }
  }

  void reset() {
    state = SignupInitial();
  }
}

final signupControllerProvider = NotifierProvider<SignupController, SignupState>(
  SignupController.new,
);
