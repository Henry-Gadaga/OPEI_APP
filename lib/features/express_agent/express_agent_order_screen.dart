import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/express_agent_access_provider.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/express_order.dart';
import 'package:opei/data/repositories/express_order_repository.dart';
import 'package:opei/features/express_p2p/express_ui.dart';
import 'package:opei/theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Agent's view of a single order: shows customer payment proofs and lets the
/// agent confirm once the customer has marked the order paid.
class ExpressAgentOrderScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String? initialBuyerContactNumber;
  const ExpressAgentOrderScreen({
    super.key,
    required this.orderId,
    this.initialBuyerContactNumber,
  });

  @override
  ConsumerState<ExpressAgentOrderScreen> createState() =>
      _ExpressAgentOrderScreenState();
}

class _ExpressAgentOrderScreenState
    extends ConsumerState<ExpressAgentOrderScreen> {
  ExpressOrder? _order;
  bool _loading = true;
  String? _error;
  bool _confirming = false;
  bool _openingDispute = false;
  String? _cachedBuyerContactNumber;

  @override
  void initState() {
    super.initState();
    _cachedBuyerContactNumber = _sanitizePhone(
      widget.initialBuyerContactNumber,
    );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final order = await ref
          .read(expressOrderRepositoryProvider)
          .fetchOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _cachedBuyerContactNumber =
            _sanitizePhone(order.buyerContactNumber) ??
            _cachedBuyerContactNumber;
        _loading = false;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = ErrorHelper.getErrorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _confirm() async {
    if (_confirming) return;
    final confirmed = await _confirmReleaseToBuyer();
    if (confirmed != true || !mounted) return;
    setState(() => _confirming = true);
    try {
      final order = await ref
          .read(expressOrderRepositoryProvider)
          .confirmOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _confirming = false;
      });
      _toast(
        'Order confirmed. Funds released to the customer.',
        OpeiBrand.success,
      );
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _confirming = false);
      _toast(e.message, OpeiBrand.danger);
    } catch (e) {
      if (!mounted) return;
      setState(() => _confirming = false);
      _toast(ErrorHelper.getErrorMessage(e), OpeiBrand.danger);
    }
  }

  Future<void> _openDispute() async {
    final order = _order;
    if (order == null || _openingDispute) return;
    final draft = await showModalBottomSheet<_AgentDisputeDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AgentDisputeSheet(),
    );
    if (draft == null || draft.message.trim().isEmpty) return;
    setState(() => _openingDispute = true);
    try {
      final uploads = draft.images
          .where((f) => f.bytes != null)
          .map(
            (f) => ExpressProofUpload(
              contentType: _mimeFor(f.extension),
              bytes: f.bytes!,
            ),
          )
          .toList(growable: false);
      final imageUrls = uploads.isEmpty
          ? const <String>[]
          : await ref
                .read(expressOrderRepositoryProvider)
                .uploadProofs(uploads);
      final updated = await ref
          .read(expressOrderRepositoryProvider)
          .openDispute(
            orderId: order.id,
            message: draft.message,
            imageUrls: imageUrls.take(5).toList(growable: false),
          );
      if (!mounted) return;
      setState(() {
        _order = updated;
        _openingDispute = false;
      });
      _toast('Dispute opened. Under admin review.', OpeiBrand.ink);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _openingDispute = false);
      _toast(_mapErrorMessage(e), OpeiBrand.danger);
    } catch (e) {
      if (!mounted) return;
      setState(() => _openingDispute = false);
      _toast(ErrorHelper.getErrorMessage(e), OpeiBrand.danger);
    }
  }

  String _mimeFor(String? ext) {
    switch ((ext ?? '').toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  String _mapErrorMessage(ApiError e) {
    switch (e.statusCode) {
      case 403:
        return 'You are not allowed to perform this action.';
      case 404:
        return 'Order no longer exists.';
      case 409:
        return 'Order updated by another action. Refreshing...';
      case 400:
      default:
        return e.message;
    }
  }

  void _toast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  Future<bool?> _confirmReleaseToBuyer() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OpeiBrand.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        ),
        title: const Text(
          'Confirm payment received?',
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: OpeiBrand.ink,
          ),
        ),
        content: const Text(
          'Only continue if the money is in your account. This will release USD to the buyer and cannot be undone. A wrong confirmation may cause financial loss.',
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 13.5,
            color: OpeiBrand.inkSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Not yet',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                color: OpeiBrand.inkSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: OpeiBrand.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Yes, release',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(expressAgentAccessProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: OpeiBrand.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: OpeiBrand.surface,
        appBar: AppBar(
          backgroundColor: OpeiBrand.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: OpeiBrand.ink),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            'Order',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(top: false, child: _buildBody(access.isActive)),
      ),
    );
  }

  Widget _buildBody(bool isActive) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: OpeiBrand.primary),
      );
    }

    if (_order == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error ?? 'Order not found.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 14,
              color: OpeiBrand.inkSecondary,
            ),
          ),
        ),
      );
    }

    final order = _order!;
    final buyerContact =
        _sanitizePhone(order.buyerContactNumber) ?? _cachedBuyerContactNumber;
    final canConfirm =
        order.status == ExpressOrderStatus.paidByUser && isActive;
    final canDispute =
        order.status == ExpressOrderStatus.paidByUser &&
        (order.dispute == null || order.dispute!.isResolved);
    final showBuyerNumber =
        order.status.shouldShowContact && buyerContact != null;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    expressUsd(order.amountUsdCents),
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: OpeiBrand.ink,
                      letterSpacing: -0.5,
                    ),
                  ),
                  ExpressStatusPill(view: expressAgentStatusView(order.status)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OpeiBrand.surface,
                  borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                  border: Border.all(color: OpeiBrand.hairline),
                ),
                child: Column(
                  children: [
                    _Row(
                      label: 'Customer pays',
                      value: expressFiat(
                        order.fiatAmountCents,
                        order.quoteCurrency,
                      ),
                    ),
                    const _RowDivider(),
                    _Row(
                      label: 'You release',
                      value: expressUsd(order.amountUsdCents),
                    ),
                    if ((order.paymentMethodType?.providerName ?? '')
                        .isNotEmpty) ...[
                      const _RowDivider(),
                      _Row(
                        label: 'Method',
                        value: order.paymentMethodType!.providerName,
                      ),
                    ],
                  ],
                ),
              ),
              if (showBuyerNumber) ...[
                const SizedBox(height: 12),
                _ContactCard(number: buyerContact),
              ],
              if (order.status == ExpressOrderStatus.disputed) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE8EA),
                    borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                  ),
                  child: const Text(
                    'Under review by admin.',
                    style: TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: OpeiBrand.danger,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'PAYMENT PROOF',
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: OpeiBrand.inkTertiary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              _ProofGallery(urls: order.proofUrls, status: order.status),
            ],
          ),
        ),
        if (order.status == ExpressOrderStatus.paidByUser)
          Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canDispute) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: _openingDispute ? null : _openDispute,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: OpeiBrand.danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            OpeiBrand.radiusCard,
                          ),
                        ),
                      ),
                      child: _openingDispute
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: OpeiBrand.danger,
                              ),
                            )
                          : const Text(
                              'Open dispute',
                              style: TextStyle(
                                fontFamily: kPrimaryFontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: OpeiBrand.danger,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (!isActive)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Your agent account is inactive. You cannot confirm orders.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 12.5,
                        color: OpeiBrand.danger,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (canConfirm && !_confirming) ? _confirm : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OpeiBrand.primary,
                      disabledBackgroundColor: OpeiBrand.primaryTintStrong,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          OpeiBrand.radiusCard,
                        ),
                      ),
                    ),
                    child: _confirming
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirm payment received',
                            style: TextStyle(
                              fontFamily: kPrimaryFontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String? _sanitizePhone(String? value) {
  final text = value?.trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

class _AgentDisputeDraft {
  final String message;
  final List<PlatformFile> images;

  const _AgentDisputeDraft({required this.message, required this.images});
}

class _AgentDisputeSheet extends StatefulWidget {
  const _AgentDisputeSheet();

  @override
  State<_AgentDisputeSheet> createState() => _AgentDisputeSheetState();
}

class _AgentDisputeSheetState extends State<_AgentDisputeSheet> {
  static const int _maxImages = 5;
  final TextEditingController _messageController = TextEditingController();
  final List<PlatformFile> _images = <PlatformFile>[];
  String? _error;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;
      final picked = result.files.where((f) => f.bytes != null).toList();
      setState(() {
        for (final file in picked) {
          if (_images.length >= _maxImages) break;
          _images.add(file);
        }
        _error = null;
      });
    } catch (_) {
      setState(() => _error = 'Could not pick images.');
    }
  }

  void _submit() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() => _error = 'Dispute message is required.');
      return;
    }
    Navigator.of(context).pop(
      _AgentDisputeDraft(
        message: message,
        images: List<PlatformFile>.from(_images),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: OpeiBrand.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 14, 20, 16 + bottomPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Open dispute',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: OpeiBrand.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              minLines: 3,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Explain the issue...',
                filled: true,
                fillColor: OpeiBrand.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._images.asMap().entries.map(
                  (entry) => Chip(
                    label: Text(
                      entry.value.name.isEmpty
                          ? 'Image ${entry.key + 1}'
                          : entry.value.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onDeleted: () =>
                        setState(() => _images.removeAt(entry.key)),
                  ),
                ),
                if (_images.length < _maxImages)
                  ActionChip(label: const Text('Add image'), onPressed: _pick),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 12.5,
                  color: OpeiBrand.danger,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OpeiBrand.danger,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                  ),
                ),
                child: const Text(
                  'Submit dispute',
                  style: TextStyle(
                    fontFamily: kPrimaryFontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProofGallery extends StatelessWidget {
  final List<String> urls;
  final ExpressOrderStatus status;

  const _ProofGallery({required this.urls, required this.status});

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OpeiBrand.surfaceMuted,
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        ),
        child: Text(
          status == ExpressOrderStatus.awaitingPayment
              ? 'Waiting for the customer to pay and upload proof.'
              : 'No proof uploaded yet.',
          style: const TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 13,
            color: OpeiBrand.inkSecondary,
            height: 1.4,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: urls
          .map(
            (url) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () => _openProofViewer(context, url),
                child: Image.network(
                  url,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 100,
                    height: 100,
                    color: OpeiBrand.surfaceMuted,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: OpeiBrand.inkTertiary,
                    ),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      width: 100,
                      height: 100,
                      color: OpeiBrand.surfaceMuted,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: OpeiBrand.primary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

void _openProofViewer(BuildContext context, String imageUrl) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.9),
    builder: (dialogContext) {
      return Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Could not open this image.',
                        style: TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: OpeiBrand.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: OpeiBrand.inkSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.ink,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 0.5, color: OpeiBrand.hairline);
  }
}

class _ContactCard extends StatelessWidget {
  final String? number;
  const _ContactCard({required this.number});

  @override
  Widget build(BuildContext context) {
    final contact = number?.trim();
    final hasContact = contact != null && contact.isNotEmpty;
    final safeContact = contact ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        border: Border.all(color: OpeiBrand.hairline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 400;
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ContactInfo(hasContact: hasContact, contact: contact),
                if (hasContact) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _ContactActions(contact: safeContact),
                  ),
                ],
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: _ContactInfo(hasContact: hasContact, contact: contact),
              ),
              if (hasContact) ...[
                const SizedBox(width: 8),
                _ContactActions(contact: safeContact),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  final bool hasContact;
  final String? contact;

  const _ContactInfo({required this.hasContact, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.phone_outlined, size: 18, color: OpeiBrand.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buyer contact',
                style: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: OpeiBrand.inkTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hasContact ? contact! : 'Buyer contact unavailable',
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: OpeiBrand.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactActions extends StatelessWidget {
  final String contact;

  const _ContactActions({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: contact));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Buyer number copied'),
                backgroundColor: OpeiBrand.ink,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
                ),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              ),
            );
          },
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Copy',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.inkSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () => _openDialer(context, contact),
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Call',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.primary,
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _openDialer(BuildContext context, String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Could not open dialer.'),
        backgroundColor: OpeiBrand.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(OpeiBrand.radiusCard),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
}
