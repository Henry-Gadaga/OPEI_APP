import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:opei/core/network/api_error.dart';
import 'package:opei/core/providers/providers.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/models/p2p_payment_method_type.dart';
import 'package:opei/features/express_p2p/express_p2p_preview_screen.dart';
import 'package:opei/features/express_p2p/express_ui.dart';
import 'package:opei/theme.dart';

/// 3-page wizard: currency → payment method → USD amount.
class ExpressP2PSetupScreen extends ConsumerStatefulWidget {
  const ExpressP2PSetupScreen({super.key});

  @override
  ConsumerState<ExpressP2PSetupScreen> createState() =>
      _ExpressP2PSetupScreenState();
}

class _ExpressP2PSetupScreenState extends ConsumerState<ExpressP2PSetupScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _amountController = TextEditingController();
  int _page = 0;

  String? _currency;
  List<P2PPaymentMethodType> _methods = const [];
  P2PPaymentMethodType? _selectedMethod;
  bool _loadingMethods = false;
  String? _methodsError;

  static const _titles = ['Select currency', 'Payment method', 'Enter amount'];

  @override
  void dispose() {
    _pageController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
    setState(() => _page = page);
  }

  void _handleBack() {
    if (_page > 0) {
      _goToPage(_page - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _selectCurrency(String code) async {
    if (_currency == code) return;
    setState(() {
      _currency = code;
      _methods = const [];
      _selectedMethod = null;
      _methodsError = null;
      _loadingMethods = true;
    });
    try {
      final methods = await ref
          .read(expressOrderRepositoryProvider)
          .fetchPaymentMethodTypes(currency: code);
      if (!mounted || _currency != code) return;
      setState(() {
        _methods = methods;
        _loadingMethods = false;
      });
    } on ApiError catch (e) {
      if (!mounted || _currency != code) return;
      setState(() {
        _methodsError = e.message;
        _loadingMethods = false;
      });
    } catch (e) {
      if (!mounted || _currency != code) return;
      setState(() {
        _methodsError = ErrorHelper.getErrorMessage(e);
        _loadingMethods = false;
      });
    }
  }

  int? get _amountCents {
    final raw = _amountController.text.trim().replaceAll(',', '');
    if (raw.isEmpty) return null;
    final v = double.tryParse(raw);
    if (v == null || v <= 0) return null;
    return (v * 100).round();
  }

  bool get _pageNextEnabled {
    switch (_page) {
      case 0:
        return _currency != null;
      case 1:
        return _selectedMethod != null;
      case 2:
        return (_amountCents ?? 0) > 0;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_page < 2) {
      _goToPage(_page + 1);
    } else {
      _submit();
    }
  }

  void _submit() {
    final method = _selectedMethod;
    final currency = _currency;
    final cents = _amountCents;
    if (method == null || currency == null || cents == null || cents <= 0) {
      return;
    }
    context.push(
      '/express-p2p/preview',
      extra: ExpressPreviewArgs(
        paymentMethodTypeId: method.id,
        providerName: method.providerName,
        methodType: method.methodType,
        quoteCurrency: currency,
        amountUsdCents: cents,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _handleBack,
          ),
          title: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              _titles[_page],
              key: ValueKey(_page),
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: OpeiBrand.ink,
                letterSpacing: -0.3,
              ),
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: _StepBar(page: _page, total: 3),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _Page1Currency(
                      selected: _currency,
                      onSelect: (code) {
                        _selectCurrency(code);
                      },
                    ),
                    _Page2Method(
                      currency: _currency,
                      methods: _methods,
                      loading: _loadingMethods,
                      error: _methodsError,
                      selected: _selectedMethod,
                      onSelect: (m) => setState(() => _selectedMethod = m),
                      onRetry: () =>
                          _currency != null ? _selectCurrency(_currency!) : null,
                    ),
                    _Page3Amount(
                      currency: _currency,
                      method: _selectedMethod,
                      controller: _amountController,
                      onChanged: (_) => setState(() {}),
                      onAddAmount: (value) {
                        final current = _amountCents ?? 0;
                        final nextCents = current + value * 100;
                        final next = (nextCents / 100).toStringAsFixed(2);
                        _amountController.text = next;
                        _amountController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: _amountController.text.length),
                        );
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              _BottomBar(
                page: _page,
                enabled: _pageNextEnabled,
                onTap: _handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step progress bar ────────────────────────────────────────────────────────

class _StepBar extends StatelessWidget {
  final int page;
  final int total;
  const _StepBar({required this.page, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        children: List.generate(total, (i) {
          final done = i <= page;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
              child: AnimatedContainer(
                duration: OpeiBrand.motionFast,
                curve: OpeiBrand.motionCurve,
                height: 3,
                decoration: BoxDecoration(
                  color: done ? OpeiBrand.primary : OpeiBrand.hairline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Page 1 — Currency ────────────────────────────────────────────────────────

class _Page1Currency extends StatelessWidget {
  final String? selected;
  final void Function(String) onSelect;
  const _Page1Currency({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        const _PageHint('Choose the local currency you will be paying in.'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kExpressCurrencies.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.34,
          ),
          itemBuilder: (_, i) {
            final c = kExpressCurrencies[i];
            final sel = selected == c.code;
            return Material(
              color: sel ? OpeiBrand.primaryTint : OpeiBrand.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => onSelect(c.code),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: OpeiBrand.motionFast,
                  curve: OpeiBrand.motionCurve,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? OpeiBrand.primary
                          : OpeiBrand.hairlineStrong,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        c.code,
                        style: TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: sel ? OpeiBrand.primary : OpeiBrand.ink,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: kPrimaryFontFamily,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: OpeiBrand.inkTertiary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Page 2 — Payment method ──────────────────────────────────────────────────

class _Page2Method extends StatelessWidget {
  final String? currency;
  final List<P2PPaymentMethodType> methods;
  final bool loading;
  final String? error;
  final P2PPaymentMethodType? selected;
  final void Function(P2PPaymentMethodType) onSelect;
  final VoidCallback onRetry;

  const _Page2Method({
    required this.currency,
    required this.methods,
    required this.loading,
    required this.error,
    required this.selected,
    required this.onSelect,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        _PageHint(
          currency != null
              ? 'Pick how you will send $currency to the agent.'
              : 'Loading methods…',
        ),
        const SizedBox(height: 16),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: OpeiBrand.primary,
              ),
            ),
          )
        else if (error != null)
          _InlineError(message: error!, onRetry: onRetry)
        else if (methods.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OpeiBrand.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'No payment methods available for this currency yet.',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 13,
                color: OpeiBrand.inkSecondary,
                height: 1.4,
              ),
            ),
          )
        else
          ...methods.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MethodTile(
                method: m,
                selected: selected?.id == m.id,
                onTap: () => onSelect(m),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Page 3 — Amount ──────────────────────────────────────────────────────────

class _Page3Amount extends StatelessWidget {
  final String? currency;
  final P2PPaymentMethodType? method;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final void Function(int) onAddAmount;

  const _Page3Amount({
    required this.currency,
    required this.method,
    required this.controller,
    required this.onChanged,
    required this.onAddAmount,
  });

  @override
  Widget build(BuildContext context) {
    final methodLabel = method == null
        ? ''
        : (method!.providerName.isNotEmpty
            ? method!.providerName
            : expressMethodTypeLabel(method!.methodType));
    return Column(
      children: [
        const SizedBox(height: 20),
        // context chip
        if (currency != null && method != null)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: OpeiBrand.primaryTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 13, color: OpeiBrand.primary),
                  const SizedBox(width: 6),
                  Text(
                    '$currency · $methodLabel',
                    style: const TextStyle(
                      fontFamily: kPrimaryFontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: OpeiBrand.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const Expanded(child: SizedBox()),
        // label
        const Text(
          'AMOUNT TO RECEIVE',
          style: TextStyle(
            fontFamily: kPrimaryFontFamily,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: OpeiBrand.inkTertiary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 20),
        // big floating input — no box, no border
        _AmountField(controller: controller, onChanged: onChanged),
        const SizedBox(height: 28),
        // quick chips
        _AmountQuickChips(onAddAmount: onAddAmount),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}

// ── Shared UI helpers ────────────────────────────────────────────────────────

class _PageHint extends StatelessWidget {
  final String text;
  const _PageHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: kPrimaryFontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: OpeiBrand.inkSecondary,
        height: 1.4,
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final P2PPaymentMethodType method;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? OpeiBrand.primaryTint : OpeiBrand.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: OpeiBrand.motionFast,
          curve: OpeiBrand.motionCurve,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? OpeiBrand.primary : OpeiBrand.hairline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: selected
                      ? OpeiBrand.primary.withValues(alpha: 0.12)
                      : OpeiBrand.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: selected
                      ? OpeiBrand.primary
                      : OpeiBrand.inkSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      method.providerName.isEmpty
                          ? expressMethodTypeLabel(method.methodType)
                          : method.providerName,
                      style: TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected ? OpeiBrand.primary : OpeiBrand.ink,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      expressMethodTypeLabel(method.methodType),
                      style: const TextStyle(
                        fontFamily: kPrimaryFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: OpeiBrand.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: selected ? OpeiBrand.primary : OpeiBrand.inkTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountQuickChips extends StatelessWidget {
  final void Function(int amount) onAddAmount;
  const _AmountQuickChips({required this.onAddAmount});

  @override
  Widget build(BuildContext context) {
    final chips = <int>[5, 10, 25, 50];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: chips.asMap().entries.map((e) {
        return Padding(
          padding: EdgeInsets.only(left: e.key == 0 ? 0 : 8),
          child: GestureDetector(
            onTap: () => onAddAmount(e.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: OpeiBrand.primaryTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '+\$${e.value}',
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: OpeiBrand.primary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AmountField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _AmountField({required this.controller, required this.onChanged});

  @override
  State<_AmountField> createState() => _AmountFieldState();
}

class _AmountFieldState extends State<_AmountField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // auto-focus when this page appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Text(
            r'$',
            style: TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: OpeiBrand.inkSecondary,
              height: 1,
            ),
          ),
          const SizedBox(width: 2),
          IntrinsicWidth(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              focusNode: _focus,
              textAlign: TextAlign.center,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              style: const TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 58,
                fontWeight: FontWeight.w800,
                color: OpeiBrand.ink,
                letterSpacing: -2,
                height: 1,
              ),
              decoration: const InputDecoration(
                hintText: '0',
                // kill every possible border the theme might inject
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 58,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFDDE8FF),
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              'USD',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: OpeiBrand.inkTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom action bar ────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int page;
  final bool enabled;
  final VoidCallback onTap;

  const _BottomBar({
    required this.page,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final isLast = page == 2;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + bottomPad),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: OpeiBrand.primary,
            disabledBackgroundColor: OpeiBrand.surfaceMuted,
            disabledForegroundColor: OpeiBrand.inkTertiary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLast ? 'Review deposit' : 'Continue',
                style: const TextStyle(
                  fontFamily: kPrimaryFontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              if (!isLast) ...[
                const SizedBox(width: 5),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Inline error ─────────────────────────────────────────────────────────────

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontFamily: kPrimaryFontFamily,
              fontSize: 12.8,
              color: OpeiBrand.inkSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onRetry,
            child: const Text(
              'Try again',
              style: TextStyle(
                fontFamily: kPrimaryFontFamily,
                fontSize: 12.8,
                fontWeight: FontWeight.w700,
                color: OpeiBrand.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
