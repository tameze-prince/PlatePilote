class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.userId,
    this.email,
    this.name,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final int? userId;
  final String? email;
  final String? name;
  final String? errorMessage;

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

  AuthState clearError() => copyWith(errorMessage: null);
}
