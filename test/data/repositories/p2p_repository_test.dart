import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:opei/core/network/api_client.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/storage/secure_storage_service.dart';
import 'package:opei/data/models/p2p_ad.dart';
import 'package:opei/data/models/p2p_trade.dart';
import 'package:opei/data/models/user_model.dart';
import 'package:opei/data/repositories/p2p_repository.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('P2PRepository', () {
    test('fetchAds parses payload list into domain objects', () async {
      final apiClient = _MockApiClient();
      final repository = P2PRepository(apiClient, _StubSecureStorageService());

      when(() => apiClient.get<Map<String, dynamic>>(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer(
        (_) async => {
          'data': [
            {
              'id': 'ad-1',
              'userId': 'seller-1',
              'type': 'BUY',
              'currency': 'USD',
              'totalAmountCents': 500000,
              'remainingAmountCents': 250000,
              'minOrderCents': 10000,
              'maxOrderCents': 200000,
              'rateCents': 100,
              'instructions': 'Ping me',
              'status': 'ACTIVE',
              'paymentMethods': [
                {
                  'id': 'pm-1',
                  'providerName': 'Bank Transfer',
                  'methodType': 'BANK',
                  'currency': 'USD',
                },
              ],
              'seller': {
                'id': 'seller-1',
                'displayName': 'Alice',
                'nickname': 'alice',
                'rating': 4.8,
                'totalTrades': 20,
              },
            },
          ],
        },
      );

      final ads = await repository.fetchAds(
        type: P2PAdType.buy,
        currency: 'USD',
      );

      expect(ads, hasLength(1));
      expect(ads.first.id, 'ad-1');
      expect(ads.first.paymentMethods, isNotEmpty);
    });

    test('cancelTrade returns parsed trade from response payload', () async {
      final apiClient = _MockApiClient();
      final repository = P2PRepository(apiClient, _StubSecureStorageService());

      when(() => apiClient.post<Map<String, dynamic>>(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => {
          'data': {
            'id': 'trade-1',
            'adId': 'ad-1',
            'buyerId': 'buyer',
            'sellerId': 'seller',
            'amountCents': 10000,
            'sendAmountCents': 10000,
            'rateCents': 100,
            'currency': 'USD',
            'status': 'CANCELLED',
            'ad': {
              'id': 'ad-1',
              'type': 'SELL',
              'currency': 'USD',
              'rateCents': 100,
              'paymentMethods': const [],
            },
          },
        },
      );

      final trade = await repository.cancelTrade(tradeId: 'trade-1');

      expect(trade.id, 'trade-1');
      expect(trade.status, P2PTradeStatus.cancelled);
    });

    test('prepareTradeProofUploads throws when user id missing', () async {
      final apiClient = _MockApiClient();
      final repository = P2PRepository(apiClient, _StubSecureStorageService());

      final request = P2PTradeProofUploadRequest(
        fileName: 'proof.png',
        contentType: 'image/png',
      );

      await expectLater(
        repository.prepareTradeProofUploads(
          tradeId: 'trade-1',
          files: [request],
        ),
        throwsA(isA<ApiError>()),
      );
    });

    test('prepareTradeProofUploads returns plans and includes user header', () async {
      final apiClient = _MockApiClient();
      final repository = P2PRepository(
        apiClient,
        _StubSecureStorageService(
          user: UserModel(
            id: 'user-1',
            email: 'tester@example.com',
            phone: '+123456789',
            role: 'user',
            status: 'active',
            userStage: 'VERIFIED',
            isEmailVerified: true,
            isPhoneVerified: true,
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
          ),
        ),
      );

      when(() => apiClient.post<Map<String, dynamic>>(
            any(),
            data: any(named: 'data'),
            headers: any(named: 'headers'),
          )).thenAnswer(
        (_) async => {
          'uploadUrl': 'https://upload',
          'fileUrl': 'https://file',
          'headers': {'x-test': 'value'},
        },
      );

      final plans = await repository.prepareTradeProofUploads(
        tradeId: 'trade-1',
        files: const [
          P2PTradeProofUploadRequest(fileName: 'proof.png', contentType: 'image/png'),
        ],
      );

      expect(plans, hasLength(1));
      final capturedHeaders = verify(
        () => apiClient.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          headers: captureAny(named: 'headers'),
        ),
      ).captured.single as Map<String, dynamic>;

      expect(capturedHeaders['x-user-id'], 'user-1');
    });
  });
}

class _StubSecureStorageService extends SecureStorageService {
  _StubSecureStorageService({this.user}) : super(const FlutterSecureStorage());

  final UserModel? user;

  @override
  Future<UserModel?> getUser() async => user;
}
