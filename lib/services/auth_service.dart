import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../utils/api_constants.dart';
import 'storage_service.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  /// Realiza login do usuário
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConstants.fullLoginUrl,
        body: {
          'email': email,
          'password': password,
        },
        includeAuth: false, // Login não precisa de autenticação
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(jsonResponse);
        
        // Salvar tokens
        await StorageService.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          expiresIn: authResponse.expiresIn,
        );
        
        // Salvar dados do usuário
        await StorageService.saveUserData(jsonEncode(authResponse.data.toJson()));
        
        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
        throw AuthException(errorData['message'] ?? 'Erro no login');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro de conexão: ${e.toString()}');
    }
  }

  /// Renova o access token usando o refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _apiService.post(
        ApiConstants.fullRefreshUrl,
        body: {
          'refresh_token': refreshToken,
        },
        includeAuth: false, // Refresh não precisa de autenticação
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Atualizar tokens
        await StorageService.saveTokens(
          accessToken: jsonResponse['access_token'],
          refreshToken: jsonResponse['refresh_token'],
          expiresIn: jsonResponse['expires_in'],
        );
        
        return true;
      } else {
        // Refresh token expirado ou inválido
        await logout();
        return false;
      }
    } catch (e) {
      // Erro na renovação, limpar tokens
      await logout();
      return false;
    }
  }

  /// Realiza logout do usuário
  Future<void> logout() async {
    await StorageService.clearTokens();
  }

  /// Verifica se o usuário está autenticado
  Future<bool> isAuthenticated() async {
    final hasToken = await StorageService.hasValidToken();
    if (!hasToken) return false;
    
    // Verificar se o token não está expirado
    final isExpiring = await StorageService.isTokenExpiringSoon();
    if (isExpiring) {
      // Tentar renovar automaticamente
      final refreshed = await refreshToken();
      return refreshed;
    }
    
    return true;
  }

  /// Obtém dados do usuário atual
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = await StorageService.getUserData();
      if (userData == null) return null;
      
      final userJson = jsonDecode(userData);
      return UserModel.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se o token está próximo do vencimento
  Future<bool> isTokenExpiringSoon() async {
    return await StorageService.isTokenExpiringSoon();
  }

  /// Obtém informações do token JWT
  Map<String, dynamic>? getTokenInfo(String token) {
    try {
      return Jwt.parseJwt(token);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se o token está expirado
  bool isTokenExpired(String token) {
    try {
      return Jwt.isExpired(token);
    } catch (e) {
      return true;
    }
  }

  /// Registra um novo cliente
  Future<AuthResponse> registerClient({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.fullRegisterClientUrl,
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(jsonResponse);
        
        // Salvar tokens
        await StorageService.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          expiresIn: authResponse.expiresIn,
        );
        
        // Salvar dados do usuário
        await StorageService.saveUserData(jsonEncode(authResponse.data.toJson()));
        
        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
        throw AuthException(errorData['message'] ?? 'Erro no cadastro');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro de conexão: ${e.toString()}');
    }
  }

  /// Registra uma nova empresa
  Future<AuthResponse> registerCompany({
    required String companyName,
    required String cnpj,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.fullRegisterCompanyUrl,
        body: {
          'company_name': companyName,
          'cnpj': cnpj,
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(jsonResponse);
        
        // Salvar tokens
        await StorageService.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          expiresIn: authResponse.expiresIn,
        );
        
        // Salvar dados do usuário
        await StorageService.saveUserData(jsonEncode(authResponse.data.toJson()));
        
        return authResponse;
      } else {
        final errorData = jsonDecode(response.body);
        throw AuthException(errorData['message'] ?? 'Erro no cadastro');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Erro de conexão: ${e.toString()}');
    }
  }
}
