import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/network/api_error.dart';
import 'package:tt1/core/providers/providers.dart';
import 'package:tt1/core/utils/error_helper.dart';
import 'package:tt1/data/models/p2p_ad.dart';
import 'package:tt1/data/models/p2p_trade.dart';
import 'package:tt1/data/repositories/p2p_repository.dart';
import 'package:tt1/features/p2p/p2p_state.dart';

final p2pAdsControllerProvider = NotifierProvider<P2PAdsController, P2PAdsState>(
  P2PAdsController.new,
);

final myP2PAdsControllerProvider = NotifierProvider<MyP2PAdsController, MyP2PAdsState>(
  MyP2PAdsController.new,
);

final p2pProfileControllerProvider = NotifierProvider<P2PProfileController, P2PProfileState>(
  P2PProfileController.new,
);

final p2pOrdersControllerProvider = NotifierProvider<P2POrdersController, P2POrdersState>(
  P2POrdersController.new,
);

class P2PAdsController extends Notifier<P2PAdsState> {
  late P2PRepository _repository;
  Object? _activeFetchToken;

  @override
  P2PAdsState build() {
    _repository = ref.read(p2pRepositoryProvider);
    return const P2PAdsState();
  }

  Future<void> ensureInitialLoad() async {
    final current = state;
    if (current.hasLoaded || current.isLoading) {
      return;
    }
    await _fetchAds();
  }

  Future<void> reload() => _fetchAds();

  Future<void> refresh() => _fetchAds(asRefresh: true);

  Future<void> updateType(P2PAdType type) async {
    if (state.selectedType == type) {
      return;
    }

    final shouldTreatAsRefresh = state.hasLoaded;

    state = state.copyWith(
      selectedType: type,
      clearError: true,
      clearInfo: true,
    );

    await _fetchAds(asRefresh: shouldTreatAsRefresh);
  }

  Future<void> updateCurrency(String currencyCode) async {
    final normalized = currencyCode.toUpperCase();
    if (state.selectedCurrencyCode == normalized) {
      return;
    }

    final shouldTreatAsRefresh = state.hasLoaded;

    state = state.copyWith(
      selectedCurrencyCode: normalized,
      clearError: true,
      clearInfo: true,
    );

    await _fetchAds(asRefresh: shouldTreatAsRefresh);
  }

  Future<void> updateAmountBounds({int? minAmountCents, int? maxAmountCents}) async {
    final shouldClearMin = minAmountCents == null || minAmountCents <= 0;
    final shouldClearMax = maxAmountCents == null || maxAmountCents <= 0;

    final effectiveMin = shouldClearMin ? null : minAmountCents;
    final effectiveMax = shouldClearMax ? null : maxAmountCents;

    if (effectiveMin != null && effectiveMax != null && effectiveMin > effectiveMax) {
      state = state.copyWith(
        errorMessage: 'The minimum amount can’t be higher than the maximum.',
        clearInfo: true,
      );
      return;
    }

    final hasMinChanged = effectiveMin != state.minAmountCents;
    final hasMaxChanged = effectiveMax != state.maxAmountCents;

    if (!hasMinChanged && !hasMaxChanged) {
      return;
    }

    state = state.copyWith(
      minAmountCents: effectiveMin,
      clearMinAmount: effectiveMin == null,
      maxAmountCents: effectiveMax,
      clearMaxAmount: effectiveMax == null,
      clearError: true,
      clearInfo: true,
    );

    await _fetchAds(asRefresh: state.hasLoaded);
  }

  void updatePaymentMethod(String? paymentMethodLabel) {
    final normalized = paymentMethodLabel?.trim();
    final nextSelection = normalized == null || normalized.isEmpty ? null : normalized;

    final filtered = _filterAds(state.allAds, nextSelection);
    final shouldClearSelection = nextSelection == null;

    state = state.copyWith(
      selectedPaymentMethod: nextSelection,
      clearSelectedPaymentMethod: shouldClearSelection,
      filteredAds: filtered,
      infoMessage: filtered.isEmpty ? 'No ads available right now.' : null,
      clearInfo: filtered.isNotEmpty,
      clearError: true,
    );
  }

