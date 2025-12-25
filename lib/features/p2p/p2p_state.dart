import 'package:tt1/data/models/p2p_ad.dart';
import 'package:tt1/data/models/p2p_trade.dart';
import 'package:tt1/data/models/p2p_user_profile.dart';

class P2PAdsState {
  final List<P2PAd> allAds;
  final List<P2PAd> filteredAds;
  final List<String> paymentMethods;
  final P2PAdType selectedType;
  final String selectedCurrencyCode;
  final String? selectedPaymentMethod;
  final int? minAmountCents;
  final int? maxAmountCents;
  final bool isLoading;
  final bool isRefreshing;
  final bool hasLoaded;
  final String? errorMessage;
  final String? infoMessage;

  const P2PAdsState({
    this.allAds = const <P2PAd>[],
    this.filteredAds = const <P2PAd>[],
    this.paymentMethods = const <String>[],
    this.selectedType = P2PAdType.buy,
    this.selectedCurrencyCode = 'USD',
    this.selectedPaymentMethod,
    this.minAmountCents,
    this.maxAmountCents,
    this.isLoading = false,
    this.isRefreshing = false,
    this.hasLoaded = false,
    this.errorMessage,
    this.infoMessage,
  });

  P2PAdsState copyWith({
    List<P2PAd>? allAds,
    List<P2PAd>? filteredAds,
    List<String>? paymentMethods,
    P2PAdType? selectedType,
    String? selectedCurrencyCode,
    String? selectedPaymentMethod,
    bool clearSelectedPaymentMethod = false,
    int? minAmountCents,
    bool clearMinAmount = false,
    int? maxAmountCents,
    bool clearMaxAmount = false,
    bool? isLoading,
    bool? isRefreshing,
    bool? hasLoaded,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
  }) {
    return P2PAdsState(
      allAds: allAds ?? this.allAds,
      filteredAds: filteredAds ?? this.filteredAds,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedType: selectedType ?? this.selectedType,
      selectedCurrencyCode: selectedCurrencyCode ?? this.selectedCurrencyCode,
      selectedPaymentMethod: clearSelectedPaymentMethod
          ? null
          : (selectedPaymentMethod ?? this.selectedPaymentMethod),
      minAmountCents: clearMinAmount ? null : (minAmountCents ?? this.minAmountCents),
      maxAmountCents: clearMaxAmount ? null : (maxAmountCents ?? this.maxAmountCents),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }
}

enum MyP2PAdStatusFilter {
  all,
  pendingReview,
  active,
  inactive,
  completed,
  rejected;

  String get displayLabel {
    switch (this) {
      case MyP2PAdStatusFilter.all:
        return 'All';
      case MyP2PAdStatusFilter.pendingReview:
        return 'Pending';
      case MyP2PAdStatusFilter.active:
        return 'Active';
      case MyP2PAdStatusFilter.inactive:
        return 'Inactive';
      case MyP2PAdStatusFilter.completed:
        return 'Completed';
      case MyP2PAdStatusFilter.rejected:
        return 'Rejected';
    }
  }

  String? get queryValue {
    switch (this) {
      case MyP2PAdStatusFilter.all:
        return null;
      case MyP2PAdStatusFilter.pendingReview:
        return 'PENDING_REVIEW';
      case MyP2PAdStatusFilter.active:
        return 'ACTIVE';
      case MyP2PAdStatusFilter.inactive:
        return 'INACTIVE';
      case MyP2PAdStatusFilter.completed:
        return 'COMPLETED';
      case MyP2PAdStatusFilter.rejected:
        return 'REJECTED';
    }
  }
}

class MyP2PAdsState {
  final List<P2PAd> ads;
  final bool isLoading;
  final bool isRefreshing;
  final bool hasLoaded;
  final MyP2PAdStatusFilter selectedFilter;
  final String? errorMessage;
  final String? infoMessage;
  final Set<String>? _deactivatingAdIds;

  const MyP2PAdsState({
    this.ads = const <P2PAd>[],
    this.isLoading = false,
    this.isRefreshing = false,
    this.hasLoaded = false,
    this.selectedFilter = MyP2PAdStatusFilter.all,
    this.errorMessage,
    this.infoMessage,
    Set<String>? deactivatingAdIds,
  }) : _deactivatingAdIds = deactivatingAdIds;

  Set<String> get deactivatingAdIds => _deactivatingAdIds ?? const <String>{};

