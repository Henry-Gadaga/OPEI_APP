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
          ? 'Your card is ready. You can continue setting up your card.'
          : null;

      state = state.copyWith(
        stage: CardCreationStage.amountEntry,
        isBusy: false,
        registration: response,
        infoMessage: alreadyRegisteredMessage,
        clearInfo: alreadyRegisteredMessage == null,
        clearError: true,
      );

      debugPrint('✅ Card registration resolved. alreadyRegistered=${response.alreadyRegistered}');
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
        debugPrint('ℹ️ Registration skipped with allowContinue=true: ${handled.message}');
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
        errorMessage: 'Enter an amount above 0.00 to continue.',
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

      debugPrint('✅ Card creation preview loaded. Total charge: ${preview.totalToCharge.cents}');
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
      state = state.copyWith(errorMessage: 'Preview details are missing. Please try again.');
      return;
    }

    if (!currentPreview.canCreate || currentPreview.walletBalanceAfter.isNegative) {
      state = state.copyWith(
        stage: CardCreationStage.preview,
        isBusy: false,
        errorMessage: 'Add funds to your wallet before creating this card.',
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

      debugPrint('🎉 Card creation submitted. Reference: ${response.reference}');

      // Refresh wallet balance in the background after successful card creation.
      unawaited(ref.read(dashboardControllerProvider.notifier).refreshBalance(showSpinner: false));

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
            ? "Your card is created. It will appear in your cards list shortly."
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
        infoMessage: "Your card is ready. It will appear in your cards list shortly.",
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
            message: 'Your card is ready. You can continue setting up your card.',
            allowContinue: true,
          );
        case 400:
        case 422:
          return _RegistrationResolution(
            message: 'Complete your profile to continue.',
          );
        case 401:
          if (rawMessage.contains('secret')) {
            return _RegistrationResolution(
              message: 'Something went wrong. Please try again in a moment.',
            );
          }
          if (rawMessage.contains('authorization') || rawMessage.contains('auth')) {
            return _RegistrationResolution(
              message: 'Session expired. Please sign in again to continue.',
            );
          }
          return _RegistrationResolution(
            message: 'Session expired. Please sign in again to continue.',
          );
        case 502:
        case 503:
          return _RegistrationResolution(
            message: 'Card service temporarily unavailable. Please try again shortly.',
          );
        case 404:
          return _RegistrationResolution(
            message: 'Something went wrong. Please try again in a moment.',
          );
      }
    }

    return _RegistrationResolution(
      message: ErrorHelper.getErrorMessage(error),
    );
  }

  String _mapPreviewError(Object error) {
    if (error is ApiError) {
      switch (error.statusCode) {
        case 404:
          return 'You need to register your card profile before continuing.';
        case 422:
          return 'Your balance is too low to complete this action.';
        case 401:
          return 'Your session has expired. Please log in again.';
        case 503:
        case 502:
          return 'Card services are temporarily unavailable. Please try again soon.';
      }
    }

    return ErrorHelper.getErrorMessage(error);
  }

  String _mapCreationError(Object error) {
    if (error is ApiError) {
      switch (error.statusCode) {
        case 404:
          return 'Please register your card profile before continuing.';
        case 422:
          return 'Your balance is too low to complete this action.';
        case 503:
        case 502:
          return 'Card services are temporarily unavailable. Please try again soon.';
        case 409:
          return 'This request is already being processed.';
        case 401:
          return 'Your session has expired. Please log in again.';
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

final cardCreationControllerProvider = NotifierProvider<CardCreationController, CardCreationState>(
  CardCreationController.new,
);