import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ErrorHandler {
  /// Exibe um SnackBar com a mensagem de erro apropriada
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    String message = _getErrorMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Fechar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Exibe um dialog de erro
  static void showErrorDialog(BuildContext context, dynamic error) {
    String message = _getErrorMessage(error);
    String title = _getErrorTitle(error);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Converte o erro em uma mensagem amigável para o usuário
  static String _getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return error.message;
    } else if (error is NetworkException) {
      return error.message;
    } else if (error is TokenExpiredException) {
      return 'Sua sessão expirou. Faça login novamente.';
    } else if (error is ApiException) {
      return error.message;
    } else if (error is SocketException) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    } else if (error is TimeoutException) {
      return 'Tempo limite excedido. Tente novamente.';
    } else if (error is FormatException) {
      return 'Erro de formato de dados. Tente novamente.';
    } else {
      return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  /// Obtém o título apropriado para o erro
  static String _getErrorTitle(dynamic error) {
    if (error is AuthException) {
      return 'Erro de Autenticação';
    } else if (error is NetworkException) {
      return 'Erro de Conexão';
    } else if (error is TokenExpiredException) {
      return 'Sessão Expirada';
    } else if (error is ApiException) {
      return 'Erro da API';
    } else {
      return 'Erro';
    }
  }

  /// Log de erro para debug (sem expor informações sensíveis)
  static void logError(dynamic error, {String? context}) {
    if (error is AuthException) {
      print('Auth Error: ${error.message}');
    } else if (error is NetworkException) {
      print('Network Error: ${error.message}');
    } else if (error is TokenExpiredException) {
      print('Token Expired: ${error.message}');
    } else if (error is ApiException) {
      print('API Error: ${error.message} (Status: ${error.statusCode})');
    } else {
      print('Unexpected Error: ${error.toString()}');
    }
    
    if (context != null) {
      print('Context: $context');
    }
  }

  /// Verifica se o erro é relacionado à autenticação
  static bool isAuthError(dynamic error) {
    return error is AuthException || 
           error is TokenExpiredException ||
           (error is ApiException && error.statusCode == 401);
  }

  /// Verifica se o erro é relacionado à rede
  static bool isNetworkError(dynamic error) {
    return error is NetworkException || 
           error is SocketException ||
           error is TimeoutException;
  }

  /// Verifica se o erro é recuperável (pode tentar novamente)
  static bool isRecoverableError(dynamic error) {
    return error is NetworkException || 
           error is SocketException ||
           error is TimeoutException ||
           (error is ApiException && error.statusCode != null && error.statusCode! >= 500);
  }
}

/// Widget para exibir erros de forma consistente
class ErrorDisplay extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final String? customMessage;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final message = customMessage ?? ErrorHandler._getErrorMessage(error);
    final isRecoverable = ErrorHandler.isRecoverableError(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Ops! Algo deu errado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (isRecoverable && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
