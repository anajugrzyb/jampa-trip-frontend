import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiresInKey = 'expires_in';
  static const String _userDataKey = 'user_data';

  /// Salva os tokens de autenticação
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _expiresInKey, value: expiresIn.toString()),
    ]);
  }

  /// Obtém o access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Obtém o refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Obtém o timestamp de expiração
  static Future<int?> getExpiresIn() async {
    final expiresInStr = await _storage.read(key: _expiresInKey);
    return expiresInStr != null ? int.tryParse(expiresInStr) : null;
  }

  /// Salva dados do usuário
  static Future<void> saveUserData(String userData) async {
    await _storage.write(key: _userDataKey, value: userData);
  }

  /// Obtém dados do usuário
  static Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  /// Verifica se existe um access token válido
  static Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Verifica se o token está próximo do vencimento (5 minutos)
  static Future<bool> isTokenExpiringSoon() async {
    final expiresIn = await getExpiresIn();
    if (expiresIn == null) return true;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeUntilExpiry = expiresIn - now;
    
    // Considera expirando se falta menos de 5 minutos (300 segundos)
    return timeUntilExpiry < 300;
  }

  /// Limpa todos os tokens e dados do usuário
  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _expiresInKey),
      _storage.delete(key: _userDataKey),
    ]);
  }

  /// Limpa apenas os dados do usuário (mantém tokens)
  static Future<void> clearUserData() async {
    await _storage.delete(key: _userDataKey);
  }
}