  Future<void> _fetchAds({bool asRefresh = false}) async {
    final fetchToken = Object();
    _activeFetchToken = fetchToken;

    final intentType = state.selectedType;

    state = state.copyWith(
      isLoading: asRefresh ? state.isLoading : true,
      isRefreshing: asRefresh,
      hasLoaded: asRefresh ? state.hasLoaded : false,
      clearError: true,
      clearInfo: true,
    );

    try {
      final ads = await _repository.fetchAds(
        type: intentType.counterpart,
        currency: state.selectedCurrencyCode,
        minAmountCents: state.minAmountCents,
        maxAmountCents: state.maxAmountCents,
      );

      if (_activeFetchToken != fetchToken) {
        return;
      }

      final paymentMethods = _extractPaymentMethods(ads);
      final selectedMethod = state.selectedPaymentMethod;
      final effectiveSelection =
          selectedMethod != null && paymentMethods.contains(selectedMethod) ? selectedMethod : null;

      final filteredAds = _filterAds(ads, effectiveSelection);

      state = state.copyWith(
        allAds: ads,
        filteredAds: filteredAds,
        paymentMethods: paymentMethods,
        selectedPaymentMethod: effectiveSelection,
        isLoading: false,
        isRefreshing: false,
        hasLoaded: true,
        infoMessage: filteredAds.isEmpty ? 'No ads available right now.' : null,
        clearInfo: filteredAds.isNotEmpty,
        clearError: true,
      );
    } catch (error, stackTrace) {
      if (_activeFetchToken != fetchToken) {
        return;
      }

      debugPrint('❌ Failed to load P2P ads: $error');
      debugPrint('$stackTrace');
      final friendly = _resolveFriendlyError(error);

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        hasLoaded: true,
        errorMessage: friendly,
        clearInfo: true,
      );
    } finally {
      if (_activeFetchToken == fetchToken) {
        _activeFetchToken = null;
      }
    }
  }

  List<String> _extractPaymentMethods(List<P2PAd> ads) {
    final set = LinkedHashSet<String>();
    for (final ad in ads) {
      for (final method in ad.paymentMethods) {
        final label = method.providerName.trim();
        if (label.isNotEmpty) {
          set.add(label);
        }
      }
    }
    final list = set.toList(growable: false);
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  List<P2PAd> _filterAds(List<P2PAd> ads, String? paymentMethodLabel) {
    if (paymentMethodLabel == null) {
      return List<P2PAd>.unmodifiable(ads);
    }

    final filtered = ads
        .where(
          (ad) => ad.paymentMethods.any(
            (method) => method.providerName == paymentMethodLabel,
          ),
        )
        .toList(growable: false);

    return List<P2PAd>.unmodifiable(filtered);
  }

  String _resolveFriendlyError(Object error) {
    if (error is ApiError) {
      final statusCode = error.statusCode;
      final message = error.message.toLowerCase();

      if (statusCode == 400) {
        if (message.contains('minamountcents cannot be greater than maxamountcents')) {
          return 'The minimum amount can’t be higher than the maximum.';
        }
        return 'We couldn’t apply those filters. Please try again.';
      }

      if (statusCode != null && statusCode >= 500) {
        return 'Something went wrong. Please try again.';
      }
    }

    return ErrorHelper.getErrorMessage(error);
  }
}

class MyP2PAdsController extends Notifier<MyP2PAdsState> {
  late P2PRepository _repository;
  Object? _activeFetchToken;

  @override
  MyP2PAdsState build() {
    _repository = ref.read(p2pRepositoryProvider);
    return const MyP2PAdsState();
  }

  Future<void> ensureInitialLoad() async {
    final current = state;
    if (current.hasLoaded || current.isLoading) {
      return;
    }
    await _fetchMyAds();
  }

  Future<void> reload() => _fetchMyAds();

  Future<void> refresh() => _fetchMyAds(asRefresh: true);

