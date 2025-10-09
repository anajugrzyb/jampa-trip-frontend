import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Timer? _tokenRefreshTimer;

  // Getters
  UserModel? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCompany => _user?.isCompany ?? false;
  bool get isClient => _user?.isClient ?? false;

  AuthProvider() {
    _initializeAuth();
  }

  /// Inicializa o estado de autenticação
  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      await checkAuthStatus();
    } catch (e) {
      _setError('Erro ao verificar autenticação: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Verifica o status de autenticação
  Future<void> checkAuthStatus() async {
    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _user = user;
          _isAuthenticated = true;
          _clearError();
          _scheduleTokenRefresh();
        } else {
          await logout();
        }
      } else {
        await logout();
      }
    } catch (e) {
      _setError('Erro ao verificar autenticação: ${e.toString()}');
      await logout();
    }
    notifyListeners();
  }

  /// Realiza login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final authResponse = await _authService.login(email, password);
      _user = authResponse.data;
      _isAuthenticated = true;
      _scheduleTokenRefresh();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erro no login: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Realiza logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
      _clearError();
      _cancelTokenRefresh();
      notifyListeners();
    } catch (e) {
      _setError('Erro no logout: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Registra um novo cliente
  Future<bool> registerClient({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final authResponse = await _authService.registerClient(
        name: name,
        email: email,
        password: password,
      );
      _user = authResponse.data;
      _isAuthenticated = true;
      _scheduleTokenRefresh();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erro no cadastro: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Registra uma nova empresa
  Future<bool> registerCompany({
    required String companyName,
    required String cnpj,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final authResponse = await _authService.registerCompany(
        companyName: companyName,
        cnpj: cnpj,
        email: email,
        password: password,
      );
      _user = authResponse.data;
      _isAuthenticated = true;
      _scheduleTokenRefresh();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erro no cadastro: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Agenda renovação automática de token
  void _scheduleTokenRefresh() {
    _cancelTokenRefresh();
    
    _tokenRefreshTimer = Timer.periodic(
      const Duration(minutes: 10), // Verificar a cada 10 minutos
      (timer) async {
        try {
          final isExpiring = await _authService.isTokenExpiringSoon();
          if (isExpiring) {
            final refreshed = await _authService.refreshToken();
            if (!refreshed) {
              // Token não pôde ser renovado, fazer logout
              await logout();
            }
          }
        } catch (e) {
          // Erro na renovação, fazer logout
          await logout();
        }
      },
    );
  }

  /// Cancela o timer de renovação de token
  void _cancelTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  /// Limpa o erro atual
  void _clearError() {
    _error = null;
  }

  /// Define um erro
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Define o estado de loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Limpa o erro manualmente
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Força verificação de autenticação
  Future<void> refreshAuthStatus() async {
    await checkAuthStatus();
  }

  @override
  void dispose() {
    _cancelTokenRefresh();
    super.dispose();
  }
}
