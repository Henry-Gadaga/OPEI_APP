// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Opei - Ferramentas Financeiras em USD';

  @override
  String get languageChooseTitle => 'Escolha seu idioma';

  @override
  String get languageChooseSubtitle =>
      'Escolha o idioma de sua preferencia.\nVoce pode alterar depois no Perfil.';

  @override
  String get languageEnglishTitle => 'English';

  @override
  String get languageEnglishSubtitle => 'Ingles';

  @override
  String get languagePortugueseTitle => 'Portugues';

  @override
  String get languagePortugueseSubtitle => 'Portugues';

  @override
  String get continueCta => 'Continuar';

  @override
  String get welcomeCreateAccount => 'Criar conta';

  @override
  String get welcomeAlreadyHaveAccount => 'Ja tem uma conta?';

  @override
  String get welcomeSignIn => 'Entrar';

  @override
  String get welcomeLegalPrefix => 'Ao continuar, voce concorda com nossos ';

  @override
  String get welcomeLegalTerms => 'Termos';

  @override
  String get welcomeLegalAnd => ' e ';

  @override
  String get welcomeLegalPrivacy => 'Politica de Privacidade';

  @override
  String get loginHeaderTitle => 'Entrar';

  @override
  String get loginHeaderSubtitle => 'Acesse sua conta Opei com seguranca.';

  @override
  String get loginWelcomeBack => 'Bem-vindo de volta';

  @override
  String get loginWelcomeSubtitle => 'Entre para continuar na sua conta';

  @override
  String get emailAddressLabel => 'Endereco de email';

  @override
  String get emailAddressHint => 'nome@exemplo.com';

  @override
  String get emailRequiredError => 'Email e obrigatorio';

  @override
  String get emailInvalidError => 'Digite um email valido';

  @override
  String get pinLabel => 'PIN de 6 digitos';

  @override
  String get forgotPinCta => 'Esqueceu o PIN?';

  @override
  String get forgotPinTitle => 'Esqueceu o PIN?';

  @override
  String get forgotPinSubtitle => 'Redefina em duas etapas rapidas.';

  @override
  String get forgotPinEmailCodeTitle => 'Vamos enviar um codigo';

  @override
  String get forgotPinEmailCodeSubtitle =>
      'Digite o email da sua conta e enviaremos um codigo de 6 digitos.';

  @override
  String get forgotPinSendCodeCta => 'Enviar codigo';

  @override
  String get forgotPinRememberedCta => 'Lembrou?';

  @override
  String get pinHint => '••••••';

  @override
  String get pinRequiredError => 'PIN e obrigatorio';

  @override
  String get pinInvalidError => 'PIN deve ter exatamente 6 digitos';

  @override
  String get loginSignInCta => 'Entrar';

  @override
  String get loginUseFaceId => 'Usar Face ID';

  @override
  String get loginUseFingerprint => 'Usar impressao digital';

  @override
  String get orSeparator => 'ou';

  @override
  String get createNewAccountCta => 'Criar nova conta';

  @override
  String get signupSubtitleEmail => 'Vamos comecar com seu email.';

  @override
  String get signupSubtitlePhone => 'Agora seu numero de telefone.';

  @override
  String get signupSubtitlePin => 'Escolha um PIN de 6 digitos.';

  @override
  String get signupTitle => 'Criar conta';

  @override
  String get phoneNumberLabel => 'Numero de telefone';

  @override
  String get signupPinHelper =>
      'Guarde bem este PIN - ele autoriza todos os seus pagamentos.';

  @override
  String get signupCreateAccountCta => 'Criar conta';

  @override
  String get alreadyHaveAccount => 'Ja tem uma conta?';

  @override
  String get resetPinTitle => 'Redefinir PIN';

  @override
  String get resetPinSubtitle => 'Digite o codigo e escolha um novo PIN.';

  @override
  String get resetPinCodeAndNewPinTitle => 'Codigo e novo PIN';

  @override
  String get resetPinCodePrefix => 'Digite o codigo de 6 digitos enviado para ';

  @override
  String get resetPinCodeSuffix => ' e escolha seu novo PIN.';

  @override
  String get resetPinVerificationCodeLabel => 'Codigo de verificacao';

  @override
  String get resetPinVerificationCodeHint => 'codigo de 6 digitos';

  @override
  String get resetPinNewPinLabel => 'Novo PIN de 6 digitos';

  @override
  String get resetPinConfirmPinLabel => 'Confirmar novo PIN';

  @override
  String get resetPinHelperText =>
      'Voce usara este PIN para entrar e autorizar pagamentos.';

  @override
  String get resetPinCta => 'Redefinir PIN';

  @override
  String get resetPinDidntGetCode => 'Nao recebeu o codigo?';

  @override
  String get resetPinRequestNewCta => 'Solicitar novo';

  @override
  String get resetPinUpdatedTitle => 'PIN atualizado';

  @override
  String get resetPinUpdatedSubtitle =>
      'Seu novo PIN de 6 digitos foi definido. Entre para continuar.';

  @override
  String get resetPinGoToSignInCta => 'Ir para entrar';

  @override
  String get verifyEmailTitle => 'Verificar email';

  @override
  String get verifyEmailSubtitle =>
      'Etapa 2 de 4  •  Digite o codigo de 6 digitos enviado.';

  @override
  String get verifyEmailInboxTitle => 'Verifique sua caixa de entrada';

  @override
  String get verifyEmailSentToPrefix => 'Enviamos um codigo de 6 digitos para ';

  @override
  String get verifyEmailWrongEmailCta => 'Email errado? Comecar de novo';

  @override
  String get verifyEmailSigningOut => 'Saindo...';

  @override
  String get verifyEmailVerifying => 'Verificando...';

  @override
  String get verifyEmailDidntGetCode => 'Nao recebeu o codigo? ';

  @override
  String get verifyEmailResendCta => 'Reenviar';

  @override
  String verifyEmailResendIn(Object timerText) {
    return 'Reenviar codigo em $timerText';
  }

  @override
  String get verifyEmailCodeSent => 'Codigo de verificacao enviado';

  @override
  String get verifyEmailNotFoundError =>
      'Email nao encontrado. Cadastre-se novamente.';

  @override
  String get topupSheetTitle => 'Recarregar cartao';

  @override
  String get topupAmountLabel => 'VALOR DA RECARGA';

  @override
  String get topupPreviewCta => 'Revisar recarga';

  @override
  String get loadingPreview => 'Carregando previsao...';

  @override
  String get paymentBreakdown => 'RESUMO DO PAGAMENTO';

  @override
  String get topupAmountRow => 'Valor da recarga';

  @override
  String get feeRow => 'Taxa';

  @override
  String get totalToPayRow => 'Total a pagar';

  @override
  String get afterThisPayment => 'DEPOIS DESTE PAGAMENTO';

  @override
  String get walletBalanceRow => 'Saldo da carteira';

  @override
  String get confirmTopupCta => 'Confirmar recarga';

  @override
  String get editAmountCta => 'Editar valor';

  @override
  String get youAreToppingUpLabel => 'VOCE ESTA RECARREGANDO';

  @override
  String get youAreWithdrawingLabel => 'VOCE ESTA SACANDO';

  @override
  String get topupCompleteTitle => 'Recarga concluida';

  @override
  String get topupCompleteSubtitle =>
      'O saldo do seu cartao sera atualizado em instantes.';

  @override
  String get referenceLabel => 'Referencia';

  @override
  String get amountLabel => 'Valor';

  @override
  String get totalPaidLabel => 'Total pago';

  @override
  String get doneCta => 'Concluir';

  @override
  String get topupFailedTitle => 'Falha na recarga';

  @override
  String get topupFailedSubtitle =>
      'Nao foi possivel concluir a recarga. Tente novamente.';

  @override
  String get tryAgainCta => 'Tentar novamente';

  @override
  String get closeCta => 'Fechar';

  @override
  String get withdrawSheetTitle => 'Sacar do cartao';

  @override
  String get withdrawAmountLabel => 'VALOR DO SAQUE';

  @override
  String get withdrawPreviewCta => 'Revisar saque';

  @override
  String get withdrawAmountRow => 'Valor do saque';

  @override
  String get youWillReceiveRow => 'Voce recebera';

  @override
  String get afterThisWithdrawal => 'DEPOIS DESTE SAQUE';

  @override
  String get cardBalanceNowRow => 'Saldo atual do cartao';

  @override
  String get cardBalanceAfterRow => 'Saldo do cartao apos';

  @override
  String get confirmWithdrawalCta => 'Confirmar saque';

  @override
  String get withdrawalCompleteTitle => 'Saque concluido';

  @override
  String get withdrawalCompleteSubtitle =>
      'Os fundos chegarao na sua carteira em instantes.';

  @override
  String get statusLabel => 'Status';

  @override
  String get withdrawalFailedTitle => 'Falha no saque';

  @override
  String get withdrawalFailedSubtitle =>
      'Nao foi possivel concluir o saque. Tente novamente.';

  @override
  String get pendingStatus => 'Pendente';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileSectionAccountInfo => 'Informacoes da Conta';

  @override
  String get profileSectionPersonalInfo => 'Informacoes Pessoais';

  @override
  String get profileSectionAddress => 'Endereco';

  @override
  String get profileSectionVerification => 'Status de Verificacao';

  @override
  String get profileSectionRewards => 'Recompensas';

  @override
  String get profileSectionPreferences => 'Preferencias';

  @override
  String get profileSectionLegal => 'Legal';

  @override
  String get profileSectionActions => 'Acoes da Conta';

  @override
  String get profileSectionSecurity => 'Configuracoes de Seguranca';

  @override
  String get profileEmailLabel => 'Email';

  @override
  String get profilePhoneLabel => 'Telefone';

  @override
  String get profileVerificationStageLabel => 'Etapa de verificacao';

  @override
  String get profileFullNameLabel => 'Nome completo';

  @override
  String get profileDobLabel => 'Data de nascimento';

  @override
  String get profileGenderLabel => 'Genero';

  @override
  String get profileNationalityLabel => 'Nacionalidade';

  @override
  String get profileIdTypeLabel => 'Tipo de documento';

  @override
  String get profileIdNumberLabel => 'Numero do documento';

  @override
  String get profileCountryLabel => 'Pais';

  @override
  String get profileStateLabel => 'Estado';

  @override
  String get profileCityLabel => 'Cidade';

  @override
  String get profileAddressLabel => 'Endereco';

  @override
  String get profileZipCodeLabel => 'CEP';

  @override
  String get profileUpdateAddressCta => 'Atualizar endereco';

  @override
  String get profileAddAddressCta => 'Adicionar endereco';

  @override
  String get profileNoAddressSubtitle => 'Nenhum endereco cadastrado';

  @override
  String get profileIdentityVerifiedTitle => 'Identidade verificada';

  @override
  String get profileIdentityVerifiedSubtitle =>
      'Sua identidade foi verificada com sucesso';

  @override
  String get profileReferralsLabel => 'Indicacoes';

  @override
  String get profileReferralsSubtitle =>
      'Compartilhe seu link e acompanhe ganhos';

  @override
  String get profileLanguageLabel => 'Idioma';

  @override
  String get profileTermsLabel => 'Termos e Condicoes';

  @override
  String get profilePrivacyLabel => 'Politica de Privacidade';

  @override
  String get profileLogoutLabel => 'Sair';

  @override
  String get profileUnableLoadTitle => 'Nao foi possivel carregar o perfil';

  @override
  String get retryCta => 'Tentar novamente';

  @override
  String get profileKycPromptTitle => 'Complete seu perfil';

  @override
  String get profileKycPromptSubtitle =>
      'Verifique sua identidade para liberar todos os recursos';

  @override
  String get naValue => 'N/A';

  @override
  String get languageUpdatedPortuguese => 'Idioma atualizado para Portugues.';

  @override
  String get languageUpdatedEnglish => 'Idioma atualizado para Ingles.';

  @override
  String get languageUpdateFailed =>
      'Nao foi possivel atualizar o idioma. Tente novamente.';

  @override
  String get selectLanguageTitle => 'Selecionar idioma';

  @override
  String get selectLanguageSubtitle =>
      'Escolha sua preferencia de idioma no app.';

  @override
  String get languageUseEnglishSubtitle => 'Usar Ingles em todo o aplicativo';

  @override
  String get languageUsePortugueseSubtitle =>
      'Usar Portugues em todo o aplicativo';

  @override
  String get logoutTitle => 'Sair';

  @override
  String get logoutSubtitle => 'Voce precisara entrar novamente na proxima vez';

  @override
  String get cancelCta => 'Cancelar';

  @override
  String get quickAuthPinLabel => 'Autenticacao por PIN';

  @override
  String get loadingText => 'Carregando...';

  @override
  String get enabledText => 'Ativado';

  @override
  String get disabledText => 'Desativado';

  @override
  String get faceIdPrompt => 'Configure Face ID para acesso rapido';

  @override
  String get fingerprintPrompt =>
      'Configure impressao digital para acesso rapido';

  @override
  String get faceIdDisabled => 'Entrada com Face ID desativada.';

  @override
  String get fingerprintDisabled => 'Entrada com impressao digital desativada.';

  @override
  String get biometricUpdateFailed =>
      'Nao foi possivel atualizar a biometria. Tente novamente.';

  @override
  String get faceIdSignInLabel => 'Entrada com Face ID';

  @override
  String get fingerprintSignInLabel => 'Entrada com impressao digital';

  @override
  String get biometricEnabledSubtitle => 'Ativado - entre com um olhar';

  @override
  String get faceIdDisabledSubtitle => 'Use Face ID em vez de digitar seu PIN';

  @override
  String get fingerprintDisabledSubtitle =>
      'Use sua impressao digital em vez de digitar seu PIN';

  @override
  String get dashboardGreetingMorning => 'Bom dia';

  @override
  String get dashboardGreetingAfternoon => 'Boa tarde';

  @override
  String get dashboardGreetingEvening => 'Boa noite';

  @override
  String get dashboardNavHome => 'Inicio';

  @override
  String get dashboardNavCards => 'Cartoes';

  @override
  String get dashboardNavActivity => 'Atividade';

  @override
  String get dashboardNavAgent => 'Agente';

  @override
  String get dashboardNavProfile => 'Perfil';

  @override
  String get dashboardRecentActivity => 'Atividade recente';

  @override
  String get dashboardSeeAll => 'Ver tudo';

  @override
  String get dashboardNoTransactionsTitle => 'Sem transacoes ainda';

  @override
  String get dashboardNoTransactionsSubtitle =>
      'Suas movimentacoes aparecerao aqui.';

  @override
  String get dashboardActivityLoadFailedTitle =>
      'Nao foi possivel carregar atividade';

  @override
  String get dashboardUsdWallet => 'Carteira USD';

  @override
  String dashboardReservedHeld(Object reserved) {
    return '$reserved retido';
  }

  @override
  String get dashboardActionAdd => 'Adicionar';

  @override
  String get dashboardActionSend => 'Enviar';

  @override
  String get dashboardActionWithdraw => 'Sacar';

  @override
  String get dashboardActionCards => 'Cartoes';

  @override
  String get transactionsNoActivityTitle => 'Sem atividade ainda';

  @override
  String get transactionsNoActivitySubtitle =>
      'Voce ainda nao fez movimentacoes.\nA nova atividade aparecera aqui instantaneamente.';

  @override
  String get transactionsAllCaughtUp => 'Tudo em dia';

  @override
  String get transactionsSingle => 'transacao';

  @override
  String get transactionsPlural => 'transacoes';

  @override
  String transactionsCountLabel(Object count, Object unit) {
    return '$count $unit';
  }

  @override
  String get transactionsHeaderSubtitle =>
      'Todas as movimentacoes da sua conta em um so lugar.';

  @override
  String transactionsHeaderTimeline(Object countLabel) {
    return '$countLabel · tudo em uma linha do tempo';
  }

  @override
  String get transactionsMoneyIn => 'Entradas';

  @override
  String get transactionsMoneyOut => 'Saidas';

  @override
  String get depositAddMoneyTitle => 'Adicionar dinheiro';

  @override
  String get depositAddMoneySubtitle => 'Escolha como deseja adicionar fundos';

  @override
  String get depositExpressP2PTitle => 'Express P2P';

  @override
  String get depositExpressP2PSubtitle =>
      'Pague em moeda local e receba USD rapido';

  @override
  String get depositP2PExchangeTitle => 'Troca P2P';

  @override
  String get depositP2PExchangeSubtitle =>
      'Transferencia bancaria, pagamentos moveis e mais';

  @override
  String get depositStablecoinTitle => 'Stablecoin USD';

  @override
  String get depositStablecoinSubtitle =>
      'Receba USDT ou USDC na sua carteira Opei';

  @override
  String get depositSelectMethodTitle => 'Selecionar metodo';

  @override
  String get depositChooseMethodSubtitle =>
      'Escolha o metodo que deseja usar para deposito';

  @override
  String get depositSelectNetworkTitle => 'Selecionar rede';

  @override
  String depositChooseNetworkSubtitle(Object currency) {
    return 'Escolha a rede para seu deposito de $currency';
  }

  @override
  String get depositFetchAddressFailed =>
      'Falha ao buscar endereco de deposito';

  @override
  String get depositAddressTitle => 'Endereco de deposito';

  @override
  String get depositScanTitle => 'Escanear para depositar';

  @override
  String depositSendOnNetwork(Object currency, Object network) {
    return 'Envie $currency na rede $network';
  }

  @override
  String get depositQrUnavailable => 'QR indisponivel';

  @override
  String get depositAddressCopied => 'Endereco copiado';

  @override
  String get depositCopyCta => 'Copiar';

  @override
  String get depositImportantTitle => 'Importante';

  @override
  String depositInfoOnlySend(Object currency, Object network) {
    return 'Envie somente $currency na rede $network';
  }

  @override
  String get depositInfoWrongAssetWarning =>
      'Outros ativos ou redes causarao perda permanente';

  @override
  String get depositInfoBalanceUpdates =>
      'O saldo atualiza apos confirmacoes da rede';
}
