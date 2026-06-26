import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/card_creation_response.dart';
import 'package:opei/data/models/virtual_card.dart';
import 'package:opei/data/repositories/card_repository.dart';
import 'package:opei/features/cards/card_creation_state.dart';
import 'package:opei/features/dashboard/dashboard_controller.dart';

class CardCreationController extends Notifier<CardCreationState> {
  static String get _cardReadyMessage => ErrorHelper.l10n.cardsCreationReadyContinueInfo;
  static String get _completeProfileMessage =>
      ErrorHelper.l10n.cardsCreationCompleteProfileError;
  static String get _genericTryAgainMessage => ErrorHelper.l10n.errGenericRetry;
  static String get _sessionExpiredContinueMessage =>
      ErrorHelper.l10n.cardsCreationSessionExpiredContinueError;
  static String get _serviceUnavailableMessage =>
      ErrorHelper.l10n.cardsCreationServiceUnavailableError;

  late CardRepository _cardRepository;

  @override
  CardCreationState build() {
    _cardRepository = ref.read(cardRepositoryProvider);
    return const CardCreationState();
  }

  void reset() {
    state = const CardCreationState();
  }

  Future<void> startRegistration() async {
    debugPrint('💳 Starting card registration flow...');
    state = state.copyWith(
      stage: CardCreationStage.registering,
      isBusy: true,
      clearError: true,
      clearInfo: true,
      clearAmount: true,
      clearPreview: true,
      clearCreation: true,
      clearCreatedCard: true,
    );

    try {
      final response = await _cardRepository.registerUser();
      final alreadyRegisteredMessage = response.alreadyRegistered
          ? _cardReadyMessage
          : null;

      state = state.copyWith(
        stage: CardCreationStage.amountEntry,
        isBusy: false,
        registration: response,
        infoMessage: alreadyRegisteredMessage,
        clearInfo: alreadyRegisteredMessage == null,
        clearError: true,
      );

      debugPrint(
        '✅ Card registration resolved. alreadyRegistered=${response.alreadyRegistered}',
      );
    } catch (error) {
      final handled = _handleRegistrationError(error);

      if (handled.allowContinue) {
        state = state.copyWith(
          stage: CardCreationStage.amountEntry,
          isBusy: false,
          infoMessage: handled.message,
          clearError: true,
          clearRegistration: true,
        );
        debugPrint(
          'ℹ️ Registration skipped with allowContinue=true: ${handled.message}',
        );
        return;
      }

      state = state.copyWith(
        isBusy: false,
        errorMessage: handled.message,
        clearInfo: true,
        clearAmount: true,
        clearPreview: true,
        clearCreation: true,
      );
      debugPrint('❌ Card registration failed: ${handled.message}');
    }
  }

  Future<void> loadPreview(Money amount) async {
    if (amount.cents <= 0) {
      state = state.copyWith(
        errorMessage: ErrorHelper.l10n.cardsCreationAmountAboveZeroError,
        clearInfo: true,
      );
      return;
    }

    state = state.copyWith(
      isBusy: true,
      stage: CardCreationStage.amountEntry,
      amount: amount,
      clearError: true,
      clearInfo: true,
      clearPreview: true,
      clearCreatedCard: true,
    );

    try {
      final preview = await _cardRepository.previewCreation(
        initialLoadCents: amount.cents,
      );

      state = state.copyWith(
        stage: CardCreationStage.preview,
        isBusy: false,
        preview: preview,
        clearError: true,
        clearCreatedCard: true,
      );

      debugPrint(
        '✅ Card creation preview loaded. Total charge: ${preview.totalToCharge.cents}',
      );
    } catch (error) {
      final message = _mapPreviewError(error);
      state = state.copyWith(
        stage: CardCreationStage.amountEntry,
        isBusy: false,
        errorMessage: message,
      );
      debugPrint('❌ Failed to load card preview: $message');
    }
  }

  Future<void> submitCreation() async {
    final currentPreview = state.preview;
    final amount = state.amount;

    if (currentPreview == null || amount == null) {
      state = state.copyWith(
        errorMessage: ErrorHelper.l10n.cardsCreationPreviewMissingError,
      );
      return;
    }

    if (!currentPreview.canCreate ||
        currentPreview.walletBalanceAfter.isNegative) {
      state = state.copyWith(
        stage: CardCreationStage.preview,
        isBusy: false,
        errorMessage: ErrorHelper.l10n.cardsCreationAddFundsError,
        clearInfo: true,
      );
      return;
    }

    state = state.copyWith(
      stage: CardCreationStage.creating,
      isBusy: true,
      clearError: true,
      clearInfo: true,
    );

    try {
      final response = await _cardRepository.createCard(
        initialLoadCents: amount.cents,
      );

      state = state.copyWith(
        stage: CardCreationStage.success,
        isBusy: true,
        creation: response,
        clearInfo: true,
        clearError: true,
        clearCreatedCard: true,
      );

      debugPrint(
        '🎉 Card creation submitted. Reference: ${response.reference}',
      );

      // Refresh wallet balance in the background after successful card creation.
      unawaited(
        ref
            .read(dashboardControllerProvider.notifier)
            .refreshBalance(showSpinner: false),
      );

      unawaited(_hydrateCreatedCard(response));
    } catch (error) {
      final message = _mapCreationError(error);
      state = state.copyWith(
        stage: CardCreationStage.preview,
        isBusy: false,
        errorMessage: message,
      );
      debugPrint('❌ Card creation failed: $message');
    }
  }

