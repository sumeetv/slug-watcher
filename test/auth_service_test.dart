import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slug_watcher/services/auth_service.dart';

class FakeGoogleIdentityClient implements GoogleIdentityClient {
  FakeGoogleIdentityClient({
    this.currentAccount,
    this.silentAccount,
    this.signInAccount,
    this.signInError,
    this.disconnectError,
  });

  GoogleIdentityAccount? currentAccount;
  GoogleIdentityAccount? silentAccount;
  GoogleIdentityAccount? signInAccount;
  PlatformException? signInError;
  PlatformException? disconnectError;
  int disconnectCalls = 0;
  int signOutCalls = 0;

  @override
  GoogleIdentityAccount? get currentUser => currentAccount;

  @override
  Future<GoogleIdentityAccount?> signInSilently() async => silentAccount;

  @override
  Future<GoogleIdentityAccount?> signIn() async {
    if (signInError != null) {
      throw signInError!;
    }
    return signInAccount;
  }

  @override
  Future<void> signOut() async {
    signOutCalls += 1;
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls += 1;
    if (disconnectError != null) {
      throw disconnectError!;
    }
  }
}

void main() {
  group('GoogleAuthService', () {
    test('masks email address when display name is missing', () async {
      final GoogleAuthService authService = GoogleAuthService(
        identityClient: FakeGoogleIdentityClient(
          signInAccount: const GoogleIdentityAccount(
            email: 'reader@example.com',
          ),
        ),
      );

      final AuthState state = await authService.signIn();

      expect(state.isSignedIn, isTrue);
      expect(state.label, 'Signed in as r***@example.com');
    });

    test('uses display name when available', () async {
      final GoogleAuthService authService = GoogleAuthService(
        identityClient: FakeGoogleIdentityClient(
          signInAccount: const GoogleIdentityAccount(
            email: 'reader@example.com',
            displayName: 'Reader One',
          ),
        ),
      );

      final AuthState state = await authService.signIn();

      expect(state.label, 'Signed in as Reader One');
    });

    test('sanitizes platform errors before returning them to the UI', () async {
      final GoogleAuthService authService = GoogleAuthService(
        identityClient: FakeGoogleIdentityClient(
          signInError: PlatformException(
            code: 'sign_in_failed',
            message: 'invalid_client: client secret mismatch',
          ),
        ),
      );

      final AuthState state = await authService.signIn();

      expect(state.isSignedIn, isFalse);
      expect(
        state.label,
        'Google sign-in failed. Check your OAuth setup and try again.',
      );
      expect(state.label.contains('invalid_client'), isFalse);
      expect(state.label.contains('secret'), isFalse);
    });

    test('disconnects on sign-out and falls back to local sign-out on failure',
        () async {
      final FakeGoogleIdentityClient identityClient = FakeGoogleIdentityClient(
        disconnectError: PlatformException(code: 'disconnect_failed'),
      );
      final GoogleAuthService authService = GoogleAuthService(
        identityClient: identityClient,
      );

      final AuthState state = await authService.signOut();

      expect(state.isSignedIn, isFalse);
      expect(identityClient.disconnectCalls, 1);
      expect(identityClient.signOutCalls, 1);
    });
  });
}