  Future<void> updateFilter(MyP2PAdStatusFilter filter) async {
    if (state.selectedFilter == filter) {
      return;
    }

    state = state.copyWith(
      selectedFilter: filter,
      clearError: true,
      clearInfo: true,
    );

    await _fetchMyAds();
  }

  Future<void> _fetchMyAds({bool asRefresh = false}) async {
    final fetchToken = Object();
    _activeFetchToken = fetchToken;

    state = state.copyWith(
      isLoading: asRefresh ? state.isLoading : true,
      isRefreshing: asRefresh,
      hasLoaded: asRefresh ? state.hasLoaded : false,
      clearError: true,
      clearInfo: true,
    );

    try {
      final ads = await _repository.fetchMyAds(status: state.selectedFilter.queryValue);

      if (_activeFetchToken != fetchToken) {
        return;
      }

      state = state.copyWith(
        ads: List<P2PAd>.unmodifiable(ads),
        isLoading: false,
        isRefreshing: false,
        hasLoaded: true,
        infoMessage: ads.isEmpty ? 'No ads found for this status yet.' : null,
        clearInfo: ads.isNotEmpty,
        clearDeactivating: true,
      );
    } catch (error, stackTrace) {
      if (_activeFetchToken != fetchToken) {
        return;
      }

      debugPrint('❌ Failed to load my P2P ads: $error');
      debugPrint('$stackTrace');

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        hasLoaded: true,
        errorMessage: ErrorHelper.getErrorMessage(error),
        clearInfo: true,
      );
    } finally {
      if (_activeFetchToken == fetchToken) {
        _activeFetchToken = null;
      }
    }
  }

  Future<String> deactivateAd(String adId) async {
    final pendingIds = <String>{...state.deactivatingAdIds, adId};
    state = state.copyWith(
      deactivatingAdIds: pendingIds,
      clearError: true,
    );

    try {
      final updated = await _repository.deactivateAd(adId: adId);
      final normalizedStatus = updated.status.trim().toUpperCase();
      final ads = state.ads.toList(growable: true);
      final index = ads.indexWhere((element) => element.id == adId);

      if (index != -1) {
        if (_matchesFilter(normalizedStatus, state.selectedFilter)) {
          ads[index] = updated;
        } else {
          ads.removeAt(index);
        }
      }

      final remaining = <String>{...pendingIds}..remove(adId);

      state = state.copyWith(
        ads: List<P2PAd>.unmodifiable(ads),
        deactivatingAdIds: remaining,
        clearError: true,
      );

      return normalizedStatus == 'INACTIVE'
          ? 'Ad moved to inactive.'
          : 'Ad updated.';
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to deactivate P2P ad $adId: $error');
      debugPrint('$stackTrace');

      final remaining = <String>{...pendingIds}..remove(adId);
      state = state.copyWith(
        deactivatingAdIds: remaining,
      );

      final friendly = _mapDeactivateError(error);
      throw friendly;
    }
  }

  bool _matchesFilter(String status, MyP2PAdStatusFilter filter) {
    final normalized = status.trim().toUpperCase();
    switch (filter) {
      case MyP2PAdStatusFilter.all:
        return true;
      case MyP2PAdStatusFilter.pendingReview:
        return normalized == 'PENDING_REVIEW';
      case MyP2PAdStatusFilter.active:
        return normalized == 'ACTIVE';
      case MyP2PAdStatusFilter.inactive:
        return normalized == 'INACTIVE';
      case MyP2PAdStatusFilter.completed:
        return normalized == 'COMPLETED';
      case MyP2PAdStatusFilter.rejected:
        return normalized == 'REJECTED';
    }
  }

  String _mapDeactivateError(Object error) {
    if (error is ApiError) {
      final status = error.statusCode ?? 0;
      if (status == 400) {
        return 'You can only deactivate your own ads.';
      }
      if (status == 404) {
        return 'This ad is no longer available.';
      }
      if (status == 401 || status == 403) {
        return 'Your session expired. Please sign in again.';
      }
      if (status >= 500) {
        return 'We couldn’t deactivate this ad right now. Please try again.';
      }
    }

    return ErrorHelper.getErrorMessage(error);
  }
}

