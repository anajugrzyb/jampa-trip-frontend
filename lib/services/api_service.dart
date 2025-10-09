import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/api_constants.dart';
import 'storage_service.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  final AuthService _authService = AuthService();

  /// Adiciona header de autorização se token disponível
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = Map<String, String>.from(ApiConstants.defaultHeaders);
    
    if (includeAuth) {
      final token = await StorageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    
    return headers;
  }

  /// Intercepta resposta e trata erros de autenticação
  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      // Token expirado, tentar renovar
      try {
        final refreshed = await _authService.refreshToken();
        if (refreshed) {
          // Token renovado com sucesso, retornar erro para retry
          throw TokenExpiredException('Token expirado, tente novamente');
        } else {
          // Falha na renovação, limpar tokens
          await _authService.logout();
          throw AuthException('Sessão expirada. Faça login novamente.');
        }
      } catch (e) {
        if (e is AuthException || e is TokenExpiredException) {
          rethrow;
        }
        throw AuthException('Erro de autenticação: ${e.toString()}');
      }
    }
    
    return response;
  }

  /// GET request
  Future<http.Response> get(String url, {Map<String, String>? queryParams}) async {
    try {
      // Adicionar query parameters se fornecidos
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        final newUri = uri.replace(queryParameters: queryParams);
        url = newUri.toString();
      }

      final headers = await _getHeaders();
      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(ApiConstants.connectTimeout);
      
      return await _handleResponse(response);
    } catch (e) {
      if (e is SocketException) {
        throw NetworkException('Erro de conexão. Verifique sua internet.');
      }
      rethrow;
    }
  }

  /// POST request
  Future<http.Response> post(String url, {Object? body, Map<String, String>? queryParams}) async {
    try {
      // Adicionar query parameters se fornecidos
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        final newUri = uri.replace(queryParameters: queryParams);
        url = newUri.toString();
      }

      final headers = await _getHeaders();
      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectTimeout);
      
      return await _handleResponse(response);
    } catch (e) {
      if (e is SocketException) {
        throw NetworkException('Erro de conexão. Verifique sua internet.');
      }
      rethrow;
    }
  }

  /// PUT request
  Future<http.Response> put(String url, {Object? body, Map<String, String>? queryParams}) async {
    try {
      // Adicionar query parameters se fornecidos
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        final newUri = uri.replace(queryParameters: queryParams);
        url = newUri.toString();
      }

      final headers = await _getHeaders();
      final response = await _client
          .put(
            Uri.parse(url),
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectTimeout);
      
      return await _handleResponse(response);
    } catch (e) {
      if (e is SocketException) {
        throw NetworkException('Erro de conexão. Verifique sua internet.');
      }
      rethrow;
    }
  }

  /// DELETE request
  Future<http.Response> delete(String url, {Map<String, String>? queryParams}) async {
    try {
      // Adicionar query parameters se fornecidos
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        final newUri = uri.replace(queryParameters: queryParams);
        url = newUri.toString();
      }

      final headers = await _getHeaders();
      final response = await _client
          .delete(Uri.parse(url), headers: headers)
          .timeout(ApiConstants.connectTimeout);
      
      return await _handleResponse(response);
    } catch (e) {
      if (e is SocketException) {
        throw NetworkException('Erro de conexão. Verifique sua internet.');
      }
      rethrow;
    }
  }

  /// Upload de arquivo
  Future<http.Response> uploadFile(String url, String filePath, {String fieldName = 'file'}) async {
    try {
      final headers = await _getHeaders();
      // Remover Content-Type para multipart
      headers.remove('Content-Type');
      
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      
      final streamedResponse = await request.send().timeout(ApiConstants.connectTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      return await _handleResponse(response);
    } catch (e) {
      if (e is SocketException) {
        throw NetworkException('Erro de conexão. Verifique sua internet.');
      }
      rethrow;
    }
  }

  /// Fechar cliente HTTP
  void dispose() {
    _client.close();
  }
}

// Exceções customizadas
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class TokenExpiredException implements Exception {
  final String message;
  TokenExpiredException(this.message);
  
  @override
  String toString() => 'TokenExpiredException: $message';
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
