import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  Future<AuthState> signIn();
  Future<AuthState> signOut();
}

class GoogleAuthService implements AuthService {
  GoogleAuthService({
    GoogleSignIn? googleSignIn,
    String? clientId,
    String? serverClientId,
  })  : _clientId = _normalizeId(clientId),
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const <String>['email'],
              clientId: _normalizeId(clientId),
              serverClientId: _normalizeId(serverClientId),
            );

  final GoogleSignIn _googleSignIn;
  final String? _clientId;

  @override
  Future<AuthState> loadState() async {
    if (!_hasMinimumConfiguration) {
      return _configurationState();
    }

    try {
      final GoogleSignInAccount? account =
          _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
      return _stateForAccount(account);
    } on PlatformException catch (error) {
      return _errorState(error.message);
    } catch (_) {
      return const AuthState(
        isSignedIn: false,
        label: 'Unable to read Google account status right now.',
      );
    }
  }

  @override
  Future<AuthState> signIn() async {
    if (!_hasMinimumConfiguration) {
      return _configurationState();
    }

    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return const AuthState(
          isSignedIn: false,
          label: 'Google sign-in was cancelled.',
        );
      }
      return _stateForAccount(account);
    } on PlatformException catch (error) {
      return _errorState(error.message);
    } catch (_) {
      return const AuthState(
        isSignedIn: false,
        label: 'Google sign-in failed. Check your OAuth setup and try again.',
      );
    }
  }

  @override
  Future<AuthState> signOut() async {
    try {
      await _googleSignIn.signOut();
      return const AuthState(
        isSignedIn: false,
        label: 'Signed out. Sign in with Google to back up your tracker.',
      );
    } on PlatformException catch (error) {
      return _errorState(error.message);
    } catch (_) {
      return const AuthState(
        isSignedIn: false,
        label: 'Unable to sign out right now.',
      );
    }
  }

  bool get _hasMinimumConfiguration {
    if (kIsWeb) {
      return _clientId != null;
    }
    return true;
  }

  AuthState _stateForAccount(GoogleSignInAccount? account) {
    if (account == null) {
      return const AuthState(
        isSignedIn: false,
        label: 'Sign in with Google to back up your tracker.',
      );
    }

    final String displayName = account.displayName?.trim().isNotEmpty == true
        ? account.displayName!.trim()
        : account.email;

    return AuthState(
      isSignedIn: true,
      label: 'Signed in as $displayName',
    );
  }

  AuthState _configurationState() {
    if (kIsWeb) {
      return const AuthState(
        isSignedIn: false,
        label:
            'Set GOOGLE_WEB_CLIENT_ID to enable Google sign-in on web builds.',
      );
    }

    return const AuthState(
      isSignedIn: false,
      label:
          'Sign in with Google after adding your Android or iOS OAuth client setup.',
    );
  }

  AuthState _errorState(String? message) {
    final String detail = message?.trim() ?? '';
    if (detail.isEmpty) {
      return const AuthState(
        isSignedIn: false,
        label: 'Google authentication is unavailable right now.',
      );
    }

    return AuthState(
      isSignedIn: false,
      label: 'Google authentication error: $detail',
    );
  }

  static String? _normalizeId(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}

class StubGoogleAuthService implements AuthService {
  const StubGoogleAuthService();

  @override
  Future<AuthState> loadState() async {
    return const AuthState(
      isSignedIn: false,
      label: 'Google sign-in not configured yet',
    );
  }

  @override
  Future<AuthState> signIn() => loadState();

  @override
  Future<AuthState> signOut() => loadState();
}
