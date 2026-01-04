import 'package:opei/core/money/money.dart';

/// Preview response returned by the transfer preview endpoint.
class TransferPreviewResponse {
  final String fromWalletId;
  final String toWalletId;
  final Money transferAmount;
  final Money estimatedFee;
  final String feeAppliedTo;
  final Money totalDebit;
  final Money senderBalanceBefore;
  final Money senderBalanceAfter;
  final Money receiverCreditAmount;

  TransferPreviewResponse({
    required this.fromWalletId,
    required this.toWalletId,
    required this.transferAmount,
    required this.estimatedFee,
    required this.feeAppliedTo,
    required this.totalDebit,
    required this.senderBalanceBefore,
    required this.senderBalanceAfter,
    required this.receiverCreditAmount,
  });

  factory TransferPreviewResponse.fromJson(
    Map<String, dynamic> json, {
    required String currency,
    int? fallbackTransferAmountCents,
    int? fallbackEstimatedFeeCents,
    int? fallbackTotalDebitCents,
    int? fallbackSenderBalanceBeforeCents,
    int? fallbackSenderBalanceAfterCents,
    int? fallbackReceiverCreditAmountCents,
  }) {
    Money parseMoney(
      dynamic value, {
      int? fallback,
    }) =>
        Money.fromJson(
          value,
          currency: currency,
          fallbackCents: fallback,
        );

    final transferAmountMoney = parseMoney(
      json['transferAmount'] ?? json['transfer_amount'],
      fallback: fallbackTransferAmountCents,
    );

    final estimatedFeeMoney = parseMoney(
      json['estimatedFee'] ?? json['estimated_fee'],
      fallback: fallbackEstimatedFeeCents,
    );

    final totalDebitMoney = parseMoney(
      json['totalDebit'] ?? json['total_debit'],
      fallback: fallbackTotalDebitCents ??
          ((fallbackTransferAmountCents ?? transferAmountMoney.cents) + estimatedFeeMoney.cents),
    );

    final receiverCreditMoney = parseMoney(
      json['receiverCreditAmount'] ?? json['receiver_credit_amount'],
      fallback: fallbackReceiverCreditAmountCents ??
          (fallbackTransferAmountCents ?? transferAmountMoney.cents),
    );

    return TransferPreviewResponse(
      fromWalletId: json['fromWalletId'] as String? ?? json['from_wallet_id'] as String? ?? '',
      toWalletId: json['toWalletId'] as String? ?? json['to_wallet_id'] as String? ?? '',
      transferAmount: transferAmountMoney,
      estimatedFee: estimatedFeeMoney,
      feeAppliedTo: (json['feeAppliedTo'] ?? json['fee_applied_to'] ?? '').toString(),
      totalDebit: totalDebitMoney,
      senderBalanceBefore: parseMoney(
        json['senderBalanceBefore'] ?? json['sender_balance_before'],
        fallback: fallbackSenderBalanceBeforeCents,
      ),
      senderBalanceAfter: parseMoney(
        json['senderBalanceAfter'] ?? json['sender_balance_after'],
        fallback: fallbackSenderBalanceAfterCents,
      ),
      receiverCreditAmount: receiverCreditMoney,
    );
  }

  Map<String, dynamic> toJson() => {
        'fromWalletId': fromWalletId,
        'toWalletId': toWalletId,
        'transferAmount': transferAmount.cents,
        'estimatedFee': estimatedFee.cents,
        'feeAppliedTo': feeAppliedTo,
        'totalDebit': totalDebit.cents,
        'senderBalanceBefore': senderBalanceBefore.cents,
        'senderBalanceAfter': senderBalanceAfter.cents,
        'receiverCreditAmount': receiverCreditAmount.cents,
      };

  Money get transferAmountMoney => transferAmount;
  Money get estimatedFeeMoney => estimatedFee;
  Money get totalDebitMoney => totalDebit;
  Money get senderBalanceBeforeMoney => senderBalanceBefore;
  Money get senderBalanceAfterMoney => senderBalanceAfter;
  Money get receiverCreditAmountMoney => receiverCreditAmount;
}