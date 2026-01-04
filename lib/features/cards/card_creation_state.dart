import 'package:opei/core/money/money.dart';
import 'package:opei/data/models/card_creation_preview.dart';
import 'package:opei/data/models/card_creation_response.dart';
import 'package:opei/data/models/card_user_registration_response.dart';
import 'package:opei/data/models/virtual_card.dart';

enum CardCreationStage {
  registering,
  amountEntry,
  preview,
  creating,
  success,
}

class CardCreationState {
  final CardCreationStage stage;
  final bool isBusy;
  final String? errorMessage;
  final String? infoMessage;
  final CardUserRegistrationResponse? registration;
  final Money? amount;
  final CardCreationPreview? preview;
  final CardCreationResponse? creation;
  final VirtualCard? createdCard;

  const CardCreationState({
    this.stage = CardCreationStage.registering,
    this.isBusy = false,
    this.errorMessage,
    this.infoMessage,
    this.registration,
    this.amount,
    this.preview,
    this.creation,
    this.createdCard,
  });

  CardCreationState copyWith({
    CardCreationStage? stage,
    bool? isBusy,
    String? errorMessage,
    String? infoMessage,
    CardUserRegistrationResponse? registration,
    Money? amount,
    CardCreationPreview? preview,
    CardCreationResponse? creation,
    VirtualCard? createdCard,
    bool clearError = false,
    bool clearInfo = false,
    bool clearRegistration = false,
    bool clearAmount = false,
    bool clearPreview = false,
    bool clearCreation = false,
    bool clearCreatedCard = false,
  }) {
    return CardCreationState(
      stage: stage ?? this.stage,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      registration: clearRegistration ? null : (registration ?? this.registration),
      amount: clearAmount ? null : (amount ?? this.amount),
      preview: clearPreview ? null : (preview ?? this.preview),
      creation: clearCreation ? null : (creation ?? this.creation),
      createdCard: clearCreatedCard ? null : (createdCard ?? this.createdCard),
    );
  }

  CardCreationState clearError() => copyWith(clearError: true);

  CardCreationState clearInfo() => copyWith(clearInfo: true);
}