import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../pages/login_page.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const AuthGuard({
    super.key,
    required this.child,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Mostrar loading se estiver carregando
        if (authProvider.isLoading) {
          return loadingWidget ?? const _DefaultLoadingWidget();
        }

        // Mostrar erro se houver
        if (authProvider.error != null) {
          return errorWidget ?? _DefaultErrorWidget(
            error: authProvider.error!,
            onRetry: () => authProvider.clearError(),
          );
        }

        // Se não autenticado, redirecionar para login
        if (!authProvider.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          });
          return const _DefaultLoadingWidget();
        }

        // Se autenticado, mostrar o conteúdo
        return child;
      },
    );
  }
}

/// Widget de loading padrão
class _DefaultLoadingWidget extends StatelessWidget {
  const _DefaultLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000080),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Carregando...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de erro padrão
class _DefaultErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000080),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4169E1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Tentar Novamente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Ir para Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// HOC (Higher Order Component) para proteger páginas
Widget withAuthGuard(Widget child) {
  return AuthGuard(child: child);
}

/// HOC para proteger páginas com loading customizado
Widget withAuthGuardAndLoading(Widget child, Widget loadingWidget) {
  return AuthGuard(
    child: child,
    loadingWidget: loadingWidget,
  );
}

/// HOC para proteger páginas com tratamento de erro customizado
Widget withAuthGuardAndError(
  Widget child,
  Widget Function(String error, VoidCallback onRetry) errorBuilder,
) {
  return AuthGuard(
    child: child,
    errorWidget: Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.error != null) {
          return errorBuilder(authProvider.error!, () => authProvider.clearError());
        }
        return child;
      },
    ),
  );
}
