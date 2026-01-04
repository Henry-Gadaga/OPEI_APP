import 'package:opei/core/network/api_client.dart';
import 'package:opei/core/money/money.dart';
import 'package:opei/data/models/card_creation_preview.dart';
import 'package:opei/data/models/card_creation_response.dart';
import 'package:opei/data/models/card_details.dart';
import 'package:opei/data/models/card_topup_preview.dart';
import 'package:opei/data/models/card_topup_response.dart';
import 'package:opei/data/models/card_withdraw_preview.dart';
import 'package:opei/data/models/card_withdraw_response.dart';
import 'package:opei/data/models/card_user_registration_response.dart';
import 'package:opei/data/models/card_transactions_page.dart';
import 'package:opei/data/models/virtual_card.dart';

class CardRepository {
  final ApiClient _apiClient;

  CardRepository(this._apiClient);

  Future<CardUserRegistrationResponse> registerUser() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/card/cards/register-user',
    );

    return CardUserRegistrationResponse.fromJson(response);
  }

  Future<CardCreationPreview> previewCreation({int? initialLoadCents}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/card/cards/preview',
      queryParameters: initialLoadCents != null
          ? {
              'initialLoadCents': initialLoadCents,
            }
          : null,
    );

    return CardCreationPreview.fromJson(response);
  }

  Future<CardCreationResponse> createCard({required int initialLoadCents}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/card/cards/create',
      data: {
        'initialLoadCents': initialLoadCents,
      },
    );

    return CardCreationResponse.fromJson(response);
  }

  Future<List<VirtualCard>> fetchCards() async {
    final response = await _apiClient.get<List<dynamic>>('/card/cards');

    if (response.isEmpty) {
      return const [];
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(VirtualCard.fromJson)
        .toList(growable: false);
  }

  Future<CardTransactionsPage> fetchCardTransactions(
    String cardId, {
    int page = 1,
    int? take,
    String order = 'DESC',
  }) async {
    final sanitizedOrder = order.toUpperCase() == 'ASC' ? 'ASC' : 'DESC';

    final queryParameters = <String, dynamic>{
      'page': page < 1 ? 1 : page,
      'order': sanitizedOrder,
    };

    if (take != null && take > 0) {
      queryParameters['take'] = take;
    }

    final payload = await _apiClient.get<dynamic>(
      '/card/cards/$cardId/transactions',
      queryParameters: queryParameters,
    );

    final items = CardTransactionsPage.extractItems(payload);
    return CardTransactionsPage.fromPayload(
      payload: payload,
      items: items,
      fallbackPage: page,
      fallbackLimit: take ?? items.length,
    );
  }

  Future<CardDetails> fetchCardDetails(
    String cardId, {
    String currency = 'USD',
    Money? fallbackBalance,
  }) async {
    final payload = await _apiClient.get<Map<String, dynamic>>(
      '/card/cards/$cardId/details',
    );

    return CardDetails.fromJson(
      payload,
      currency: currency,
      fallbackBalance: fallbackBalance,
    );
  }

  Future<String> freezeCard(String cardId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/card/cards/freeze',
      data: {'cardId': cardId},
    );

    if (response.isEmpty) {
      return 'Card locked';
    }

    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return 'Card locked';
  }

  Future<String> unfreezeCard(String cardId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/card/cards/unfreeze',
      data: {'cardId': cardId},
    );

    if (response.isEmpty) {
      return 'Card unlocked';
    }

    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return 'Card unlocked';
  }

  Future<String> terminateCard(String cardId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/card/cards/terminate',
      data: {'cardId': cardId},
    );

    if (response.isEmpty) {
      return 'Card terminated';
    }

    final message = response['message']?.toString().trim();
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return 'Card terminated';
  }

  Future<CardTopUpPreview> previewTopUp({
    required String cardId,
    required int amountCents,
    String currency = 'USD',
  }) async {
    final response = await _apiClient.get<dynamic>(
      '/card/cards/topup/preview',
      queryParameters: {
        'crid': cardId,
        'amountCents': amountCents,
      },
    );

    final payload = _unwrapDataEnvelope(response);

    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid top-up preview payload');
    }

    return CardTopUpPreview.fromJson(
      payload,
      currency: currency,
      fallbackAmount: Money.fromCents(amountCents, currency: currency),
    );
  }

  Future<CardTopUpResponse> confirmTopUp({
    required String cardId,
    required int amountCents,
    String currency = 'USD',
  }) async {
    final response = await _apiClient.post<dynamic>(
      '/card/cards/topup',
      data: {
        'crid': cardId,
        'amountCents': amountCents,
      },
    );

    final payload = _unwrapDataEnvelope(response);

    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid top-up response payload');
    }

    return CardTopUpResponse.fromJson(
      payload,
      currency: currency,
      fallbackAmountCents: amountCents,
    );
  }

  Future<CardWithdrawPreview> previewWithdraw({
    required String cardId,
    required int amountCents,
    String currency = 'USD',
  }) async {
    final response = await _apiClient.get<dynamic>(
      '/card/cards/withdraw/preview',
      queryParameters: {
        'cardId': cardId,
        'amountCents': amountCents,
      },
    );

    final payload = _unwrapDataEnvelope(response);

    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid withdraw preview payload');
    }

    return CardWithdrawPreview.fromJson(
      payload,
      currency: currency,
      fallbackAmount: Money.fromCents(amountCents, currency: currency),
    );
  }

  Future<CardWithdrawResponse> confirmWithdraw({
    required String cardId,
    required int amountCents,
    String currency = 'USD',
    int? feeCents,
    int? netCents,
  }) async {
    final response = await _apiClient.post<dynamic>(
      '/card/cards/withdraw',
      data: {
        'cardId': cardId,
        'amountCents': amountCents,
      },
    );

    final payload = _unwrapDataEnvelope(response);

    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid withdraw response payload');
    }

    return CardWithdrawResponse.fromJson(
      payload,
      currency: currency,
      fallbackAmountCents: amountCents,
      fallbackFeeCents: feeCents,
      fallbackNetCents: netCents,
    );
  }

  dynamic _unwrapDataEnvelope(dynamic response) {
    if (response is Map<String, dynamic>) {
      if (response.containsKey('success')) {
        final success = response['success'] == true;
        if (!success) {
          final message = response['message']?.toString().trim();
          throw Exception(message?.isNotEmpty == true ? message : 'Request failed');
        }

        final data = response['data'];
        if (data != null) {
          return data;
        }
      }
      return response;
    }

    return response;
  }
}