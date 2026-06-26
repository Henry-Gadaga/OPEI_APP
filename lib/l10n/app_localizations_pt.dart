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

  @override
  String get sendMoneyTitle => 'Enviar dinheiro';

  @override
  String get sendMoneyRecipientEmailLabel => 'Email do destinatario';

  @override
  String get sendMoneyEnterEmailError => 'Digite um email';

  @override
  String get sendMoneyValidEmailError => 'Digite um email valido';

  @override
  String get sendMoneySendingToLabel => 'Enviando para';

  @override
  String get sendMoneyEnterAmountError => 'Digite um valor';

  @override
  String get sendMoneyValidAmountError => 'Digite um valor valido';

  @override
  String get sendMoneyNoPreview => 'Previa indisponivel';

  @override
  String get sendMoneyRecipientSection => 'DESTINATARIO';

  @override
  String get sendMoneyTransferAmountRow => 'Valor da transferencia';

  @override
  String get sendMoneyTotalToChargeRow => 'Total a cobrar';

  @override
  String get sendMoneySendNowCta => 'Enviar agora';

  @override
  String get sendMoneyTransferCompleteTitle => 'Transferencia concluida';

  @override
  String sendMoneyTransferCompleteSubtitle(
    Object amount,
    Object recipientName,
  ) {
    return 'Voce enviou $amount para $recipientName';
  }

  @override
  String get sendMoneyAmountSentRow => 'Valor enviado';

  @override
  String get sendMoneyNewBalanceRow => 'Seu novo saldo';

  @override
  String get sendMoneyTransferFailedTitle => 'Falha na transferencia';

  @override
  String get sendMoneyTransferFailedSubtitle =>
      'A transferencia nao pode ser concluida. Tente novamente.';

  @override
  String get onboardingCancelTitle => 'Cancelar configuracao?';

  @override
  String get onboardingCancelMessage =>
      'Voce saira da conta e retornara para o inicio. Voce pode continuar o onboarding depois de entrar novamente.';

  @override
  String get onboardingKeepGoingCta => 'Continuar';

  @override
  String get onboardingCancelSetupCta => 'Cancelar configuracao';

  @override
  String get referralEnterValidCodeError =>
      'Digite um codigo de indicacao valido';

  @override
  String get referralTooLateVerifiedError =>
      'Tarde demais - conta ja verificada';

  @override
  String get referralAppliedSuccess =>
      'Codigo de indicacao aplicado com sucesso.';

  @override
  String get referralTryAgainLater => 'Tente novamente mais tarde';

  @override
  String get referralInvalidCodeError =>
      'Codigo invalido - verifique e tente novamente';

  @override
  String get referralSelfCodeError => 'Voce nao pode usar seu proprio codigo';

  @override
  String get referralAlreadyHasReferrerError => 'Voce ja possui um indicador';

  @override
  String get referralApplyTitle => 'Aplicar indicacao';

  @override
  String get referralGotCodeTitle => 'Tem um codigo de indicacao?';

  @override
  String get referralOptionalSubtitle =>
      'Etapa opcional. Voce so pode aplicar indicacao antes da verificacao.';

  @override
  String get referralApplyCta => 'Aplicar indicacao';

  @override
  String get referralSkipForNowCta => 'Pular por agora';

  @override
  String get referralLoadFailedMessage =>
      'Nao foi possivel carregar os detalhes de indicacao. Tente novamente.';

  @override
  String get referralCodeCopied => 'Codigo copiado';

  @override
  String get referralShareCodeSubtitle =>
      'Compartilhe seu codigo com amigos. Eles devem inserir no cadastro.';

  @override
  String get referralStatsLabel => 'SUAS ESTATISTICAS';

  @override
  String get referralInvitedLabel => 'Convidados';

  @override
  String get referralSuccessfulLabel => 'Com sucesso';

  @override
  String get referralTotalEarnedLabel => 'Total ganho';

  @override
  String get referralHeaderTitle => 'Indique e Ganhe';

  @override
  String get referralHeaderSubtitle => 'Convide amigos e ganhe recompensas.';

  @override
  String get referralYourCodeLabel => 'SEU CODIGO';

  @override
  String get referralCopiedCta => 'Copiado';

  @override
  String get referralCouldNotLoadTitle =>
      'Nao foi possivel carregar os detalhes de indicacao';

  @override
  String get addressWhereDoYouLiveTitle => 'Onde voce mora?';

  @override
  String get addressWhereDoYouLiveSubtitle =>
      'Obrigatorio para verificar sua conta. Fica totalmente privado.';

  @override
  String get addressLineLabel => 'Linha do endereco';

  @override
  String get addressAptSuiteLabel => 'Apto / Suite';

  @override
  String get addressZipCodeLabel => 'CEP';

  @override
  String get addressCityLabel => 'Cidade';

  @override
  String get addressStateLabel => 'Estado';

  @override
  String get addressBvnLabel => 'BVN';

  @override
  String get addressBvnHelper => 'Obrigatorio para residentes da Nigeria.';

  @override
  String get addressHomeAddressTitle => 'Endereco residencial';

  @override
  String get addressOnboardingStepSubtitle =>
      'Etapa 3 de 4  •  Seus dados residenciais.';

  @override
  String get addressUpdateSubtitle => 'Atualize seus dados residenciais.';

  @override
  String get addressSelectCountryHint => 'Selecionar pais';

  @override
  String get addressSelectCountryTitle => 'Selecionar pais';

  @override
  String get addressSearchCountryHint => 'Buscar pais';

  @override
  String get addressUpdatedTitle => 'Endereco atualizado';

  @override
  String get addressUpdatedSubtitle => 'Seus dados residenciais foram salvos.';

  @override
  String get kycIdentityVerificationTitle => 'Verificacao de identidade';

  @override
  String get kycCheckingStatus => 'Verificando o status da sua verificacao...';

  @override
  String get kycApprovedTitle => 'KYC aprovado';

  @override
  String get kycApprovedSubtitle =>
      'Voce esta totalmente verificado. Continue para o painel.';

  @override
  String get kycUnderReviewTitle => 'Em analise';

  @override
  String get kycUnderReviewSubtitle =>
      'Enviaremos um email em ate 24 horas quando a analise terminar.';

  @override
  String get kycDeclinedTitle => 'KYC recusado';

  @override
  String get kycDeclinedSubtitle =>
      'Verifique seu email para o motivo e proximos passos, ou contate o suporte.';

  @override
  String get kycRetryVerificationCta => 'Tentar verificacao novamente';

  @override
  String get kycUnableFetchStatus =>
      'Nao foi possivel buscar seu status. Tente novamente.';

  @override
  String get kycVerifyIdentityTitle => 'Verifique sua\nidentidade';

  @override
  String get kycVerifyIdentitySubtitle =>
      'Ultima etapa — verificacao rapida de documento e selfie. Leva cerca de 2 minutos.';

  @override
  String get kycChecklistGovernmentIdTitle => 'Documento oficial';

  @override
  String get kycChecklistGovernmentIdSubtitle =>
      'Passaporte, carteira de motorista ou identidade nacional';

  @override
  String get kycChecklistSelfieTitle => 'Uma selfie rapida';

  @override
  String get kycChecklistSelfieSubtitle =>
      'Comparada com a foto do seu documento';

  @override
  String get kycChecklistTwoMinutesTitle => 'Cerca de 2 minutos';

  @override
  String get kycChecklistTwoMinutesSubtitle =>
      'A maioria das verificacoes conclui na hora';

  @override
  String get kycDataPrivacyNote =>
      'Seus dados sao criptografados e nunca compartilhados. Verificamos com um parceiro confiavel.';

  @override
  String get kycStartVerificationCta => 'Iniciar verificacao';

  @override
  String get kycPermissionInProgressError =>
      'Uma solicitacao de permissao ja esta em andamento. Aguarde e tente novamente.';

  @override
  String get kycPermissionRequiredError =>
      'Acesso a camera e microfone e obrigatorio para continuar.';

  @override
  String get kycAllowAccessTitle => 'Permitir acesso';

  @override
  String get kycAllowAccessMessage =>
      'Permissoes de camera, microfone e midia sao necessarias para capturar sua selfie de verificacao. Ative nas Configuracoes para continuar.';

  @override
  String get kycNotNowCta => 'Agora nao';

  @override
  String get kycOpenSettingsCta => 'Abrir Configuracoes';

  @override
  String get kycPreparingVerification => 'Preparando verificacao…';

  @override
  String get kycCouldNotOpenVerificationTab =>
      'Nao foi possivel abrir a aba de verificacao. Copiando link…';

  @override
  String get kycAlreadyVerifiedTitle => 'Ja verificado';

  @override
  String get kycGoToDashboardCta => 'Ir para o painel';

  @override
  String get kycAddressRequiredTitle => 'Endereco obrigatorio';

  @override
  String get kycCompleteAddressCta => 'Completar endereco';

  @override
  String get kycAccountInactiveTitle => 'Conta inativa';

  @override
  String get kycSignInAgainTitle => 'Entre novamente';

  @override
  String get kycGoToSignInCta => 'Ir para entrar';

  @override
  String get kycSomethingWentWrongTitle => 'Algo deu errado';

  @override
  String get kycAllSetTitle => 'Tudo pronto!';

  @override
  String get kycAllSetSubtitle =>
      'Sua identidade foi verificada. Bem-vindo a Opei.';

  @override
  String get kycContinueToDashboardCta => 'Continuar para o painel';

  @override
  String get callCta => 'Ligar';

  @override
  String get couldNotOpenDialer => 'Nao foi possivel abrir o discador.';

  @override
  String get buyerNumberCopied => 'Numero do comprador copiado';

  @override
  String get addImageCta => 'Adicionar imagem';

  @override
  String get copiedLabel => 'Copiado';

  @override
  String get cardsTransactionsTitle => 'Transacoes do cartao';

  @override
  String get cardsVirtualReadyMessage => 'Seu cartao virtual esta pronto!';

  @override
  String get cardsVirtualCardLabel => 'Cartao virtual';

  @override
  String get cardsKeepCardCta => 'Manter cartao';

  @override
  String get cardsTerminateCta => 'Encerrar';

  @override
  String get cardsCreateVirtualCardCta => 'Criar cartao virtual';

  @override
  String get cardsTopUpAction => 'Recarregar';

  @override
  String get cardsWithdrawAction => 'Sacar';

  @override
  String get cardsTransactionsAction => 'Transacoes';

  @override
  String get cardsFreezeAction => 'Congelar cartao';

  @override
  String get cardsUnfreezeAction => 'Descongelar cartao';

  @override
  String cardsValueCopied(Object label) {
    return '$label copiado';
  }

  @override
  String get editCta => 'Editar';

  @override
  String get deactivateCta => 'Desativar';

  @override
  String get backCta => 'Voltar';

  @override
  String get goBackCta => 'Voltar';

  @override
  String get iUnderstandCta => 'Eu entendo';

  @override
  String get currencyLabel => 'Moeda';

  @override
  String get providerLabel => 'Provedor';

  @override
  String get frenchLabel => 'Frances';

  @override
  String get p2pTradeCancelledSnack => 'Negociacao cancelada.';

  @override
  String get p2pAdSubmittedReviewSnack => 'Anuncio enviado para revisao.';

  @override
  String get p2pClearFiltersCta => 'Limpar filtros';

  @override
  String get p2pApplyFiltersCta => 'Aplicar filtros';

  @override
  String get p2pThanksForRatingSnack => 'Obrigado pela avaliacao!';

  @override
  String get p2pDisputeSubmittedSnack =>
      'Disputa enviada. O suporte foi notificado.';

  @override
  String get p2pImageUnavailable => 'Imagem indisponivel';

  @override
  String get p2pSubmitDisputeCta => 'Enviar disputa';

  @override
  String get p2pCreateAdTitle => 'Criar anuncio P2P';

  @override
  String get p2pChooseAdType => 'Escolha o tipo de anuncio';

  @override
  String get p2pAddPaymentMethodCta => 'Adicionar metodo de pagamento';

  @override
  String get p2pSelectCurrency => 'Selecionar moeda';

  @override
  String get p2pPreferredLanguage => 'Idioma preferido';

  @override
  String get p2pPreferredCurrency => 'Moeda preferida';

  @override
  String get p2pChoosePayoutCurrencySubtitle =>
      'Escolha a moeda em que deseja receber';

  @override
  String get p2pPayoutCurrencyLabel => 'Moeda de recebimento';

  @override
  String p2pSelectOrAddPaymentMethodsForCurrency(Object currency) {
    return 'Selecione ou adicione metodos de pagamento para $currency';
  }

  @override
  String get p2pCreateBuyAdTitle => 'Criar anuncio de COMPRA';

  @override
  String get p2pCreateBuyAdSubtitle =>
      'Defina o valor, os limites e o preco que voce esta disposto a pagar.';

  @override
  String get sendReceiverFallback => 'Destinatario';

  @override
  String get sendReceiverBadge => 'Destinatario';

  @override
  String get sendAmountTitle => 'Inserir valor';

  @override
  String sendAmountSubtitle(Object currencyCode) {
    return 'Quanto ele vai receber em $currencyCode?';
  }

  @override
  String sendAmountAmountError(Object currencyCode) {
    return 'Insira um valor em $currencyCode acima de 0 para continuar.';
  }

  @override
  String get sendAmountDescriptionMinError =>
      'Insira uma descricao clara (pelo menos 3 caracteres).';

  @override
  String get sendAmountDescriptionMaxError =>
      'A descricao e muito longa (maximo de 120 caracteres).';

  @override
  String get sendAmountCostHint =>
      'Voce vera o custo em USD e a taxa de cambio antes de confirmar.';

  @override
  String get sendDescriptionLabel => 'Descricao *';

  @override
  String get sendDescriptionHint => 'Para que e este pagamento?';

  @override
  String get sendPreviewQuoteUnavailable =>
      'Cotacao indisponivel. Volte e tente novamente.';

  @override
  String get sendPreviewTitle => 'Revisar transferencia';

  @override
  String get sendPreviewSubtitle => 'Confira os detalhes antes de confirmar.';

  @override
  String sendPreviewBalanceShortfall(Object shortfall) {
    return 'Seu saldo esta curto em \$$shortfall. Recarregue para continuar.';
  }

  @override
  String get sendPreviewReservingFunds => 'Reservando fundos…';

  @override
  String get sendPreviewSendingPayment => 'Enviando pagamento…';

  @override
  String get sendPreviewConfirmCta => 'Confirmar e enviar';

  @override
  String get sendPreviewYouPayLabel => 'VOCE PAGA';

  @override
  String get sendPreviewTheyReceiveLabel => 'ELE RECEBE';

  @override
  String get sendPreviewRecipientBadge => 'Destinatario';

  @override
  String get sendPreviewSendAmountRow => 'Valor enviado';

  @override
  String get sendPreviewTransferFeeRow => 'Taxa de transferencia';

  @override
  String get sendPreviewTotalChargedRow => 'Total cobrado';

  @override
  String get sendPreviewWalletAfterRow => 'Carteira apos';

  @override
  String get sendPreviewNoteRow => 'Observacao';

  @override
  String sendPreviewQuoteExpiresAt(Object time) {
    return 'Cotacao expira as $time';
  }

  @override
  String get sendResultMoneySentTitle => 'Dinheiro enviado';

  @override
  String sendResultMoneySentSubtitle(Object receiverName) {
    return 'Seu pagamento para $receiverName foi entregue.';
  }

  @override
  String get sendResultCompletedStatus => 'CONCLUIDO';

  @override
  String get sendResultPaymentFailedTitle => 'Falha no pagamento';

  @override
  String get sendResultPaymentFailedSubtitle =>
      'O provedor nao conseguiu processar este pagamento. Nenhum valor foi debitado.';

  @override
  String get sendResultFailedStatus => 'FALHOU';

  @override
  String get sendResultSendingInProgressTitle => 'Envio em andamento';

  @override
  String sendResultSendingInProgressSubtitle(Object receiverName) {
    return 'Seu pagamento esta a caminho de $receiverName. Vamos avisar quando for confirmado.';
  }

  @override
  String get sendResultProcessingStatus => 'PROCESSANDO';

  @override
  String get sendResultStatusUnknownTitle => 'Status desconhecido';

  @override
  String get sendResultStatusUnknownSubtitle =>
      'Verifique as Atividades em alguns instantes para ver o resultado.';

  @override
  String get sendResultUnknownStatus => 'DESCONHECIDO';

  @override
  String get sendResultReceivedLabel => 'RECEBIDO';

  @override
  String get sendResultDateRow => 'Data';

  @override
  String get quickAuthEnterPinTitle => 'Insira seu PIN';

  @override
  String get quickAuthNoPinTitle => 'PIN nao configurado';

  @override
  String get quickAuthEnterPinSubtitle =>
      'Use seu PIN de 6 digitos para entrar';

  @override
  String get quickAuthNoPinSubtitle =>
      'Configure um PIN nas configuracoes da sua conta';

  @override
  String get quickAuthVerifyingTitle => 'Verificando';

  @override
  String get quickAuthVerifyingSubtitle => 'Um momento, por favor';

  @override
  String get quickAuthFaceIdBanner => 'Use Face ID para entrar mais rapido';

  @override
  String get quickAuthFingerprintBanner =>
      'Use impressao digital para entrar mais rapido';

  @override
  String get quickAuthEnableCta => 'Ativar';

  @override
  String get quickAuthDismissTooltip => 'Fechar';

  @override
  String get quickAuthUsePasswordCta => 'Usar senha';

  @override
  String get p2pBuyerLabel => 'Comprador';

  @override
  String get p2pSellerLabel => 'Vendedor';

  @override
  String get p2pSelectStarRatingError =>
      'Selecione uma classificacao por estrelas.';

  @override
  String get p2pFailedSubmitRatingError =>
      'Falha ao enviar avaliacao. Tente novamente.';

  @override
  String p2pRateCounterpartyTitle(Object counterparty) {
    return 'Avaliar $counterparty';
  }

  @override
  String get p2pHowWasExperienceSubtitle => 'Como foi sua experiencia?';

  @override
  String get p2pWhatWentWellLabel => 'O que correu bem?';

  @override
  String get p2pCommentsLabel => 'Comentarios';

  @override
  String get p2pShareExperienceHint => 'Compartilhe sua experiencia...';

  @override
  String get p2pSubmitRatingCta => 'Enviar avaliacao';

  @override
  String get refreshCta => 'Atualizar';

  @override
  String get addressLabel => 'Endereco';

  @override
  String get accountNumberLabel => 'Numero da conta';

  @override
  String get accountNameLabel => 'Nome da conta';

  @override
  String get detailsLabel => 'Detalhes';

  @override
  String get networkLabel => 'Rede';

  @override
  String get paymentMethodLabel => 'Metodo de pagamento';

  @override
  String get exchangeRateLabel => 'Taxa de cambio';

  @override
  String get withdrawChooseMethodSubtitle => 'Escolha um metodo de saque';

  @override
  String get withdrawMobileMoneyTitle => 'Dinheiro movel';

  @override
  String get withdrawMobileMoneySubtitle => 'M-Pesa, Airtel Money e mais';

  @override
  String get withdrawBankTransferTitle => 'Transferencia bancaria';

  @override
  String get withdrawBankTransferSubtitle => 'Enviar para conta bancaria';

  @override
  String get withdrawP2PExchangeTitle => 'Cambio P2P';

  @override
  String get withdrawP2PExchangeSubtitle =>
      'Venda para compradores e receba diretamente';

  @override
  String get withdrawStablecoinSubtitle =>
      'Envie USDT ou USDC para sua carteira cripto';

  @override
  String get withdrawEnterAmountError => 'Insira um valor';

  @override
  String get withdrawEnterDestinationError => 'Insira um endereco de destino';

  @override
  String get withdrawEnterValidAmountError =>
      'Insira um valor valido maior que zero';

  @override
  String withdrawDetailsSubtitle(Object currency, Object network) {
    return 'Insira os detalhes do seu saque de $currency na rede $network.';
  }

  @override
  String get withdrawAmountHelper => 'Insira o valor que voce deseja enviar';

  @override
  String get withdrawAmountPlaceholder => '0.00';

  @override
  String get withdrawDestinationAddressLabel => 'Endereco de destino';

  @override
  String get withdrawDestinationAddressHelper =>
      'Cole o endereco da carteira que vai receber os fundos';

  @override
  String get withdrawDestinationAddressPlaceholder => 'Endereco da carteira';

  @override
  String get withdrawMemoOptionalLabel => 'Memo (opcional)';

  @override
  String get withdrawMemoHelper =>
      'Adicione uma nota para seus proprios registros';

  @override
  String get withdrawMemoPlaceholder => 'Memo ou descricao';

  @override
  String get withdrawInfoDoubleCheck =>
      'Confirme a rede e o endereco antes de enviar.';

  @override
  String get withdrawInfoStatusUpdates =>
      'Vamos avisar quando o status da transferencia for atualizado.';

  @override
  String get withdrawReviewTitle => 'Revisar saque';

  @override
  String withdrawReviewSubtitle(Object currency) {
    return 'Confirme estes detalhes antes de enviarmos seu $currency.';
  }

  @override
  String get withdrawAssetLabel => 'Ativo';

  @override
  String get withdrawNetworkLabel => 'Rede';

  @override
  String get withdrawDestinationLabel => 'Destino';

  @override
  String get withdrawConfirmCta => 'Confirmar';

  @override
  String get withdrawSubmittedTitle => 'Saque enviado';

  @override
  String get withdrawSentTitle => 'Saque enviado';

  @override
  String withdrawSentSubtitle(Object asset, Object network) {
    return 'Estamos processando sua transferencia de $asset na rede $network. Voce recebera uma atualizacao assim que as confirmacoes acontecerem.';
  }

  @override
  String get withdrawRequestedLabel => 'Solicitado';

  @override
  String get cardsCardNumberLabel => 'Numero do cartao';

  @override
  String get cardsExpiresLabel => 'Validade';

  @override
  String get cardsExpiryDateLabel => 'Data de validade';

  @override
  String get cardsCvvLabel => 'CVV';

  @override
  String copyLabelWithValue(Object value) {
    return 'Copiar $value';
  }

  @override
  String get cardsUseCaseSubscriptionsTitle => 'Assinaturas';

  @override
  String get cardsUseCaseSubscriptionsSubtitle => 'Netflix, Spotify e mais';

  @override
  String get cardsUseCaseOnlineShoppingTitle => 'Compras online';

  @override
  String get cardsUseCaseOnlineShoppingSubtitle => 'Compre em qualquer loja';

  @override
  String get cardsUseCaseTravelTitle => 'Viagens e passagens';

  @override
  String get cardsUseCaseTravelSubtitle => 'Reserve voos e hoteis';

  @override
  String get cardsUseCaseGamingTitle => 'Jogos';

  @override
  String get cardsUseCaseGamingSubtitle => 'Compras em apps e jogos';

  @override
  String get cardsUseCaseInternationalTitle =>
      'Pagamentos em lojas internacionais';

  @override
  String get cardsUseCaseInternationalSubtitle => 'Compre de qualquer lugar';

  @override
  String get cardsUseCaseSecureTitle => 'Compras online seguras';

  @override
  String get cardsUseCaseSecureSubtitle => 'Transacoes protegidas';

  @override
  String get cardsSettingUpCardLoading => 'Configurando seu cartao...';

  @override
  String get cardsReadyToCreate =>
      'Seu cartao virtual esta pronto para ser criado.';

  @override
  String get cardsTopupToCreate =>
      'Recarregue sua carteira para continuar a criacao do cartao.';

  @override
  String get cardsPaymentSummaryLabel => 'RESUMO DO PAGAMENTO';

  @override
  String get cardsTopupRequiredLabel => 'RECARGA NECESSARIA';

  @override
  String get cardsCreateMyCardCta => 'Criar meu cartao';

  @override
  String get cardsAddFundsCta => 'Adicionar fundos';

  @override
  String get cardsCreationFeeRow => 'Taxa de criacao';

  @override
  String get cardsActivationFeeRow => 'Taxa de ativacao';

  @override
  String get cardsOnYourCardRow => 'No seu cartao';

  @override
  String get cardsAmountNeededRow => 'Valor necessario';

  @override
  String get cardsCreatingCardLoading => 'Criando seu cartao...';

  @override
  String get expressStatusFindingAgent => 'Buscando agente';

  @override
  String get expressStatusPayNow => 'Pagar agora';

  @override
  String get expressStatusVerifying => 'Verificando';

  @override
  String get expressStatusUnderReview => 'Em analise';

  @override
  String get expressStatusCompleted => 'Concluido';

  @override
  String get expressStatusExpired => 'Expirado';

  @override
  String get expressStatusCancelled => 'Cancelado';

  @override
  String get expressStatusProcessing => 'Processando';

  @override
  String get expressStatusAvailable => 'Disponivel';

  @override
  String get expressStatusWaitingPayment => 'Aguardando pagamento';

  @override
  String get expressStatusConfirmPayment => 'Confirmar pagamento';

  @override
  String get expressCustomerPaysRow => 'Cliente paga';

  @override
  String get expressYouReleaseRow => 'Voce libera';

  @override
  String get expressYouReceiveRow => 'Voce recebe';

  @override
  String get expressYouPayRow => 'Voce paga';

  @override
  String get agentContactTitle => 'Contato do agente';

  @override
  String get needToFollowUpTitle => 'Precisa acompanhar?';

  @override
  String get disputeExplainIssueHint => 'Explique o problema...';

  @override
  String get addNoteOptionalHint => 'Adicionar nota (opcional)';

  @override
  String get transactionsEarlierGroup => 'Anteriores';

  @override
  String get transactionsTodayGroup => 'Hoje';

  @override
  String get transactionsYesterdayGroup => 'Ontem';

  @override
  String get transactionsFailedStatus => 'Falhou';

  @override
  String get transactionsCancelledStatus => 'Cancelado';

  @override
  String get transactionsReversedStatus => 'Estornado';

  @override
  String get transactionsRefundedStatus => 'Reembolsado';

  @override
  String get usBankTransferSetupTitle => 'Configuracao da transferencia';

  @override
  String get usBankTransferTypeLabel => 'Tipo de transferencia';

  @override
  String get usBankBeneficiaryTypeLabel => 'Tipo de beneficiario';

  @override
  String get usBankAccountTypeLabel => 'Tipo de conta';

  @override
  String get usBankAccountNumbersTitle => 'Numeros da conta';

  @override
  String get usBankRoutingNumberLabel => 'Numero de roteamento';

  @override
  String get usBankBankInformationTitle => 'Informacoes do banco';

  @override
  String get usBankBankNameLabel => 'Nome do banco';

  @override
  String get usBankBankAddressLabel => 'Endereco do banco';

  @override
  String get usBankRemittancePurposeTitle => 'Finalidade da remessa';

  @override
  String get usBankBeneficiaryDetailsTitle => 'Detalhes do beneficiario';

  @override
  String get usBankBusinessNameLabel => 'Nome da empresa';

  @override
  String get usBankFullNameLabel => 'Nome completo';

  @override
  String get referralCodeHint => 'Cole o codigo ou https://opei.app/r/CODE';

  @override
  String get sendMoneyAmountHint => '0.00';
}
