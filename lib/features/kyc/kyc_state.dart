sealed class KycState {}

class KycInitial extends KycState {}

class KycLoading extends KycState {}

class KycWebViewReady extends KycState {
  final String sessionUrl;
  final String status;

  KycWebViewReady({required this.sessionUrl, required this.status});
}

class KycError extends KycState {
  final String message;
  final KycErrorType errorType;

  KycError({required this.message, required this.errorType});
}

class KycCompleted extends KycState {}

enum KycErrorType {
  alreadyApproved,
  underReview,
  wrongStage,
  inactiveUser,
  unauthorized,
  notFound,
  serviceUnavailable,
  general,
}