  void backToAmountEntry() {
    if (state.stage == CardCreationStage.preview) {
      state = state.copyWith(
        stage: CardCreationStage.amountEntry,
        isBusy: false,
        clearError: true,
        clearInfo: true,
        clearPreview: true,
        clearCreation: true,
        clearCreatedCard: true,
      );
    }
  }

  Future<void> _hydrateCreatedCard(CardCreationResponse response) async {
    try {
      final cards = await _cardRepository.fetchCards();
      final createdCard = _selectCreatedCard(cards, response.cardId);

      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(
        isBusy: false,
        createdCard: createdCard,
        clearInfo: createdCard != null,
        infoMessage: createdCard == null
            ? ErrorHelper.l10n.cardsCreationWillAppearSoonInfo
            : null,
      );
    } catch (error, stackTrace) {
      debugPrint('⚠️ Failed to load created card: $error');
      debugPrint('$stackTrace');

      if (!ref.mounted) {
        return;
      }

      state = state.copyWith(
        isBusy: false,
        infoMessage:
            ErrorHelper.l10n.cardsCreationReadyAppearSoonInfo,
      );
    }
  }

  VirtualCard? _selectCreatedCard(List<VirtualCard> cards, String rawId) {
    if (cards.isEmpty) {
      return null;
    }

    final normalizedId = rawId.trim().toLowerCase();
    if (normalizedId.isEmpty) {
      return null;
    }

    for (final card in cards) {
      if (card.id.trim().toLowerCase() == normalizedId) {
        return card;
      }
    }

    return null;
  }

  _RegistrationResolution _handleRegistrationError(Object error) {
    if (error is ApiError) {
      final statusCode = error.statusCode;
      final rawMessage = error.message.toLowerCase().trim();

      switch (statusCode) {
        case 409:
          return _RegistrationResolution(
            message: _cardReadyMessage,
            allowContinue: true,
          );
        case 400:
        case 422:
          return _RegistrationResolution(message: _completeProfileMessage);
        case 401:
          if (rawMessage.contains('secret')) {
            return _RegistrationResolution(message: _genericTryAgainMessage);
          }
          if (rawMessage.contains('authorization') ||
              rawMessage.contains('auth')) {
            return _RegistrationResolution(
              message: _sessionExpiredContinueMessage,
            );
          }
          return _RegistrationResolution(
            message: _sessionExpiredContinueMessage,
          );
        case 502:
        case 503:
          return _RegistrationResolution(message: _serviceUnavailableMessage);
        case 404:
          return _RegistrationResolution(message: _genericTryAgainMessage);
      }
    }

    return _RegistrationResolution(message: ErrorHelper.getErrorMessage(error));
  }

  String _mapPreviewError(Object error) {
    if (error is ApiError) {
      switch (error.statusCode) {
        case 404:
          return ErrorHelper.l10n.cardsCreationRegisterProfileError;
        case 422:
          return ErrorHelper.l10n.cardsCreationBalanceLowError;
        case 401:
          return ErrorHelper.l10n.errSessionExpired;
        case 503:
        case 502:
          return ErrorHelper.l10n.cardsCreationServiceUnavailableSoonError;
      }
    }

    return ErrorHelper.getErrorMessage(error);
  }

  String _mapCreationError(Object error) {
    if (error is ApiError) {
      switch (error.statusCode) {
        case 404:
          return ErrorHelper.l10n.cardsCreationRegisterProfilePromptError;
        case 422:
          return ErrorHelper.l10n.cardsCreationBalanceLowError;
        case 503:
        case 502:
          return ErrorHelper.l10n.cardsCreationServiceUnavailableSoonError;
        case 409:
          return ErrorHelper.l10n.cardsCreationRequestProcessingError;
        case 401:
          return ErrorHelper.l10n.errSessionExpired;
      }
    }

    return ErrorHelper.getErrorMessage(error);
  }
}

class _RegistrationResolution {
  final String message;
  final bool allowContinue;

  _RegistrationResolution({required this.message, this.allowContinue = false});
}

final cardCreationControllerProvider =
    NotifierProvider<CardCreationController, CardCreationState>(
      CardCreationController.new,
    );
