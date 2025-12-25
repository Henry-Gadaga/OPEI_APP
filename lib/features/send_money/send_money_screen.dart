import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tt1/core/money/money.dart';
import 'package:tt1/features/send_money/send_money_controller.dart';
import 'package:tt1/features/send_money/send_money_state.dart';
import 'package:tt1/theme.dart';
import 'package:tt1/widgets/success_hero.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _amountFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Reset state when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sendMoneyControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sendMoneyControllerProvider);

    return Scaffold(
      backgroundColor: OpeiColors.pureWhite,
      appBar: AppBar(
        backgroundColor: OpeiColors.pureWhite,
        elevation: 0,
        leading: state.currentStep == SendMoneyStep.result 
            ? null 
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: OpeiColors.pureBlack),
                onPressed: () {
                  if (state.currentStep == SendMoneyStep.emailLookup) {
                    context.pop();
                  } else {
                    ref.read(sendMoneyControllerProvider.notifier).goBack();
                  }
                },
              ),
        title: Text(
          'Send Money',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildStepContent(context, state),
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, SendMoneyState state) {
    switch (state.currentStep) {
      case SendMoneyStep.emailLookup:
        return _buildEmailLookupStep(context, state);
      case SendMoneyStep.amountEntry:
        return _buildAmountEntryStep(context, state);
      case SendMoneyStep.preview:
        return _buildPreviewStep(context, state);
      case SendMoneyStep.result:
        return _ResultStep(state: state);
    }
  }

  Widget _buildEmailLookupStep(BuildContext context, SendMoneyState state) {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Text(
            'Recipient email',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            enabled: !state.isLoading,
            decoration: InputDecoration(
              hintText: 'email@example.com',
              prefixIcon: const Icon(Icons.email_outlined, size: 18),
              prefixIconConstraints: const BoxConstraints(minWidth: 36),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              errorText: state.errorMessage?.isNotEmpty == true ? state.errorMessage : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLookup(),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: state.isLoading ? null : _handleLookup,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: state.isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(OpeiColors.pureWhite),
                    ),
                  )
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountEntryStep(BuildContext context, SendMoneyState state) {
    return Form(
      key: _amountFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: OpeiColors.grey100,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: OpeiColors.pureBlack,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      state.lookupResult!.bestDisplayName[0].toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: OpeiColors.pureWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sending to',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: OpeiColors.grey600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.lookupResult!.bestDisplayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Amount',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            enabled: !state.isLoading,
            decoration: InputDecoration(
              hintText: '0.00',
              prefixIcon: const Icon(Icons.attach_money, size: 18),
              prefixIconConstraints: const BoxConstraints(minWidth: 36),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              errorText: state.errorMessage?.isNotEmpty == true ? state.errorMessage : null,
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter an amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleAmountContinue(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: state.isLoading ? null : _handleAmountContinue,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: state.isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(OpeiColors.pureWhite),
                    ),
                  )
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStep(BuildContext context, SendMoneyState state) {
    final preview = state.previewResult;
    if (preview == null) {
      return const Center(child: Text('No preview available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Text(
          'Review transfer',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: OpeiColors.grey100,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            children: [
              _buildDetailRow(context, 'Sending to', state.lookupResult!.bestDisplayName, isLabel: true),
              const SizedBox(height: 18),
              _buildDetailRow(
                context,
                'Transfer amount',
                preview.transferAmountMoney.format(includeCurrencySymbol: true),
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                context,
                'Fee',
                preview.estimatedFeeMoney.format(includeCurrencySymbol: true),
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                context,
                'Total debit',
                preview.totalDebitMoney.format(includeCurrencySymbol: true),
                isTotal: true,
              ),
              const SizedBox(height: 10),
              _buildDetailRow(
                context,
                'Balance after',
                preview.senderBalanceAfterMoney.format(includeCurrencySymbol: true),
              ),
              const SizedBox(height: 16),
              Divider(color: OpeiColors.grey300.withValues(alpha: 0.6), height: 1),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                'Recipient receives',
                preview.receiverCreditAmountMoney.format(includeCurrencySymbol: true),
                isHighlight: true,
              ),
            ],
          ),
        ),
        if (state.errorMessage?.isNotEmpty == true) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: OpeiColors.errorRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: OpeiColors.errorRed, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: OpeiColors.errorRed,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
        ElevatedButton(
          onPressed: state.isLoading ? null : _handleConfirmTransfer,
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          child: state.isLoading
              ? const CupertinoActivityIndicator(radius: 11, color: OpeiColors.pureWhite)
              : const Text('Send now'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isTotal = false, bool isLabel = false, bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isLabel || isTotal || isHighlight ? OpeiColors.pureBlack : OpeiColors.grey600,
                fontWeight: isLabel || isTotal || isHighlight ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isTotal || isHighlight ? FontWeight.w700 : FontWeight.w600,
                fontSize: isTotal ? 18 : null,
                color: isHighlight ? OpeiColors.successGreen : null,
              ),
        ),
      ],
    );
  }

  Future<void> _handleLookup() async {
    if (_emailFormKey.currentState?.validate() ?? false) {
      await ref.read(sendMoneyControllerProvider.notifier).lookupWallet(_emailController.text.trim().toLowerCase());
    }
  }

  Future<void> _handleAmountContinue() async {
    if (_amountFormKey.currentState?.validate() ?? false) {
      final money = Money.parse(_amountController.text.trim());
      await ref.read(sendMoneyControllerProvider.notifier).previewTransfer(money);
    }
  }

  Future<void> _handleConfirmTransfer() async {
    await ref.read(sendMoneyControllerProvider.notifier).confirmTransfer();
  }
}

class _ResultStep extends ConsumerWidget {
  final SendMoneyState state;
  
  const _ResultStep({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuccess = state.transferSuccess;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 36),
          if (isSuccess) ...[
            const SuccessHero(iconHeight: 64, gap: 2),
            const SizedBox(height: 16),
            Text(
              'Transfer complete',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            if (state.transferResult != null) ...[
              Text(
                'You sent ${state.transferResult!.amountMoney.format(includeCurrencySymbol: true)} to ${state.lookupResult!.bestDisplayName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: OpeiColors.grey600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OpeiColors.grey100,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      'Amount sent',
                      state.transferResult!.amountMoney.format(includeCurrencySymbol: true),
                      isHighlight: true,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Your new balance',
                      state.transferResult!.fromBalanceMoney.format(includeCurrencySymbol: true),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: OpeiColors.errorRed.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_rounded,
                size: 46,
                color: OpeiColors.errorRed,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Transfer failed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? 'The transfer could not be completed. Please try again.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: OpeiColors.grey600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (isSuccess) {
                  context.pop();
                } else {
                  ref.read(sendMoneyControllerProvider.notifier).reset();
                }
              },
              child: Text(isSuccess ? 'Done' : 'Try Again'),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isHighlight = false, bool isSmall = false}) {
    if (isSmall) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: OpeiColors.grey600,
                  fontSize: 11,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isHighlight ? OpeiColors.pureBlack : OpeiColors.grey600,
                fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                  fontSize: isHighlight ? 18 : null,
                  color: isHighlight ? OpeiColors.pureBlack : null,
                ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

