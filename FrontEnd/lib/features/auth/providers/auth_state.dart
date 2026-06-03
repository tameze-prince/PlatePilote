/// État de l'authentification.
/// Contient les informations de session et l'état de chargement/erreur.
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.name,
    this.errorMessage,
  });

  /// Indique si une opération d'authentification est en cours.
  final bool isLoading;

  /// Indique si l'utilisateur est authentifié.
  final bool isAuthenticated;

  /// Identifiant unique de l'utilisateur.
  final int? userId;

  /// Adresse email de l'utilisateur.
  final String? email;

  /// Nom complet de l'utilisateur.
  final String? name;

  /// Message d'erreur éventuel.
  final String? errorMessage;

  /// Crée une copie avec des champs mis à jour.
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    int? userId,
    String? email,
    String? name,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      name: name ?? this.name,
      errorMessage: errorMessage,
    );
  }

  /// Réinitialise le message d'erreur.
  AuthState clearError() => copyWith(errorMessage: null);
}