  MyP2PAdsState copyWith({
    List<P2PAd>? ads,
    bool? isLoading,
    bool? isRefreshing,
    bool? hasLoaded,
    MyP2PAdStatusFilter? selectedFilter,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
    Set<String>? deactivatingAdIds,
    bool clearDeactivating = false,
  }) {
    Set<String>? nextPending;
    if (clearDeactivating) {
      nextPending = const <String>{};
    } else if (deactivatingAdIds != null) {
      nextPending = Set.unmodifiable(deactivatingAdIds);
    } else {
      nextPending = _deactivatingAdIds;
    }

    return MyP2PAdsState(
      ads: ads ?? this.ads,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      deactivatingAdIds: nextPending,
    );
  }
}

extension MyP2PAdsStateX on MyP2PAdsState {
  /// Gracefully handles stale state shaped before [deactivatingAdIds] existed during hot reloads.
  bool isAdDeactivating(String adId) {
    try {
      final dynamic pending = _deactivatingAdIds;
      if (pending is Set) {
        return pending.contains(adId);
      }
    } catch (_) {
      // Legacy instances may not have the backing field; treat as not deactivating.
    }
    return false;
  }
}

class P2PProfileState {
  final P2PUserProfile? profile;
  final bool isLoading;
  final bool isRefreshing;
  final bool hasLoaded;
  final bool isMissingProfile;
  final String? errorMessage;

  const P2PProfileState({
    this.profile,
    this.isLoading = false,
    this.isRefreshing = false,
    this.hasLoaded = false,
    this.isMissingProfile = false,
    this.errorMessage,
  });

  P2PProfileState copyWith({
    P2PUserProfile? profile,
    bool clearProfile = false,
    bool? isLoading,
    bool? isRefreshing,
    bool? hasLoaded,
    bool? isMissingProfile,
    String? errorMessage,
    bool clearError = false,
  }) {
    return P2PProfileState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isMissingProfile: isMissingProfile ?? this.isMissingProfile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

enum P2POrderStatusFilter {
  all,
  initiated,
  paidByBuyer,
  releasedBySeller,
  completed,
  cancelled,
  disputed,
  expired;

  String get displayLabel {
    switch (this) {
      case P2POrderStatusFilter.all:
        return 'All';
      case P2POrderStatusFilter.initiated:
        return 'Active';
      case P2POrderStatusFilter.paidByBuyer:
        return 'Paid';
      case P2POrderStatusFilter.releasedBySeller:
        return 'Released';
      case P2POrderStatusFilter.completed:
        return 'Completed';
      case P2POrderStatusFilter.cancelled:
        return 'Cancelled';
      case P2POrderStatusFilter.disputed:
        return 'Disputed';
      case P2POrderStatusFilter.expired:
        return 'Expired';
    }
  }

  String? get queryValue {
    switch (this) {
      case P2POrderStatusFilter.all:
        return null;
      case P2POrderStatusFilter.initiated:
        return P2PTradeStatus.initiated.apiValue;
      case P2POrderStatusFilter.paidByBuyer:
        return P2PTradeStatus.paidByBuyer.apiValue;
      case P2POrderStatusFilter.releasedBySeller:
        return P2PTradeStatus.releasedBySeller.apiValue;
      case P2POrderStatusFilter.completed:
        return P2PTradeStatus.completed.apiValue;
      case P2POrderStatusFilter.cancelled:
        return P2PTradeStatus.cancelled.apiValue;
      case P2POrderStatusFilter.disputed:
        return P2PTradeStatus.disputed.apiValue;
      case P2POrderStatusFilter.expired:
        return P2PTradeStatus.expired.apiValue;
    }
  }
}

class P2POrdersState {
  final List<P2PTrade> trades;
  final bool isLoading;
  final bool isRefreshing;
  final bool hasLoaded;
  final P2POrderStatusFilter selectedFilter;
  final String? errorMessage;
  final String? infoMessage;
  final Set<String>? _cancellingTradeIds;

  const P2POrdersState({
    this.trades = const <P2PTrade>[],
    this.isLoading = false,
    this.isRefreshing = false,
    this.hasLoaded = false,
    this.selectedFilter = P2POrderStatusFilter.all,
    this.errorMessage,
    this.infoMessage,
    Set<String>? cancellingTradeIds,
  }) : _cancellingTradeIds = cancellingTradeIds;

  Set<String> get cancellingTradeIds => _cancellingTradeIds ?? const <String>{};

  P2POrdersState copyWith({
    List<P2PTrade>? trades,
    bool? isLoading,
    bool? isRefreshing,
    bool? hasLoaded,
    P2POrderStatusFilter? selectedFilter,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
    Set<String>? cancellingTradeIds,
    bool clearCancelling = false,
  }) {
    Set<String>? nextCancelling;
    if (clearCancelling) {
      nextCancelling = const <String>{};
    } else if (cancellingTradeIds != null) {
      nextCancelling = Set.unmodifiable(cancellingTradeIds);
    } else {
      nextCancelling = _cancellingTradeIds;
    }

    return P2POrdersState(
      trades: trades ?? this.trades,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      cancellingTradeIds: nextCancelling,
    );
  }
}

extension P2POrdersStateX on P2POrdersState {
  bool isTradeCancelling(String tradeId) {
    try {
      final dynamic pending = _cancellingTradeIds;
      if (pending is Set) {
        return pending.contains(tradeId);
      }
    } catch (_) {
      // Legacy instances may not have the backing field; treat as not cancelling.
    }
    return false;
  }
}