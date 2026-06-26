import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opei/core/utils/error_helper.dart';
import 'package:opei/data/repositories/beneficiary_repository.dart';
import 'package:opei/features/beneficiaries/us_bank/us_bank_beneficiaries_controller.dart';
import 'package:opei/l10n/app_localizations.dart';
import 'package:opei/theme.dart';

/// Modal bottom sheet for adding a US bank receiver.
/// Grouped into cards, segmented pickers, and a live progress indicator.
class UsBankAddReceiverSheet extends ConsumerStatefulWidget {
  const UsBankAddReceiverSheet({super.key});

  @override
  ConsumerState<UsBankAddReceiverSheet> createState() =>
      _UsBankAddReceiverSheetState();
}

class _UsBankAddReceiverSheetState
    extends ConsumerState<UsBankAddReceiverSheet> {
  String _tr(String en, String pt) {
    return Localizations.localeOf(context).languageCode == 'pt' ? pt : en;
  }

  final _formKey = GlobalKey<FormState>();

  // Destination options
  String _transferType = 'WIRE';
  String _accountType = 'CHECKING';
  final _accountNumberCtrl = TextEditingController();
  final _routingNumberCtrl = TextEditingController();
  final _bankNameCtrl = TextEditingController();
  final _bankAddressCtrl = TextEditingController();
  final _postCodeCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  String _remittancePurpose =
      BeneficiaryRepository.usBankRemittancePurposes.first.value;

  // Beneficiary options
  String _beneficiaryType = 'INDIVIDUAL';
  final _bAccountNameCtrl = TextEditingController();
  final _bStateCtrl = TextEditingController();
  final _bCityCtrl = TextEditingController();
  final _bAddressCtrl = TextEditingController();
  final _bPostCodeCtrl = TextEditingController();

  late final List<TextEditingController> _allControllers;

  @override
  void initState() {
    super.initState();
    _allControllers = [
      _accountNumberCtrl,
      _routingNumberCtrl,
      _bankNameCtrl,
      _bankAddressCtrl,
      _postCodeCtrl,
      _cityCtrl,
      _stateCtrl,
      _bAccountNameCtrl,
      _bStateCtrl,
      _bCityCtrl,
      _bAddressCtrl,
      _bPostCodeCtrl,
    ];
    for (final c in _allControllers) {
      c.addListener(_onFieldChange);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(usBankBeneficiariesControllerProvider.notifier)
          .clearCreateError();
    });
  }

  void _onFieldChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.removeListener(_onFieldChange);
      c.dispose();
    }
    super.dispose();
  }

  bool get _achWithBusinessConflict =>
      _transferType == 'ACH' && _beneficiaryType == 'BUSINESS';

  // Count how many of the 5 logical sections are complete for the progress ring.
  int get _sectionsComplete {
    int n = 0;
    // 1 – Transfer setup
    if (!_achWithBusinessConflict) n++;
    // 2 – Account numbers
    final acc = _accountNumberCtrl.text.replaceAll(RegExp(r'\D'), '');
    final rt = _routingNumberCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (acc.length >= 4 && acc.length <= 17 && rt.length == 9) n++;
    // 3 – Bank info
    bool ne(String s) => s.trim().length >= 2;
    if (ne(_bankNameCtrl.text) &&
        ne(_bankAddressCtrl.text) &&
        ne(_cityCtrl.text) &&
        ne(_stateCtrl.text) &&
        _postCodeCtrl.text.trim().length >= 3) {
      n++;
    }
    // 4 – Purpose always selected (has default)
    n++;
    // 5 – Beneficiary details
    if (_bAccountNameCtrl.text.trim().length >= 2 &&
        ne(_bAddressCtrl.text) &&
        ne(_bCityCtrl.text) &&
        ne(_bStateCtrl.text) &&
        _bPostCodeCtrl.text.trim().length >= 3) {
      n++;
    }
    return n;
  }

  bool get _isFormReady {
    if (_achWithBusinessConflict) return false;
    final acc = _accountNumberCtrl.text.replaceAll(RegExp(r'\D'), '');
    final rt = _routingNumberCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (acc.length < 4 || acc.length > 17) return false;
    if (rt.length != 9) return false;
    bool ne(String s) => s.trim().length >= 2;
    if (!ne(_bankNameCtrl.text)) return false;
    if (!ne(_bankAddressCtrl.text)) return false;
    if (_postCodeCtrl.text.trim().length < 3) return false;
    if (!ne(_cityCtrl.text)) return false;
    if (!ne(_stateCtrl.text)) return false;
    if (_bAccountNameCtrl.text.trim().length < 2) return false;
    if (!ne(_bStateCtrl.text)) return false;
    if (!ne(_bCityCtrl.text)) return false;
    if (!ne(_bAddressCtrl.text)) return false;
    if (_bPostCodeCtrl.text.trim().length < 3) return false;
    return true;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_achWithBusinessConflict) {
      showError(
        context,
        _tr(
          'ACH transfers are only available for individuals. Switch to Wire for businesses.',
          'Transferencias ACH estao disponiveis apenas para individuos. Use Wire para empresas.',
        ),
      );
      return;
    }

    final ctrl = ref.read(usBankBeneficiariesControllerProvider.notifier);
    final ok = await ctrl.createUsBank(
      transferType: _transferType,
      accountType: _accountType,
      accountNumber: _accountNumberCtrl.text,
      routingNumber: _routingNumberCtrl.text,
      bankName: _bankNameCtrl.text,
      bankAddress: _bankAddressCtrl.text,
      postCode: _postCodeCtrl.text,
      city: _cityCtrl.text,
      state: _stateCtrl.text,
      remittancePurpose: _remittancePurpose,
      beneficiaryType: _beneficiaryType,
      beneficiaryAccountName: _bAccountNameCtrl.text,
      beneficiaryState: _bStateCtrl.text,
      beneficiaryCity: _bCityCtrl.text,
      beneficiaryAddress: _bAddressCtrl.text,
      beneficiaryPostCode: _bPostCodeCtrl.text,
    );
    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
      showSuccess(context, _tr('Receiver added.', 'Destinatario adicionado.'));
    } else {
      final err = ref.read(usBankBeneficiariesControllerProvider).createError;
      if (err != null) showError(context, err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(usBankBeneficiariesControllerProvider);
    final viewInsets = MediaQuery.of(context).viewInsets;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.93;
    final canSubmit = _isFormReady && !state.isCreating;
    final progress = _sectionsComplete / 5.0;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: OpeiBrand.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ────────────────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 34,
              height: 4,
              decoration: BoxDecoration(
                color: OpeiBrand.hairlineStrong,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),

            // ── Header row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("🇺🇸", style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _tr('New receiver', 'Novo destinatario'),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: OpeiBrand.ink,
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          _tr(
                            'United States · Bank Transfer',
                            'Estados Unidos · Transferencia bancaria',
                          ),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: OpeiBrand.inkSecondary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress ring
                  _ProgressRing(value: progress, size: 32),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(height: 0.5, color: OpeiBrand.hairline),

            // ── Scrollable form ───────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + bottomPadding),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── 1 · Transfer setup ─────────────────────────────
                      _CardSection(
                        title: l10n.usBankTransferSetupTitle,
                        children: [
                          _CardRow(
                            label: l10n.usBankTransferTypeLabel,
                            child: _Pill(
                              options: [
                                ('WIRE', _tr('Wire', 'Wire')),
                                ('ACH', 'ACH'),
                              ],
                              selected: _transferType,
                              onSelect: (v) =>
                                  setState(() => _transferType = v),
                            ),
                          ),
                          _CardDivider(),
                          _CardRow(
                            label: l10n.usBankBeneficiaryTypeLabel,
                            child: _Pill(
                              options: [
                                ('INDIVIDUAL', _tr('Individual', 'Individual')),
                                ('BUSINESS', _tr('Business', 'Empresa')),
                              ],
                              selected: _beneficiaryType,
                              onSelect: (v) =>
                                  setState(() => _beneficiaryType = v),
                            ),
                          ),
                          if (_achWithBusinessConflict) ...[
                            _CardDivider(),
                            _InfoBanner(
                              color: OpeiBrand.warning,
                              message: _tr(
                                'ACH is only available for individuals. Switch to Wire to send to a business.',
                                'ACH esta disponivel apenas para individuos. Use Wire para enviar para uma empresa.',
                              ),
                            ),
                          ],
                          _CardDivider(),
                          _CardRow(
                            label: l10n.usBankAccountTypeLabel,
                            child: _Pill(
                              options: [
                                ('CHECKING', _tr('Checking', 'Corrente')),
                                ('SAVINGS', _tr('Savings', 'Poupanca')),
                              ],
                              selected: _accountType,
                              onSelect: (v) => setState(() => _accountType = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── 2 · Account numbers ────────────────────────────
                      _CardSection(
                        title: l10n.usBankAccountNumbersTitle,
                        children: [
                          _FieldRow(
                            label: l10n.accountNumberLabel,
                            helper: _tr('4 – 17 digits', '4 – 17 digitos'),
                            child: TextFormField(
                              controller: _accountNumberCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(17),
                              ],
                              decoration: _dec(hint: '••••••••••'),
                              validator: (v) {
                                final val = (v ?? '').replaceAll(
                                  RegExp(r'\D'),
                                  '',
                                );
                                if (val.length < 4 || val.length > 17) {
                                  return _tr(
                                    'Must be 4 – 17 digits.',
                                    'Deve ter de 4 a 17 digitos.',
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                          _CardDivider(),
                          _FieldRow(
                            label: l10n.usBankRoutingNumberLabel,
                            helper: _tr(
                              'Exactly 9 digits',
                              'Exatamente 9 digitos',
                            ),
                            child: TextFormField(
                              controller: _routingNumberCtrl,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                              ],
                              decoration: _dec(
                                hint: _tr('9 digits', '9 digitos'),
                              ),
                              validator: (v) {
                                final val = (v ?? '').replaceAll(
                                  RegExp(r'\D'),
                                  '',
                                );
                                if (val.length != 9) {
                                  return _tr(
                                    'Must be exactly 9 digits.',
                                    'Deve ter exatamente 9 digitos.',
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── 3 · Bank information ────────────────────────────
                      _CardSection(
                        title: l10n.usBankBankInformationTitle,
                        children: [
                          _FieldRow(
                            label: l10n.usBankBankNameLabel,
                            child: TextFormField(
                              controller: _bankNameCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: _dec(
                                hint: _tr(
                                  'e.g. Chase Bank',
                                  'ex.: Banco Chase',
                                ),
                              ),
                              validator: _min(
                                2,
                                _tr(
                                  'Enter the bank name.',
                                  'Digite o nome do banco.',
                                ),
                              ),
                            ),
                          ),
                          _CardDivider(),
                          _FieldRow(
                            label: l10n.usBankBankAddressLabel,
                            child: TextFormField(
                              controller: _bankAddressCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: _dec(
                                hint: _tr(
                                  'e.g. 270 Park Avenue',
                                  'ex.: 270 Park Avenue',
                                ),
                              ),
                              validator: _min(
                                2,
                                _tr(
                                  'Enter the bank address.',
                                  'Digite o endereco do banco.',
                                ),
                              ),
                            ),
                          ),
                          _CardDivider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _FieldRow(
                                  label: l10n.addressCityLabel,
                                  child: TextFormField(
                                    controller: _cityCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: _dec(
                                      hint: _tr('New York', 'Nova York'),
                                    ),
                                    validator: _min(
                                      2,
                                      _tr('Required.', 'Obrigatorio.'),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: _FieldRow(
                                  label: l10n.addressStateLabel,
                                  child: TextFormField(
                                    controller: _stateCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: _dec(
                                      hint: _tr('New York', 'Nova York'),
                                    ),
                                    validator: _min(
                                      2,
                                      _tr('Required.', 'Obrigatorio.'),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: _FieldRow(
                                  label: l10n.addressZipCodeLabel,
                                  child: TextFormField(
                                    controller: _postCodeCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: _dec(hint: '10017'),
                                    validator: (v) {
                                      if ((v ?? '').trim().length < 3) {
                                        return _tr('Required.', 'Obrigatorio.');
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── 4 · Purpose ─────────────────────────────────────
                      _CardSection(
                        title: l10n.usBankRemittancePurposeTitle,
                        children: [
                          _PurposeDropdown(
                            value: _remittancePurpose,
                            onChanged: (v) =>
                                setState(() => _remittancePurpose = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── 5 · Beneficiary details ─────────────────────────
                      _CardSection(
                        title: l10n.usBankBeneficiaryDetailsTitle,
                        children: [
                          _FieldRow(
                            label: _beneficiaryType == 'BUSINESS'
                                ? l10n.usBankBusinessNameLabel
                                : l10n.usBankFullNameLabel,
                            child: TextFormField(
                              controller: _bAccountNameCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: _dec(
                                hint: _beneficiaryType == 'BUSINESS'
                                    ? _tr(
                                        'e.g. Saul Atta LLC',
                                        'ex.: Saul Atta LLC',
                                      )
                                    : _tr('e.g. John Doe', 'ex.: John Doe'),
                              ),
                              validator: (v) {
                                if ((v ?? '').trim().length < 2) {
                                  return _tr(
                                    'Enter the beneficiary name.',
                                    'Digite o nome do beneficiario.',
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                          _CardDivider(),
                          _FieldRow(
                            label: l10n.addressLabel,
                            child: TextFormField(
                              controller: _bAddressCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: _dec(
                                hint: _tr(
                                  'e.g. 123 Tech Avenue, Suite 400',
                                  'ex.: 123 Tech Avenue, Suite 400',
                                ),
                              ),
                              validator: _min(
                                2,
                                _tr('Enter an address.', 'Digite um endereco.'),
                              ),
                            ),
                          ),
                          _CardDivider(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: _FieldRow(
                                  label: l10n.addressCityLabel,
                                  child: TextFormField(
                                    controller: _bCityCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: _dec(
                                      hint: _tr('Austin', 'Austin'),
                                    ),
                                    validator: _min(
                                      2,
                                      _tr('Required.', 'Obrigatorio.'),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: _FieldRow(
                                  label: l10n.addressStateLabel,
                                  child: TextFormField(
                                    controller: _bStateCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: _dec(
                                      hint: _tr('Texas', 'Texas'),
                                    ),
                                    validator: _min(
                                      2,
                                      _tr('Required.', 'Obrigatorio.'),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: _FieldRow(
                                  label: l10n.addressZipCodeLabel,
                                  child: TextFormField(
                                    controller: _bPostCodeCtrl,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: _dec(hint: '78701'),
                                    validator: (v) {
                                      if ((v ?? '').trim().length < 3) {
                                        return _tr('Required.', 'Obrigatorio.');
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Inline error
                      if (state.createError != null) ...[
                        const SizedBox(height: 14),
                        _InlineError(
                          message: state.createError!,
                          onClose: () => ref
                              .read(
                                usBankBeneficiariesControllerProvider.notifier,
                              )
                              .clearCreateError(),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Save button ──────────────────────────────────────
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: canSubmit ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: OpeiBrand.primary,
                            disabledBackgroundColor: OpeiBrand.surfaceMuted,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: OpeiBrand.inkPlaceholder,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: canSubmit
                                    ? Colors.transparent
                                    : OpeiBrand.hairline,
                                width: 1,
                              ),
                            ),
                          ),
                          child: state.isCreating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _tr('Save receiver', 'Salvar destinatario'),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? Function(String?)? _min(int n, String msg) =>
      (v) => (v ?? '').trim().length < n ? msg : null;

  InputDecoration _dec({required String hint}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: OpeiBrand.inkPlaceholder,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    filled: true,
    fillColor: OpeiBrand.surface,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: OpeiBrand.hairline, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: OpeiBrand.hairline, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: OpeiBrand.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: OpeiBrand.danger, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: OpeiBrand.danger, width: 1.5),
    ),
    errorStyle: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: OpeiBrand.danger,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Layout helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Rounded card that groups related fields with a header label.
class _CardSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _CardSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OpeiBrand.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 0),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: OpeiBrand.inkTertiary,
                letterSpacing: 0.9,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin separator inside a card section.
class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    height: 0.5,
    color: OpeiBrand.hairline,
  );
}

/// Row with a label on top and the child (field or picker) below.
class _FieldRow extends StatelessWidget {
  final String label;
  final String? helper;
  final Widget child;
  const _FieldRow({required this.label, this.helper, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: OpeiBrand.ink,
                letterSpacing: -0.1,
              ),
            ),
            if (helper != null) ...[
              const Spacer(),
              Text(
                helper!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: OpeiBrand.inkTertiary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Row with a label on the left and a compact widget (pill picker) on the right.
class _CardRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _CardRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: OpeiBrand.ink,
            letterSpacing: -0.1,
          ),
        ),
        const Spacer(),
        child,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Picker / selector widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Smooth sliding-indicator segmented control, iOS-style.
class _Pill extends StatelessWidget {
  final List<(String, String)> options;
  final String selected;
  final ValueChanged<String> onSelect;

  static const double segmentWidth = 78;
  static const double height = 32;

  const _Pill({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final n = options.length;
    final activeIndex = options.indexWhere((o) => o.$1 == selected);
    final alignX = n <= 1 ? 0.0 : (activeIndex / (n - 1)) * 2 - 1;

    return SizedBox(
      width: segmentWidth * n + 6,
      height: height,
      child: Stack(
        children: [
          // Track
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2F6),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          // Sliding white indicator tile
          Padding(
            padding: const EdgeInsets.all(3),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              alignment: Alignment(alignX, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / n,
                heightFactor: 1.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: OpeiBrand.surface,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: OpeiBrand.ink.withValues(alpha: 0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                      BoxShadow(
                        color: OpeiBrand.ink.withValues(alpha: 0.04),
                        blurRadius: 1,
                        offset: const Offset(0, 0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Tap targets + animated text colour
          Row(
            children: options.map((opt) {
              final active = opt.$1 == selected;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(opt.$1),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: active ? OpeiBrand.ink : OpeiBrand.inkSecondary,
                        letterSpacing: -0.1,
                      ),
                      child: Text(opt.$2),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PurposeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _PurposeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OpeiBrand.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: OpeiBrand.hairline, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(
            Icons.expand_more_rounded,
            size: 18,
            color: OpeiBrand.inkTertiary,
          ),
          value: value,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: OpeiBrand.ink,
            letterSpacing: -0.2,
          ),
          dropdownColor: OpeiBrand.surface,
          items: [
            for (final item in BeneficiaryRepository.usBankRemittancePurposes)
              DropdownMenuItem<String>(
                value: item.value,
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: OpeiBrand.ink,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Informational banners
// ─────────────────────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final Color color;
  final String message;
  const _InfoBanner({required this.color, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.35,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  const _InlineError({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: OpeiBrand.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: OpeiBrand.danger.withValues(alpha: 0.20),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: OpeiBrand.danger,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: OpeiBrand.danger,
                height: 1.3,
                letterSpacing: -0.1,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Icon(
                Icons.close_rounded,
                size: 15,
                color: OpeiBrand.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Progress ring (header accessory)
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressRing extends StatelessWidget {
  final double value; // 0.0 → 1.0
  final double size;
  const _ProgressRing({required this.value, required this.size});

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    final done = pct == 100;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 3,
            backgroundColor: OpeiBrand.hairlineStrong,
            valueColor: AlwaysStoppedAnimation(
              done ? OpeiBrand.success : OpeiBrand.primary,
            ),
          ),
          if (done)
            const Icon(Icons.check_rounded, size: 16, color: OpeiBrand.success)
          else
            Text(
              '$pct%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: OpeiBrand.ink,
                letterSpacing: -0.3,
              ),
            ),
        ],
      ),
    );
  }
}
