/// Result of `GET /p2p/express-orders/agent/status`.
///
/// Drives whether the Express Agent area is visible and whether the agent can
/// perform actions (accept / confirm).
class ExpressAgentStatus {
  /// Whether the current user is registered as an Express agent.
  final bool isAgent;

  /// Whether the agent account is active. An admin can deactivate an agent, in
  /// which case the Agent tab stays visible but actions are disabled.
  final bool isActive;

  /// Backend agent profile id (null for non-agents).
  final String? agentProfileId;

  const ExpressAgentStatus({
    required this.isAgent,
    required this.isActive,
    this.agentProfileId,
  });

  /// Safe default used before the first fetch and on any failure. Treating an
  /// unknown user as a non-agent ensures we never surface agent UI by accident.
  static const ExpressAgentStatus none = ExpressAgentStatus(
    isAgent: false,
    isActive: false,
    agentProfileId: null,
  );

  factory ExpressAgentStatus.fromJson(Map<String, dynamic> json) {
    return ExpressAgentStatus(
      isAgent: json['isAgent'] == true,
      isActive: json['isActive'] == true,
      agentProfileId: (json['agentProfileId'] as Object?)?.toString(),
    );
  }
}
