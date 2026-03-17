import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication status of the current user.
enum AuthStatus { unauthenticated, loading, guest, authenticated }

/// Holds the current authentication state.
class AuthState {
  final AuthStatus status;
  final String? displayName;
  final String? email;
  final String? photoUrl;

  const AuthState({
    required this.status,
    this.displayName,
    this.email,
    this.photoUrl,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? displayName,
    String? email,
    String? photoUrl,
  }) {
    return AuthState(
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

/// Manages authentication flows: Google, Apple, and Guest.
class AuthController extends Notifier<AuthState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Sign in with Google OAuth.
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          displayName: account.displayName,
          email: account.email,
          photoUrl: account.photoUrl,
        );
        return true;
      }
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return false;
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return false;
    }
  }

  /// Sign in with Apple ID (iOS only).
  Future<bool> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      debugPrint("Apple Sign-In: Platform-specific implementation required.");
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return false;
    } catch (e) {
      debugPrint("Apple Sign-In error: $e");
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return false;
    }
  }

  /// Continue without login as a guest user.
  void continueAsGuest() {
    state = const AuthState(
      status: AuthStatus.guest,
      displayName: 'Guest',
    );
  }

  /// Sign out of the current session.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("Sign-out error: $e");
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Check if user is logged in (either authenticated or guest).
  bool get isLoggedIn =>
      state.status == AuthStatus.authenticated ||
      state.status == AuthStatus.guest;
}

/// Riverpod provider for authentication state.
final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