class P2PProfileController extends Notifier<P2PProfileState> {
  late P2PRepository _repository;

  @override
  P2PProfileState build() {
    _repository = ref.read(p2pRepositoryProvider);
    return const P2PProfileState();
  }

  Future<void> ensureProfileLoaded() async {
    final current = state;
    if (current.hasLoaded || current.isLoading) {
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    final hasRenderableState = state.profile != null || state.isMissingProfile;

    state = state.copyWith(
      isLoading: hasRenderableState ? false : true,
      isRefreshing: hasRenderableState,
      hasLoaded: hasRenderableState ? state.hasLoaded : false,
      clearProfile: hasRenderableState ? false : true,
      isMissingProfile: hasRenderableState ? state.isMissingProfile : false,
      clearError: true,
    );
    try {
      final profile = await _repository.fetchUserProfile();
      state = state.copyWith(
        profile: profile,
        clearProfile: profile == null,
        isLoading: false,
        isRefreshing: false,
        hasLoaded: true,
        isMissingProfile: profile == null,
        clearError: true,
      );
    } catch (error, stackTrace) {
      debugPrint('❌ Failed to load P2P profile: $error');
      debugPrint('$stackTrace');
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        hasLoaded: true,
        isMissingProfile: false,
        errorMessage: _mapError(error),
      );
    }
  }

  String _mapError(Object error) {
    if (error is ApiError) {
      final statusCode = error.statusCode ?? 0;
      final message = error.message.toLowerCase();

      if (statusCode == 400 || statusCode == 401) {
        if (message.contains('missing') && message.contains('x-user-id')) {
          return 'We couldn’t verify your session. Please sign in again to view your profile.';
        }
        return 'We couldn’t verify your session. Please sign in again.';
      }

      if (statusCode == 403) {
        return 'You don’t have permission to view this profile.';
      }

      if (statusCode >= 500) {
        return 'We’re having trouble loading your profile right now. Please try again.';
      }

      return 'We couldn’t load your profile right now. Please try again.';
    }

    return ErrorHelper.getErrorMessage(error);
  }
}

class P2POrdersController extends Notifier<P2POrdersState> {
  late P2PRepository _repository;
  Object? _activeFetchToken;

  @override
  P2POrdersState build() {
    _repository = ref.read(p2pRepositoryProvider);
    return const P2POrdersState();
  }

  Future<void> ensureInitialLoad() async {
    final current = state;
    if (current.hasLoaded || current.isLoading) {
      return;
    }
    await _fetchTrades();
  }

  Future<void> reload() => _fetchTrades();

  Future<void> refresh() => _fetchTrades(asRefresh: true);

  Future<void> updateFilter(P2POrderStatusFilter filter) async {
    if (state.selectedFilter == filter) {
      return;
    }

    state = state.copyWith(
      selectedFilter: filter,
      clearError: true,
      clearInfo: true,
    );

    await _fetchTrades();
  }

  Future<P2PTrade> cancelTrade(P2PTrade trade) async {
    final tradeId = trade.id;
    if (tradeId.isEmpty) {
      throw 'We couldn’t identify this trade. Please try again.';
    }

    final pending = state.cancellingTradeIds.toSet()..add(tradeId);
    state = state.copyWith(cancellingTradeIds: pending);

    try {
      final updated = await _repository.cancelTrade(tradeId: tradeId);

      final remaining = state.cancellingTradeIds.toSet()
        ..remove(tradeId);
      var nextTrades = state.trades;
      if (nextTrades.any((item) => item.id == updated.id)) {
        nextTrades = nextTrades
            .map((item) => item.id == updated.id ? updated : item)
            .toList(growable: false);
      }

      state = state.copyWith(
        cancellingTradeIds: remaining,
        trades: nextTrades,
      );

      // Refresh so the trade list respects the active filter (e.g., removes trade from Active view).
      await _fetchTrades(asRefresh: true);
      return updated;
    } catch (error) {
      final remaining = state.cancellingTradeIds.toSet()
        ..remove(tradeId);
      state = state.copyWith(cancellingTradeIds: remaining);
      throw _mapCancelError(error, trade: trade);
    }
  }

