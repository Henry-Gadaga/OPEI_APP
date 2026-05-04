import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/beneficiary.dart';

/// Immutable state for the US bank beneficiaries flow.
///
/// Mirrors [BeneficiariesState] but with its own copy so we can grow the
/// US bank flow independently of mobile money in the future.
class UsBankBeneficiariesState {
  final bool isLoading;
  final String? error;
  final List<Beneficiary> items;

  // Create flow
  final bool isCreating;
  final String? createError;
  final Beneficiary? lastCreated;

  const UsBankBeneficiariesState({
    this.isLoading = false,
    this.error,
    this.items = const [],
    this.isCreating = false,
    this.createError,
    this.lastCreated,
  });

  UsBankBeneficiariesState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<Beneficiary>? items,
    bool? isCreating,
    String? createError,
    bool clearCreateError = false,
    Beneficiary? lastCreated,
    bool clearLastCreated = false,
  }) {
    return UsBankBeneficiariesState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      items: items ?? this.items,
      isCreating: isCreating ?? this.isCreating,
      createError:
          clearCreateError ? null : (createError ?? this.createError),
      lastCreated:
          clearLastCreated ? null : (lastCreated ?? this.lastCreated),
    );
  }
}

/// Controller for the US bank beneficiaries flow.
///
/// Distinct from the mobile-money controller because the create payload is
/// completely different (long, structured destination + beneficiary objects).
final usBankBeneficiariesControllerProvider = NotifierProvider<
    UsBankBeneficiariesController, UsBankBeneficiariesState>(
  UsBankBeneficiariesController.new,
);

class UsBankBeneficiariesController
    extends Notifier<UsBankBeneficiariesState> {
  @override
  UsBankBeneficiariesState build() {
    Future.microtask(load);
    return const UsBankBeneficiariesState();
  }

  Future<void> load() async {
    final userId = ref.read(authSessionProvider).userId;
    if (userId == null) {
      state = state.copyWith(
          error: 'You need to be signed in to view receivers.');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(beneficiaryRepositoryProvider);
      // Backend uses Prisma's `BeneficiaryType` enum which only accepts
      // `BANK | MOBILEMONEY | ALIPAY | WECHATPAY` — sending `US_BANK` here
      // makes the ValidationPipe throw 400. We narrow to the US corridor
      // via the `country` filter instead.
      final list = await repo.listBeneficiaries(
        userId: userId,
        country: 'US',
        type: 'BANK',
      );
      state = state.copyWith(isLoading: false, items: list);
    } catch (error, stack) {
      debugPrint('US bank load error: $error\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: ErrorHelper.getErrorMessage(error, context: 'us_bank'),
      );
    }
  }

  Future<bool> createUsBank({
    required String transferType,
    required String accountType,
    required String accountNumber,
    required String routingNumber,
    required String bankName,
    required String bankAddress,
    required String postCode,
    required String city,
    required String state,
    required String remittancePurpose,
    required String beneficiaryType,
    required String beneficiaryAccountName,
    required String beneficiaryState,
    required String beneficiaryCity,
    required String beneficiaryAddress,
    required String beneficiaryPostCode,
  }) async {
    final userId = ref.read(authSessionProvider).userId;
    if (userId == null) {
      this.state = this.state.copyWith(
          createError: 'You need to be signed in to add a receiver.');
      return false;
    }

    this.state = this.state.copyWith(isCreating: true, clearCreateError: true);
    try {
      final repo = ref.read(beneficiaryRepositoryProvider);
      final created = await repo.createUsBankBeneficiary(
        userId: userId,
        transferType: transferType,
        accountType: accountType,
        accountNumber: accountNumber,
        routingNumber: routingNumber,
        bankName: bankName,
        bankAddress: bankAddress,
        postCode: postCode,
        city: city,
        state: state,
        remittancePurpose: remittancePurpose,
        beneficiaryType: beneficiaryType,
        beneficiaryAccountName: beneficiaryAccountName,
        beneficiaryState: beneficiaryState,
        beneficiaryCity: beneficiaryCity,
        beneficiaryAddress: beneficiaryAddress,
        beneficiaryPostCode: beneficiaryPostCode,
      );
      this.state = this.state.copyWith(
            isCreating: false,
            lastCreated: created,
            items: [created, ...this.state.items],
          );
      return true;
    } catch (error, stack) {
      debugPrint('US bank create error: $error\n$stack');
      this.state = this.state.copyWith(
            isCreating: false,
            createError:
                ErrorHelper.getErrorMessage(error, context: 'us_bank'),
          );
      return false;
    }
  }

  void clearCreateError() => state = state.copyWith(clearCreateError: true);
}
