import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/core/utils/user_preferences.dart';
import 'package:kiosk/features/admin/presentation/pages/admin_page.dart';
import 'package:kiosk/features/auth/data/repositories/auth_repository.dart';
import 'package:kiosk/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:kiosk/features/auth/presentation/pages/sign_up_page.dart';
import 'package:kiosk/features/home/presentation/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailOrUsernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthRepository _authRepository = AuthRepository();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      print('=== LOGIN ATTEMPT START ===');
      print('Email/Username: ${_emailOrUsernameController.text.trim()}');
      print('Password length: ${_passwordController.text.length}');
      
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await _authRepository.login(
          _emailOrUsernameController.text.trim(),
          _passwordController.text,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('Login timeout!');
            return null;
          },
        );
        
        print('Login result: ${user != null ? "SUCCESS" : "FAILED"}');

        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });

        if (user != null) {
          // Save user to preferences
          await UserPreferences.saveUser(
            user['id'] as int,
            user['username'] as String,
          );

          // Check if admin (username = 'admin')
          if (user['username'] == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminPage(),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          }
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid email/username or password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.pageBackground,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Logo/Icon
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.brandBrown.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_cafe_rounded,
                        size: 50,
                        color: AppColors.brandBrown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Welcome Text
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  // Email or Username Field
                  TextFormField(
                    controller: _emailOrUsernameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Email or Username',
                      hintText: 'Enter your email or username',
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.brandBrown,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.brandBrown,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email or username';
                      }
                      // If it contains @, validate as email
                      if (value.contains('@')) {
                        if (!value.contains('.') || value.length < 5) {
                          return 'Please enter a valid email';
                        }
                      } else {
                        // Validate as username (at least 3 characters)
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(
                        Icons.lock_outlined,
                        color: AppColors.brandBrown,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.brandBrown,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.brandBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Login Button
                  FilledButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.brandBrown,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

