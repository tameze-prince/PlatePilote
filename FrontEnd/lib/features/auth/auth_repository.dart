import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_session_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

class AuthRepository {
  const AuthRepository(this._ref);

  final Ref _ref;

  Future<void> signIn({required String email, required String password}) {
    return _ref.read(appSessionProvider.notifier).signIn();
  }

  Future<void> signOut() {
    return _ref.read(appSessionProvider.notifier).signOut();
  }
}
