import 'package:opei/data/models/promo_card_create_result.dart';
import 'package:opei/data/models/promo_card_prepare.dart';

enum PromoCardStage {
  /// Calling prepare — no user input needed.
  preparing,

  /// Prepare succeeded — show pricing breakdown for user to confirm.
  confirm,

  /// Calling create-promo — spinner shown.
  creating,

  /// Card created successfully — show success screen.
  success,
}

class PromoCardCreationState {
  final PromoCardStage stage;
  final bool isBusy;
  final String? errorMessage;
  final PromoCardPrepare? prepare;
  final PromoCardCreateResult? result;

  const PromoCardCreationState({
    this.stage = PromoCardStage.preparing,
    this.isBusy = false,
    this.errorMessage,
    this.prepare,
    this.result,
  });

  PromoCardCreationState copyWith({
    PromoCardStage? stage,
    bool? isBusy,
    String? errorMessage,
    PromoCardPrepare? prepare,
    PromoCardCreateResult? result,
    bool clearError = false,
    bool clearPrepare = false,
    bool clearResult = false,
  }) {
    return PromoCardCreationState(
      stage: stage ?? this.stage,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      prepare: clearPrepare ? null : (prepare ?? this.prepare),
      result: clearResult ? null : (result ?? this.result),
    );
  }
}
