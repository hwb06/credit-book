import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udhaar_app/bloc/auth/auth_event.dart';
import 'package:udhaar_app/bloc/auth/auth_state.dart';
import 'package:udhaar_app/data/repositories/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;
  late final StreamSubscription<User?> _sub;

  AuthBloc(this._repo) : super(const AuthState.unknown()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLoginRequested>(_onLogin);
    on<AuthLogoutRequested>(_onLogout);

    _sub = _repo.authStateChanges.listen((user) => add(AuthUserChanged(user)));
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthState.authenticated(event.user!));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLogin(
      AuthLoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthState.loading());
    try {
      await _repo.login(event.email, event.password);
    } catch (e) {
      emit(AuthState.failure(e.toString().replaceFirst('Exception: ', '')));
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> _onLogout(
      AuthLogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await _repo.logout();
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}