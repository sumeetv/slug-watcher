class AuthState {
  const AuthState({
    required this.isSignedIn,
    required this.label,
  });

  final bool isSignedIn;
  final String label;
}

abstract class AuthService {
  Future<AuthState> loadState();
}

class StubGoogleAuthService implements AuthService {
  @override
  Future<AuthState> loadState() async {
    return const AuthState(
      isSignedIn: false,
      label: 'Google sign-in not configured yet',
    );
  }
}
