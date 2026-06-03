import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_session_provider.dart';

/// Fournisseur du dépôt d'authentification.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

/// Dépôt d'authentification.
/// Délègue les opérations de connexion/déconnexion à [appSessionProvider].
class AuthRepository {
  /// Crée une instance avec une référence Riverpod.
  const AuthRepository(this._ref);

  /// Référence Riverpod pour accéder aux autres providers.
  final Ref _ref;

  /// Authentifie l'utilisateur avec son email et mot de passe.
  Future<void> signIn({required String email, required String password}) {
    return _ref.read(appSessionProvider.notifier).signIn();
  }

  /// Déconnecte l'utilisateur.
  Future<void> signOut() {
    return _ref.read(appSessionProvider.notifier).signOut();
  }
}
