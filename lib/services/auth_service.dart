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

abstract class GoogleIdentityClient {
  GoogleIdentityAccount? get currentUser;

  Future<GoogleIdentityAccount?> signInSilently();
  Future<GoogleIdentityAccount?> signIn();
  Future<void> signOut();
  Future<void> disconnect();
}

class GoogleIdentityAccount {
  const GoogleIdentityAccount({
    required this.email,
    this.displayName,
  });

  final String email;
  final String? displayName;
}

class GoogleSignInIdentityClient implements GoogleIdentityClient {
  GoogleSignInIdentityClient({
    GoogleSignIn? googleSignIn,
    String? clientId,
    String? serverClientId,
  }) : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: const <String>['email'],
              clientId: normalizeId(clientId),
              serverClientId: normalizeId(serverClientId),
            );

  final GoogleSignIn _googleSignIn;

  @override
  GoogleIdentityAccount? get currentUser =>
      _mapAccount(_googleSignIn.currentUser);

  @override
  Future<GoogleIdentityAccount?> signInSilently() async {
    final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
    return _mapAccount(account);
  }

  @override
  Future<GoogleIdentityAccount?> signIn() async {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    return _mapAccount(account);
  }

  @override
  Future<void> signOut() => _googleSignIn.signOut();

  @override
  Future<void> disconnect() => _googleSignIn.disconnect();

  static GoogleIdentityAccount? _mapAccount(GoogleSignInAccount? account) {
    if (account == null) {
      return null;
    }

    return GoogleIdentityAccount(
      email: account.email,
      displayName: account.displayName,
    );
  }
}

class GoogleAuthService implements AuthService {
  GoogleAuthService({
    GoogleIdentityClient? identityClient,
    String? clientId,
    String? serverClientId,
  })  : _clientId = normalizeId(clientId),
        _identityClient = identityClient ??
            GoogleSignInIdentityClient(
              clientId: clientId,
              serverClientId: serverClientId,
            );

  final GoogleIdentityClient _identityClient;
  final String? _clientId;

  @override
  Future<AuthState> loadState() async {
    if (!_hasMinimumConfiguration) {
      return _configurationState();
    }

    try {
      final GoogleIdentityAccount? account =
          _identityClient.currentUser ?? await _identityClient.signInSilently();
      return _stateForAccount(account);
    } on PlatformException catch (error) {
      return _errorState(error.code, error.message);
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
      final GoogleIdentityAccount? account = await _identityClient.signIn();
      if (account == null) {
        return const AuthState(
          isSignedIn: false,
          label: 'Google sign-in was cancelled.',
        );
      }
      return _stateForAccount(account);
    } on PlatformException catch (error) {
      return _errorState(error.code, error.message);
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
      await _identityClient.disconnect();
    } on PlatformException catch (_) {
      await _identityClient.signOut();
    } catch (_) {
      await _identityClient.signOut();
    }

    return const AuthState(
      isSignedIn: false,
      label: 'Signed out. Sign in with Google to back up your tracker.',
    );
  }

  bool get _hasMinimumConfiguration {
    if (kIsWeb) {
      return _clientId != null;
    }
    return true;
  }

  AuthState _stateForAccount(GoogleIdentityAccount? account) {
    if (account == null) {
      return const AuthState(
        isSignedIn: false,
        label: 'Sign in with Google to back up your tracker.',
      );
    }

    final String displayName = _displayNameFor(account);

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

  AuthState _errorState(String? code, String? message) {
    switch (code) {
      case 'sign_in_canceled':
      case 'canceled':
      case 'cancelled':
        return const AuthState(
          isSignedIn: false,
          label: 'Google sign-in was cancelled.',
        );
      case 'network_error':
      case 'network-request-failed':
        return const AuthState(
          isSignedIn: false,
          label:
              'Google authentication is unavailable. Check your connection and try again.',
        );
      case 'sign_in_failed':
      case 'failed_to_recover_auth':
      case 'client_configuration_error':
      case 'invalid_client':
        return const AuthState(
          isSignedIn: false,
          label: 'Google sign-in failed. Check your OAuth setup and try again.',
        );
    }

    final String detail = message?.toLowerCase().trim() ?? '';
    if (detail.contains('network')) {
      return const AuthState(
        isSignedIn: false,
        label:
            'Google authentication is unavailable. Check your connection and try again.',
      );
    }
    if (detail.contains('cancel')) {
      return const AuthState(
        isSignedIn: false,
        label: 'Google sign-in was cancelled.',
      );
    }

    return const AuthState(
      isSignedIn: false,
      label: 'Google authentication is unavailable right now.',
    );
  }

  String _displayNameFor(GoogleIdentityAccount account) {
    final String? displayName = account.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    return _maskEmail(account.email);
  }

  String _maskEmail(String email) {
    final int atIndex = email.indexOf('@');
    if (atIndex <= 1 || atIndex == email.length - 1) {
      return 'your Google account';
    }

    final String localPart = email.substring(0, atIndex);
    final String domain = email.substring(atIndex + 1);
    final String visiblePrefix = localPart.substring(0, 1);
    return '$visiblePrefix***@$domain';
  }
}

String? normalizeId(String? value) {
  final String trimmed = value?.trim() ?? '';
  return trimmed.isEmpty ? null : trimmed;
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
