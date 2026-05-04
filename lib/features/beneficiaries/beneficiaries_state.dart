import 'package:opei/data/models/beneficiary.dart';

class BeneficiariesState {
  final bool isLoading;
  final String? error;
  final String? country;
  final List<Beneficiary> items;

  // create flow
  final bool isCreating;
  final String? createError;
  final Beneficiary? lastCreated;

  const BeneficiariesState({
    this.isLoading = false,
    this.error,
    this.country,
    this.items = const [],
    this.isCreating = false,
    this.createError,
    this.lastCreated,
  });

  BeneficiariesState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? country,
    List<Beneficiary>? items,
    bool? isCreating,
    String? createError,
    bool clearCreateError = false,
    Beneficiary? lastCreated,
    bool clearLastCreated = false,
  }) {
    return BeneficiariesState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      country: country ?? this.country,
      items: items ?? this.items,
      isCreating: isCreating ?? this.isCreating,
      createError: clearCreateError ? null : (createError ?? this.createError),
      lastCreated:
          clearLastCreated ? null : (lastCreated ?? this.lastCreated),
    );
  }
}
