import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import 'auth_providers.dart';

// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth Controller
class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthController(this._ref) : super(const AuthState());

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final signInUseCase = _ref.read(signInWithEmailProvider);
    final result = await signInUseCase(
      email: email,
      password: password,
    );
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        error: null,
      ),
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final signUpUseCase = _ref.read(signUpWithEmailProvider);
    final result = await signUpUseCase(
      email: email,
      password: password,
      displayName: displayName,
    );
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        error: null,
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final signInGoogleUseCase = _ref.read(signInWithGoogleProvider);
    final result = await signInGoogleUseCase();
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        error: null,
      ),
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final signOutUseCase = _ref.read(signOutProvider);
    final result = await signOutUseCase();
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) => state = const AuthState(),
    );
  }

  void updateAuthState(User? user) {
    state = state.copyWith(
      user: user,
      isAuthenticated: user != null,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth Controller Provider
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref),
);