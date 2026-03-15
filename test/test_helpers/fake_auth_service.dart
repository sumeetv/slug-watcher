import 'package:slug_watcher/services/auth_service.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({
    AuthState? initialState,
    AuthState? signInState,
    AuthState? signOutState,
  })  : _currentState = initialState ??
            const AuthState(
              isSignedIn: false,
              label: 'Sign in with Google to back up your tracker.',
            ),
        _signInState = signInState ??
            const AuthState(
              isSignedIn: true,
              label: 'Signed in as Reader',
            ),
        _signOutState = signOutState ??
            const AuthState(
              isSignedIn: false,
              label: 'Signed out. Sign in with Google to back up your tracker.',
            );

  AuthState _currentState;
  final AuthState _signInState;
  final AuthState _signOutState;
  int signInCallCount = 0;
  int signOutCallCount = 0;

  @override
  Future<AuthState> loadState() async => _currentState;

  @override
  Future<AuthState> signIn() async {
    signInCallCount += 1;
    _currentState = _signInState;
    return _currentState;
  }

  @override
  Future<AuthState> signOut() async {
    signOutCallCount += 1;
    _currentState = _signOutState;
    return _currentState;
  }
}
