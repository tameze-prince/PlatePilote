// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'PlatePilot';

  @override
  String get splashTagline => 'Seu copiloto inteligente de refeições';

  @override
  String get splashGetStarted => 'Começar';

  @override
  String get step1Title => 'Vamos conhecer sua família';

  @override
  String get step1Subtitle =>
      'PlatePilot ajusta porções, tempo de preparo e orçamento à sua cozinha.';

  @override
  String get step2Title => 'Defina seu orçamento e limites';

  @override
  String get step2Subtitle =>
      'Mantenha refeições realistas sem perder variedade.';

  @override
  String get step3Title => 'Escolha seus objetivos';

  @override
  String get step3Subtitle =>
      'A configuração opcional da despensa ajuda o PlatePilot a usar o que você já tem.';

  @override
  String get householdSize => 'Para quantas pessoas você costuma cozinhar?';

  @override
  String get cookingProfile => 'Perfil de cozinha';

  @override
  String get weeklyBudget => 'Orçamento semanal de compras';

  @override
  String get cookingTime => 'Tempo de cozimento';

  @override
  String get dietaryPrefs => 'Preferências alimentares';

  @override
  String get goals => 'O que o PlatePilot deve otimizar?';

  @override
  String get continueBtn => 'Continuar';

  @override
  String get backBtn => 'Voltar';

  @override
  String get doneBtn => 'Ir para o login';

  @override
  String stepOf(Object current, Object total) {
    return 'Passo $current de $total';
  }

  @override
  String get householdSetup => 'Configuração da família';

  @override
  String get budgetConstraints => 'Orçamento e limites';

  @override
  String get goalsPantry => 'Objetivos e despensa';

  @override
  String get beginner => 'Iniciante';

  @override
  String get balanced => 'Equilibrado';

  @override
  String get batchCook => 'Cozinhar em lote';

  @override
  String get chefMode => 'Modo chef';

  @override
  String get flexible => 'Flexível';

  @override
  String get custom => 'Personalizado';

  @override
  String get highProtein => 'Rico em proteínas';

  @override
  String get vegetarian => 'Vegetariano';

  @override
  String get glutenFree => 'Sem glúten';

  @override
  String get lowCarb => 'Poucos carboidratos';

  @override
  String get saveMoney => 'Economizar';

  @override
  String get eatHealthier => 'Comer mais saudável';

  @override
  String get wasteLess => 'Menos desperdício';

  @override
  String get cookFaster => 'Cozinhar mais rápido';

  @override
  String get pantryLater =>
      'A configuração da despensa pode ser concluída depois na aba Despensa.';

  @override
  String get customBudgetTitle => 'Orçamento semanal personalizado';

  @override
  String get customBudgetSubtitle =>
      'Arraste o controle ou digite o valor exato que quer gastar em compras por semana.';

  @override
  String customBudgetApplied(int amount) {
    return 'Orçamento de $amount \$ salvo';
  }

  @override
  String get resumeDraft => 'Retomar meu rascunho';

  @override
  String get resumeDraftTooltip => 'Continue de onde parou';

  @override
  String goodMorning(Object name) {
    return 'Bom dia, $name!';
  }

  @override
  String get homeSubtitle => 'Pronto para manter o foco e economizar hoje?';

  @override
  String get budgetStatus => 'Status do orçamento';

  @override
  String percentSpent(Object percent) {
    return '$percent% gasto';
  }

  @override
  String get budgetRemaining => 'Orçamento restante';

  @override
  String get yourPlanToday => 'Seu plano de hoje';

  @override
  String get viewFullPlan => 'Ver plano completo';

  @override
  String get quickMealMode => 'Modo refeição rápida';

  @override
  String pantryWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens devem ser usados esta semana.',
      one: '1 item deve ser usado esta semana.',
      zero: 'Nenhum item para usar esta semana',
    );
    return '$_temp0';
  }

  @override
  String get welcomeBack => 'Bem-vindo de volta';

  @override
  String get signInSubtitle =>
      'Entre para sincronizar seu plano semanal e sua lista de compras.';

  @override
  String get signIn => 'Entrar';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get createAccountTitle => 'Crie sua conta PlatePilot';

  @override
  String get signupSubtitle =>
      'O planejamento personalizado de refeições começa com algumas informações.';

  @override
  String get fullName => 'Nome completo';

  @override
  String get emailAddress => 'Endereço de e-mail';

  @override
  String get password => 'Senha';

  @override
  String get haveAccount => 'Já tenho uma conta';

  @override
  String get yourWeek => 'Sua semana';

  @override
  String mealsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count refeições equilibradas selecionadas para sua família.',
      one: '1 refeição equilibrada selecionada para sua família.',
      zero: 'Nenhuma refeição selecionada',
    );
    return '$_temp0';
  }

  @override
  String get quickMeal => 'Refeição rápida';

  @override
  String get expressMode => 'Modo expresso';

  @override
  String get groceryList => 'Lista de compras';

  @override
  String get readyToBuy => 'Pronto para comprar';

  @override
  String get estimatedBudget => 'Orçamento estimado';

  @override
  String budgetDetail(String total, int items, int pantry) {
    String _temp0 = intl.Intl.pluralLogic(
      items,
      locale: localeName,
      other: '$items itens de compra',
      one: '1 item de compra',
    );
    return '$total para $_temp0, incluindo $pantry ingredientes já na despensa.';
  }

  @override
  String itemsToBuy(int count, String pantry) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens para comprar - $pantry itens na despensa',
      one: '1 item para comprar - $pantry itens na despensa',
      zero: 'Nenhum item para comprar',
    );
    return '$_temp0';
  }

  @override
  String get replace => 'Substituir';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get estimatedTotal => 'Total estimado';

  @override
  String get withinBudget => 'Dentro do orçamento';

  @override
  String get items => 'itens';

  @override
  String get searchIngredients => 'Buscar ingredientes...';

  @override
  String get allItems => 'Todos os itens';

  @override
  String get scanOrAdd => 'Escanear ou adicionar à despensa';

  @override
  String get useSoon => 'Usar em breve';

  @override
  String preventWaste(Object amount, Object item, Object recipe) {
    return 'Use $item hoje à noite em $recipe para evitar desperdício e economizar cerca de $amount.';
  }

  @override
  String dinnerIn(Object minutes) {
    return 'Jantar em $minutes minutos';
  }

  @override
  String get quickMealDesc =>
      'Com base na sua despensa, orçamento e preferência de preparo rápido.';

  @override
  String get bestMatches => 'Melhores combinações';

  @override
  String get swap => 'Trocar';

  @override
  String get cook => 'Cozinhar';

  @override
  String get unlockSmarter =>
      'Desbloqueie um planejamento de refeições mais inteligente';

  @override
  String get premiumSubtitle =>
      'Previsões avançadas de orçamento, leituras ilimitadas da despensa, perfis familiares e maiores economias nas compras.';

  @override
  String perMonth(Object price) {
    return '$price / mês';
  }

  @override
  String get aiPlanRegen => 'Regeneração de plano com IA';

  @override
  String get aiPlanRegenSub =>
      'Troque refeições mantendo orçamento e nutrição.';

  @override
  String get unlimitedScans => 'Leituras ilimitadas da despensa';

  @override
  String get unlimitedScansSub =>
      'Captura por nota fiscal, código de barras e câmera.';

  @override
  String get savingsIntelligence => 'Inteligência de economia';

  @override
  String get savingsIntelligenceSub =>
      'Acompanhe a redução do desperdício e as melhores substituições.';

  @override
  String get startTrial => 'Iniciar teste Premium';

  @override
  String get profilePrefs => 'Perfil e preferências';

  @override
  String get profilePrefsSub => 'Família, objetivos, culinárias, alergias';

  @override
  String get notifications => 'Notificações';

  @override
  String get notificationsSub => 'Alertas da despensa e lembretes do plano';

  @override
  String get customRecipes => 'Receitas personalizadas';

  @override
  String get customRecipesSub => 'Salve suas próprias receitas';

  @override
  String get theme => 'Tema';

  @override
  String get settings => 'Configurações';

  @override
  String get upgradeToPremium => 'Atualizar para Premium';

  @override
  String get language => 'Idioma';

  @override
  String get languageSub =>
      'English / Français / Deutsch / Italiano / Português';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageFr => 'Français';

  @override
  String get settingsLanguageDe => 'Deutsch';

  @override
  String get editPreferences => 'Editar preferências';

  @override
  String get budgetManagement => 'Gestão de orçamento';

  @override
  String get addPantryItem => 'Adicionar à despensa';

  @override
  String get addGroceryItem => 'Adicionar item';

  @override
  String get addRecipe => 'Adicionar receita';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get confirm => 'Confirmar';

  @override
  String get loading => 'Carregando...';

  @override
  String get error => 'Algo deu errado';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get search => 'Buscar';

  @override
  String get noResults => 'Nenhum resultado encontrado';

  @override
  String premiumTrialDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Teste Premium - $days dias restantes',
      one: 'Teste Premium - 1 dia restante',
      zero: 'Teste Premium encerrado',
    );
    return '$_temp0';
  }

  @override
  String get followsSystem => 'Segue a aparência do sistema';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get lightMode => 'Modo claro';

  @override
  String weeklyCap(Object amount) {
    return 'Teto semanal de compras $amount';
  }

  @override
  String get activeUsers => 'usuários ativos';

  @override
  String get appRating => 'na App Store';

  @override
  String get avgSavings => 'economizados em média';

  @override
  String get testimonial1Text =>
      'Economizo 45€ por mês nas compras graças às substituições inteligentes!';

  @override
  String get testimonial2Text =>
      'O plano de refeições com IA me fez descobrir receitas que eu nunca teria testado sozinho.';

  @override
  String get testimonial3Text =>
      'Finalmente um app que entende a culinária africana!';

  @override
  String get funnelSkip => 'Pular';

  @override
  String get funnelTrialBadge => 'GRÁTIS POR 7 DIAS';

  @override
  String get funnelExplainTitle => 'Decida menos, economize mais';

  @override
  String get funnelExplainSubtitle =>
      'PlatePilot planeja suas refeições, gera sua lista de compras e acompanha seu orçamento — automaticamente.';

  @override
  String get funnelBenefitAiTitle => 'Planos IA ilimitados';

  @override
  String get funnelBenefitAiSub =>
      'Regenere a semana quando quiser, com orçamento e nutrição preservados.';

  @override
  String get funnelBenefitGroceryTitle =>
      'Lista de compras gerada automaticamente';

  @override
  String get funnelBenefitGrocerySub =>
      'Organizada por corredor, quantidades ajustadas à sua família.';

  @override
  String get funnelBenefitBudgetTitle => 'Otimizador de orçamento';

  @override
  String get funnelBenefitBudgetSub =>
      'Substituições inteligentes para ficar abaixo do seu teto semanal.';

  @override
  String get funnelCtaPickPlan => 'Ver os planos';

  @override
  String get funnelPickPlanTitle => 'Escolha seu plano';

  @override
  String get funnelMonthlyLabel => 'Mensal';

  @override
  String get funnelAnnualLabel => 'Anual';

  @override
  String get funnelMonthlyTitle => 'Mensal';

  @override
  String get funnelMonthlyTag => 'SEM COMPROMISSO';

  @override
  String get funnelMonthlyPrice => 'US\$ 6,99';

  @override
  String get funnelAnnualTitle => 'Anual';

  @override
  String get funnelAnnualPrice => 'US\$ 59,99';

  @override
  String get funnelAnnualEquiv => '~US\$ 4,99/mês';

  @override
  String get funnelPerMonth => '/ mês';

  @override
  String get funnelPerYear => '/ ano';

  @override
  String get funnelSaveBadge => 'ECONOMIZE 28%';

  @override
  String get featuresTitle => 'Recursos Premium';

  @override
  String get funnelFeaturesTitle => 'Tudo no Premium';

  @override
  String get funnelFeatureAi => 'Regeneração ilimitada de refeições com IA';

  @override
  String get funnelFeatureGrocery =>
      'Lista de compras inteligente por corredor';

  @override
  String get funnelFeatureBudget =>
      'Otimização de orçamento e acompanhamento de economia';

  @override
  String get funnelFeatureScans =>
      'Leituras ilimitadas de notas fiscais e códigos de barras';

  @override
  String get funnelFeatureFamily => 'Perfis familiares e preferências';

  @override
  String get funnelSocialProof => '12.400 famílias confiam no PlatePilot';

  @override
  String get funnelCtaStartTrial => 'Iniciar teste grátis';

  @override
  String get funnelTrialCopy => '7 dias grátis, cancele quando quiser';

  @override
  String get funnelPaymentTitle => 'Finalizar assinatura';

  @override
  String get funnelPaymentMethods => 'Forma de pagamento';

  @override
  String get funnelApplePay => 'Apple Pay';

  @override
  String get funnelGooglePay => 'Google Pay';

  @override
  String get funnelCard => 'Cartão de crédito';

  @override
  String get funnelSubscribe => 'Assinar';

  @override
  String get funnelLegalFooter =>
      'Ao assinar, você aceita nossos Termos e nossa Política de Privacidade.';

  @override
  String get cmdPaletteSearchHint => 'Buscar em qualquer lugar...';

  @override
  String get cmdPalettePages => 'Páginas';

  @override
  String get cmdPaletteRecipes => 'Receitas';

  @override
  String get cmdPalettePantry => 'Despensa';

  @override
  String get cmdPaletteEmptyTitle => 'Nenhum resultado';

  @override
  String get cmdPaletteEmptyHint =>
      'Tente outra palavra-chave ou pressione Esc para fechar.';

  @override
  String cmdPaletteEmptyFor(String query) {
    return 'Nenhum resultado para \"$query\"';
  }

  @override
  String get cmdPaletteCloseHint => 'Esc para fechar';

  @override
  String get emptyPantryTitle => 'Sua despensa está vazia';

  @override
  String get emptyPantrySubtitle =>
      'Adicione seus primeiros ingredientes para recomendações mais precisas.';

  @override
  String get emptyPantryCta => 'Adicionar ingrediente';

  @override
  String get emptyGroceryTitle => 'Nenhuma compra ainda';

  @override
  String get emptyGrocerySubtitle =>
      'Gere um plano de refeições para criar sua lista de compras.';

  @override
  String get emptyGroceryCta => 'Gerar plano';

  @override
  String get emptyFavoritesTitle => 'Nenhuma receita favorita ainda';

  @override
  String get emptyFavoritesSubtitle =>
      'Salve suas receitas favoritas para encontrá-las rapidamente.';

  @override
  String get emptyFavoritesCta => 'Explorar receitas';

  @override
  String emptySearchTitle(String query) {
    return 'Nenhum resultado para \"$query\"';
  }

  @override
  String get emptySearchSubtitle => 'Tente outras palavras-chave.';

  @override
  String get emptyNotificationsTitle => 'Você está em dia';

  @override
  String get emptyNotificationsSubtitle =>
      'Nenhuma notificação nova no momento.';

  @override
  String get emptyQuickMealTitle => 'Nenhuma receita à mão';

  @override
  String get emptyQuickMealSubtitle =>
      'Adicione alguns ingredientes à despensa para liberar sugestões.';

  @override
  String get emptyQuickMealCta => 'Abrir despensa';

  @override
  String get onboardingSingleTitle => 'Bem-vindo ao PlatePilot';

  @override
  String get onboardingSingleSubtitle =>
      'Conte-nos algumas coisas e prepararemos sua primeira semana.';

  @override
  String get onboardingSingleHousehold => 'Conte-nos sobre sua família';

  @override
  String onboardingSingleHouseholdPeople(String count) {
    return '$count pessoas';
  }

  @override
  String get onboardingSingleCookingProfile => 'Como você cozinha?';

  @override
  String get onboardingSingleBudget => 'Orçamento semanal de compras';

  @override
  String get onboardingSingleCustom => 'Personalizado';

  @override
  String get onboardingSingleTime => 'Tempo por refeição';

  @override
  String onboardingSingleTimeShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get onboardingSingleTimeFlexible => 'Flexível';

  @override
  String get onboardingSingleDietary => 'Preferências alimentares';

  @override
  String get onboardingSingleGoals => 'Seus objetivos';

  @override
  String get onboardingSingleVegan => 'Vegano';

  @override
  String get onboardingSingleHalal => 'Halal';

  @override
  String get onboardingSingleLactoseFree => 'Sem lactose';

  @override
  String get onboardingSingleKeto => 'Cetogênica';

  @override
  String get onboardingSinglePescatarian => 'Pescetariano';

  @override
  String get onboardingSingleGoalSaveMoney => 'Economizar';

  @override
  String get onboardingSingleGoalEatHealthier => 'Comer mais saudável';

  @override
  String get onboardingSingleGoalWasteLess => 'Menos desperdício';

  @override
  String get onboardingSingleGoalCookFaster => 'Cozinhar mais rápido';

  @override
  String get onboardingSinglePreviewTitle => 'Sua semana';

  @override
  String onboardingSinglePreviewRecipes(int count) {
    return '$count receitas / semana';
  }

  @override
  String onboardingSinglePreviewBudget(String amount) {
    return 'Orçamento $amount';
  }

  @override
  String onboardingSinglePreviewTime(int minutes) {
    return '~$minutes min / refeição';
  }

  @override
  String get onboardingSinglePreviewPantryHint =>
      'A configuração da despensa pode ser concluída depois na aba Despensa.';

  @override
  String get onboardingSinglePreviewEmpty =>
      'Escolha pelo menos um tamanho de família para visualizar a semana.';

  @override
  String get onboardingSingleCtaSeePlan => 'Ver meu plano';

  @override
  String get onboardingSingleCtaCreateAccount => 'Criar minha conta';

  @override
  String get onboardingSingleCtaSignInInstead => 'Entrar em vez disso';

  @override
  String get onboardingSingleCustomizeLater => 'Personalizar depois';

  @override
  String get onboardingSingleSkip => 'Pular';
}