  Future<void> _fetchTrades({bool asRefresh = false}) async {
    final fetchToken = Object();
    _activeFetchToken = fetchToken;

    state = state.copyWith(
      isLoading: asRefresh ? state.isLoading : true,
      isRefreshing: asRefresh,
      hasLoaded: asRefresh ? state.hasLoaded : false,
      clearError: true,
      clearInfo: true,
    );

    try {
      final trades = await _repository.fetchMyTrades(status: state.selectedFilter.queryValue);

      if (_activeFetchToken != fetchToken) {
        return;
      }

      final sorted = trades.toList(growable: true)
        ..sort((a, b) {
          final aDate = a.updatedAt ?? a.createdAt;
          final bDate = b.updatedAt ?? b.createdAt;
          if (aDate == null && bDate == null) {
            return 0;
          }
          if (aDate == null) {
            return 1;
          }
          if (bDate == null) {
            return -1;
          }
          return bDate.compareTo(aDate);
        });

      final immutable = List<P2PTrade>.unmodifiable(sorted);

      state = state.copyWith(
        trades: immutable,
        isLoading: false,
        isRefreshing: false,
        hasLoaded: true,
        errorMessage: null,
        infoMessage: immutable.isEmpty ? 'No orders in this status yet.' : null,
        clearInfo: immutable.isNotEmpty,
        clearError: true,
      );
    } catch (error, stackTrace) {
      if (_activeFetchToken != fetchToken) {
        return;
      }

      debugPrint('❌ Failed to load P2P trades: $error');
      debugPrint('$stackTrace');

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        hasLoaded: true,
        errorMessage: _mapError(error),
        clearInfo: true,
      );
    } finally {
      if (_activeFetchToken == fetchToken) {
        _activeFetchToken = null;
      }
    }
  }

  String _mapError(Object error) {
    if (error is ApiError) {
      final status = error.statusCode ?? 0;
      if (status == 401) {
        return 'We couldn’t verify your session. Please sign in again.';
      }
      if (status == 400) {
        return 'That filter isn’t available. Please pick another status.';
      }
      if (status >= 500) {
        return 'We’re having trouble loading your orders right now. Please try again.';
      }
    }
    return ErrorHelper.getErrorMessage(error);
  }

  String _mapCancelError(Object error, {required P2PTrade trade}) {
    if (error is ApiError) {
      final status = error.statusCode ?? 0;
      final message = error.message.trim();
      final normalized = message.toLowerCase();

      if (status == 401) {
        return 'We couldn’t verify your session. Please sign in again.';
      }

      if (status == 404) {
        return 'We couldn’t find this trade. It may have been removed.';
      }

      if (status == 403) {
        return _cancelPermissionMessage(trade);
      }

      if (status == 400) {
        if (normalized.contains('cannot') && normalized.contains('cancel')) {
          return 'This trade can’t be cancelled anymore.';
        }
        if (normalized.contains('already') && normalized.contains('cancel')) {
          return 'This trade is already cancelled.';
        }
        return 'We couldn’t cancel this trade. Please try again.';
      }

      if (status >= 500) {
        return 'We’re having trouble cancelling this trade right now. Please try again.';
      }

      if (message.isNotEmpty) {
        return message;
      }
    }

    final fallback = error.toString().toLowerCase();
    if (fallback.contains('missing') && fallback.contains('x-user-id')) {
      return 'We couldn’t verify your session. Please sign in again.';
    }
    if (fallback.contains('unauthorized')) {
      return 'Please sign in again to continue.';
    }
    return 'We couldn’t cancel this trade right now. Please try again.';
  }

  String _cancelPermissionMessage(P2PTrade trade) {
    if (trade.ad.type == P2PAdType.sell) {
      return 'Only the buyer who opened this trade can cancel it.';
    }
    return 'Only the seller who listed this ad can cancel it.';
  }
}