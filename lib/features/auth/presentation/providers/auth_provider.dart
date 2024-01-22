import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/auth/domain/domain.dart';
import 'package:teslo_shop/features/auth/infrastructure/infrastructure.dart';
import 'package:teslo_shop/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:teslo_shop/features/shared/infrastructure/services/key_value_storage_service_impl.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) { //? Auth provider
  
  final authRepository = AuthRepositoryImpl();
  final keyValueStorageServices = KeyValueStorageServiceImpl();
  
  return AuthNotifier(
    authRepository: authRepository,
    keyValueStorageServices: keyValueStorageServices
  );
});

class AuthNotifier extends StateNotifier<AuthState> { //? Auth notifier
  AuthNotifier({ 
    required this.authRepository, 
    required this.keyValueStorageServices 
  }): super(AuthState());
  
  final AuthRepository authRepository;
  final KeyValueStorageServices keyValueStorageServices;

  Future<void> loginUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    try {

      final user = await authRepository.login(email, password);
      _setLoggedUser(user);

    } on CustomError catch (e) {

      logOut(e.message);

    } catch (e) {

      logOut('Something wrong happend. Try again later');

    }

  }

  void registerUser(String email, String password) async {
    
  }

  void checkAuthStatus() async {
    final token = await keyValueStorageServices.getValue<String>('token');

    if (token == null) return logOut();

    try {
      
      final user = await authRepository.checkAuthStatus(token);
      _setLoggedUser(user);

    } catch (e) {
      logOut();
    }
  }

  void _setLoggedUser(User user) async {
    await keyValueStorageServices.setKeyValue('token', user.token);

    state = state.copyWith(
      user: user,
      authStatus: AuthStatus.authenticated,
    );
  }

  Future<void> logOut([String? errorMessage]) async {
    await keyValueStorageServices.removeKey('token');

    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
      errorMessage: errorMessage
    );
  }

}

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState { //? Auth state
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  AuthState({
    this.authStatus = AuthStatus.checking, 
    this.user, 
    this.errorMessage = ''
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage
  );
}