import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/repositories/beneficiary_repository.dart';

import 'beneficiaries_state.dart';

/// Controller for the per-country beneficiaries flow.
///
/// One controller instance per country code (provided as a [Family] argument)
/// so that switching countries doesn't bleed into stale state.
final beneficiariesControllerProvider = NotifierProvider.family<
    BeneficiariesController, BeneficiariesState, String>(
  (country) {
    final controller = BeneficiariesController();
    controller._country = country.toUpperCase();
    return controller;
  },
);

class BeneficiariesController extends Notifier<BeneficiariesState> {
  late String _country;
  late BeneficiaryRepository _repo;

  @override
  BeneficiariesState build() {
    _repo = ref.read(beneficiaryRepositoryProvider);
    // Auto-load on first listen for this country.
    Future.microtask(load);
    return BeneficiariesState(country: _country);
  }

  /// Refreshes the list of beneficiaries for this country.
  Future<void> load() async {
    final userId = ref.read(authSessionProvider).userId;
    if (userId == null) {
      state = state.copyWith(
        error: ErrorHelper.l10n.p2pPleaseSignInAgainError,
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repo.listBeneficiaries(
        userId: userId,
        country: _country,
      );
      state = state.copyWith(isLoading: false, items: list);
    } catch (error, stack) {
      debugPrint('Beneficiary load error: $error\n$stack');
      state = state.copyWith(
        isLoading: false,
        error: ErrorHelper.getErrorMessage(error, context: 'beneficiary'),
      );
    }
  }

  /// Creates a new mobile-money beneficiary for this country.
  ///
  /// Returns `true` on success, `false` on error (and surfaces the message via
  /// [BeneficiariesState.createError]).
  Future<bool> createMobileMoney({
    required String network,
    required String accountNumber,
    String? accountName,
  }) async {
    final userId = ref.read(authSessionProvider).userId;
    if (userId == null) {
      state = state.copyWith(
        createError: ErrorHelper.l10n.p2pPleaseSignInAgainError,
      );
      return false;
    }

    state = state.copyWith(isCreating: true, clearCreateError: true);
    try {
      final created = await _repo.createMobileMoneyBeneficiary(
        userId: userId,
        country: _country,
        network: network,
        accountNumber: accountNumber,
        accountName: accountName,
      );
      state = state.copyWith(
        isCreating: false,
        lastCreated: created,
        items: [created, ...state.items],
      );
      return true;
    } catch (error, stack) {
      debugPrint('Beneficiary create error: $error\n$stack');
      state = state.copyWith(
        isCreating: false,
        createError: ErrorHelper.getErrorMessage(error, context: 'beneficiary'),
      );
      return false;
    }
  }

  void clearCreateError() => state = state.copyWith(clearCreateError: true);
}
