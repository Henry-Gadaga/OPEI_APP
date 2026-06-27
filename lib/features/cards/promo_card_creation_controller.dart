import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/repositories/card_repository.dart';
import 'package:opei/features/cards/promo_card_creation_state.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';
import 'package:opei/features/money_movement/availability_controller.dart';

final promoCardCreationControllerProvider =
    NotifierProvider<PromoCardCreationController, PromoCardCreationState>(
      PromoCardCreationController.new,
    );

class PromoCardCreationController extends Notifier<PromoCardCreationState> {
  late CardRepository _repo;

  @override
  PromoCardCreationState build() {
    _repo = ref.read(cardRepositoryProvider);
    return const PromoCardCreationState();
  }

  void reset() => state = const PromoCardCreationState();

  /// Step 1 — call prepare. Auto-advances to confirm stage.
  Future<void> prepare() async {
    final availability = availabilityFromRef(ref);
    if (!availability.cards.creation.enabled) {
      state = state.copyWith(
        stage: PromoCardStage.preparing,
        isBusy: false,
        errorMessage: ErrorHelper.l10n.errServiceUnavailable,
      );
      return;
    }

    debugPrint('💳 [PromoCard] Starting prepare...');
    state = state.copyWith(
      stage: PromoCardStage.preparing,
      isBusy: true,
      clearError: true,
      clearPrepare: true,
      clearResult: true,
    );

    try {
      final prepare = await _repo.preparePromoCard();
      debugPrint(
        '💳 [PromoCard] Prepare done — canCreate=${prepare.canCreate}',
      );
      state = state.copyWith(
        stage: PromoCardStage.confirm,
        isBusy: false,
        prepare: prepare,
      );
    } on ApiError catch (e) {
      debugPrint('💳 [PromoCard] Prepare ApiError: ${e.message}');
      state = state.copyWith(isBusy: false, errorMessage: e.message);
    } catch (e) {
      final msg = ErrorHelper.getErrorMessage(e);
      debugPrint('💳 [PromoCard] Prepare error: $msg');
      state = state.copyWith(isBusy: false, errorMessage: msg);
    }
  }

  /// Step 2 — user confirmed; call create-promo.
  Future<void> createCard() async {
    final availability = availabilityFromRef(ref);
    if (!availability.cards.creation.enabled) {
      state = state.copyWith(
        stage: PromoCardStage.confirm,
        isBusy: false,
        errorMessage: ErrorHelper.l10n.errServiceUnavailable,
      );
      return;
    }

    final prepare = state.prepare;
    if (prepare == null || !prepare.canCreate) return;

    final idempotencyKey =
        'promo-${prepare.cardUserId ?? 'user'}-${DateTime.now().millisecondsSinceEpoch}';

    debugPrint('💳 [PromoCard] Creating card (key=$idempotencyKey)...');
    state = state.copyWith(
      stage: PromoCardStage.creating,
      isBusy: true,
      clearError: true,
    );

    try {
      final result = await _repo.createPromoCard(
        idempotencyKey: idempotencyKey,
      );
      debugPrint(
        '💳 [PromoCard] Card created — ref=${result.reference} status=${result.status}',
      );

      // Refresh wallet balance in background (don't block success screen).
      ref
          .read(dashboardControllerProvider.notifier)
          .refreshBalance(showSpinner: false);

      state = state.copyWith(
        stage: PromoCardStage.success,
        isBusy: false,
        result: result,
      );
    } on ApiError catch (e) {
      debugPrint('💳 [PromoCard] Create ApiError: ${e.message}');
      state = state.copyWith(
        stage: PromoCardStage.confirm,
        isBusy: false,
        errorMessage: _mapCreateError(e.message),
      );
    } catch (e) {
      final msg = ErrorHelper.getErrorMessage(e);
      debugPrint('💳 [PromoCard] Create error: $msg');
      state = state.copyWith(
        stage: PromoCardStage.confirm,
        isBusy: false,
        errorMessage: msg,
      );
    }
  }

  String _mapCreateError(String raw) {
    final l10n = ErrorHelper.l10n;
    final code = raw.toUpperCase().trim();
    switch (code) {
      case 'USER_NOT_REGISTERED_FOR_CARD':
        return l10n.cardsPromoRegistrationIssueError;
      case 'INSUFFICIENT_FUNDS':
        return l10n.cardsPromoBalanceChangedError;
      case 'PROMO_CARD_CONFIG_NOT_FOUND':
        return l10n.cardsPromoUnavailableLaterError;
      case 'WALLET_SERVICE_UNAVAILABLE':
      case 'WALLET_UNAVAILABLE':
        return l10n.cardsPromoWalletUnavailableError;
      default:
        return raw.isNotEmpty ? raw : l10n.errGenericRetry;
    }
  }
}
