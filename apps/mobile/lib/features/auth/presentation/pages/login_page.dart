import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:altrupets/core/constants/auth_errors.dart';
import 'package:altrupets/core/providers/navigation_provider.dart';
import 'package:altrupets/core/widgets/atoms/app_snackbar.dart';
import 'package:altrupets/features/auth/presentation/providers/auth_provider.dart';
import 'package:altrupets/features/auth/presentation/pages/register_page.dart';
import 'package:altrupets/features/home/presentation/pages/home_page.dart';
import 'package:altrupets/features/profile/presentation/providers/profile_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    // Escuchar cambios en el estado de auth
    ref.listen<AuthState>(authProvider, (previous, next) async {
      debugPrint(
        '[LoginPage] 👂 AuthState cambió: isLoading=${next.isLoading}, error=${next.error != null}, payload=${next.payload != null}',
      );

      final loginCompleted = previous?.isLoading == true && !next.isLoading;
      if (loginCompleted && next.payload != null) {
        debugPrint(
          '[LoginPage] ✅ Login completado - invalidando currentUserProvider...',
        );

        // Login exitoso: precargar perfil y navegar a home
        ref.invalidate(currentUserProvider);

        debugPrint('[LoginPage] ⏳ Esperando currentUserProvider.future...');

        final user = await ref.read(currentUserProvider.future);

        debugPrint(
          '[LoginPage] ✅ currentUserProvider resuelto: ${user != null ? user.username : 'NULL'}',
        );

        final navigation = ref.read(navigationProvider);
        navigation.navigateAndRemoveAll(context, const HomePage());

        debugPrint('[LoginPage] 🚀 Navegación a HomePage completada');
      } else if (next.error != null && previous?.error != next.error) {
        debugPrint(
          '[LoginPage] ============================================================',
        );
        debugPrint('[LoginPage] ❌ Error de login: ${next.error}');
        debugPrint(
          '[LoginPage] ============================================================',
        );

        final error = next.error!;
        String userMessage;
        String title = 'Error';
        bool isConnectionError = false;

        if (error.contains(AuthErrorType.ACCOUNT_LOCKED.code)) {
          title = 'Cuenta bloqueada';
          userMessage = error;
        } else if (error.contains(AuthErrorType.USER_NOT_FOUND.code)) {
          title = 'Usuario no encontrado';
          userMessage = 'El usuario no existe en nuestra base de datos.';
        } else if (error.contains(AuthErrorType.INVALID_PASSWORD.code)) {
          title = 'Credenciales inválidas';
          userMessage =
              'El usuario o contraseña son incorrectos. Por favor intenta de nuevo.';
        } else if (error.contains('connection refused') ||
            error.contains('socketexception') ||
            error.contains('connection timeout')) {
          title = 'Sin conexión';
          userMessage =
              'No se pudo conectar al servidor.\n\nAsegúrate de que el backend esté corriendo en http://localhost:3001';
          isConnectionError = true;
        } else if (error.contains('network')) {
          title = 'Error de red';
          userMessage = 'Error de red. Verifica tu conexión a internet.';
          isConnectionError = true;
        } else {
          userMessage =
              'Ocurrió un error al iniciar sesión. Por favor intenta de nuevo.';
        }

        if (mounted) {
          if (isConnectionError) {
            AppSnackbar.connectionError(
              context: context,
              message: userMessage,
              title: title,
            );
          } else {
            AppSnackbar.error(
              context: context,
              message: userMessage,
              title: title,
              duration: const Duration(seconds: 5),
            );
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bienvenido',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'Email o Usuario',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'usuario@ejemplo.com',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu usuario';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Contraseña',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!authState.isLoading) {
                        _handleLogin();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Iniciar Sesión'),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: theme.colorScheme.outlineVariant),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'O continúa con',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: theme.colorScheme.outlineVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Implement Google Sign-In
                            // Resources:
                            // https://context7.com/websites/pub_dev_google_sign_in
                            // https://firebase.google.com/docs/auth/flutter/start?hl=es-419
                            AppSnackbar.info(
                              context: context,
                              message:
                                  'Implementar Google Sign-In (Ver URLs en código).',
                            );
                          },
                          icon: const Text(
                            'G',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          label: const Text('Google'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            AppSnackbar.info(
                              context: context,
                              message: 'Próximamente!',
                            );
                          },
                          icon: const Icon(Icons.facebook, color: Colors.blue),
                          label: const Text('Facebook'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  InkWell(
                    onTap: () {
                      AppSnackbar.info(
                        context: context,
                        message: 'Próximamente!',
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Icon(
                            Icons.fingerprint,
                            size: 36,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Login con Huella',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push<dynamic>(
                        MaterialPageRoute<dynamic>(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                    child: const Text('Registrar nuevo usuario'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
