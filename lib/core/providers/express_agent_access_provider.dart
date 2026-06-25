import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/data/models/express_agent_status.dart';

/// Cached Express agent access for the current session.
///
/// Fetched once after login / session restore so the app knows from the very
/// first dashboard paint whether to show the Agent tab. Defaults to a safe
/// non-agent state and never throws — a failed fetch simply hides agent UI.
@immutable
class ExpressAgentAccess {
  /// Whether we have completed at least one status fetch this session.
  final bool loaded;
  final ExpressAgentStatus status;

  const ExpressAgentAccess({
    required this.loaded,
    required this.status,
  });

  static const ExpressAgentAccess initial = ExpressAgentAccess(
    loaded: false,
    status: ExpressAgentStatus.none,
  );

  bool get isAgent => status.isAgent;
  bool get isActive => status.isActive;
  String? get agentProfileId => status.agentProfileId;

  ExpressAgentAccess copyWith({
    bool? loaded,
    ExpressAgentStatus? status,
  }) {
    return ExpressAgentAccess(
      loaded: loaded ?? this.loaded,
      status: status ?? this.status,
    );
  }
}

class ExpressAgentAccessNotifier extends Notifier<ExpressAgentAccess> {
  bool _inFlight = false;

  @override
  ExpressAgentAccess build() => ExpressAgentAccess.initial;

  /// Fetches agent status from the gateway. Safe to call multiple times;
  /// overlapping calls are ignored. Failures keep the user as a non-agent.
  Future<void> refresh() async {
    if (_inFlight) return;
    _inFlight = true;
    try {
      final status =
          await ref.read(expressOrderRepositoryProvider).getAgentStatus();
      state = ExpressAgentAccess(loaded: true, status: status);
    } catch (e) {
      debugPrint('⚠️ Express agent status fetch failed (treating as non-agent): $e');
      // Mark as loaded so the UI stops waiting; default stays non-agent.
      state = const ExpressAgentAccess(
        loaded: true,
        status: ExpressAgentStatus.none,
      );
    } finally {
      _inFlight = false;
    }
  }

  /// Clears cached access on logout.
  void clear() {
    state = ExpressAgentAccess.initial;
  }
}

final expressAgentAccessProvider =
    NotifierProvider<ExpressAgentAccessNotifier, ExpressAgentAccess>(
  ExpressAgentAccessNotifier.new,
);
