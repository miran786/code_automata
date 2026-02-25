import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: isSmallScreen ? 26 : 30,
                ),
              ),
              SizedBox(height: size.height * 0.06),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: size.height * 0.04),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _isLoading = true);
                        final success = await _apiService.login(
                          _usernameController.text,
                          _passwordController.text,
                        );
                        setState(() => _isLoading = false);

                        if (success) {
                          navigator.pushReplacementNamed(
                            AppConstants.dashboardRoute,
                          );
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Invalid credentials'),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login as Patient'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.pushNamed(context, AppConstants.signupRoute),
                child: const Text('Don\'t have an account? Sign up'),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _isLoading = true);
                        await _apiService.signUp(
                          'testuser',
                          'password123',
                          'Test Patient',
                        );
                        final success = await _apiService.login(
                          'testuser',
                          'password123',
                        );
                        setState(() => _isLoading = false);

                        if (success) {
                          navigator.pushReplacementNamed(
                            AppConstants.dashboardRoute,
                          );
                        } else {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Direct Sign In Failed'),
                            ),
                          );
                        }
                      },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Quick Login (Direct Sign In)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
