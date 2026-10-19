import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supervision_mobile/core/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
  });

  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? error;

  @override
  List<Object?> get props => [status, user, error];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  Future<void> restore() async {
    await _repo.init();
    final user = await _repo.me();
    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } else {
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    }
  }

  Future<void> login(String email, String password, {String? apiUrl}) async {
    try {
      if (apiUrl != null && apiUrl.trim().isNotEmpty) {
        await _repo.setBaseUrl(apiUrl);
      }
      final data = await _repo.login(email, password);
      emit(AuthState(
        status: AuthStatus.authenticated,
        user: data['user'] as Map<String, dynamic>?,
      ));
    } catch (e) {
      emit(AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
