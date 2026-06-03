import '../../core/providers/app_session_provider.dart';

/// Fournisseur d'authentification principal.
/// Redirige vers [appSessionProvider] pour centraliser la gestion de session.
final authProvider = appSessionProvider;
