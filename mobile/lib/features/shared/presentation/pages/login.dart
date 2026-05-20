import 'package:flutter/material.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // Sign in with Supabase
        await supabase.auth.signInWithPassword(
          email: _usernameController.text.trim(),
          password: _passwordController.text,
        );

        // Get user role from profile
        final userId = supabase.auth.currentUser!.id;
        print('DEBUG: Looking for user with ID: $userId');

        final profile = await supabase
            .from('users')
            .select('role')
            .eq('id', userId)
            .maybeSingle();

        print('DEBUG: Profile result: $profile');

        if (profile == null) {
          // User doesn't have a profile in the users table
          await supabase.auth.signOut();
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Profil utilisateur non trouvé. Contactez l\'administrateur.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final role = (profile['role'] as String).toLowerCase();

        if (mounted) {
          setState(() => _isLoading = false);

          // Navigate based on role
          if (role == 'employee') {
            // Navigate to employee dashboard
            Navigator.pushReplacementNamed(context, '/employee');
          } else if (role == 'supervisor') {
            // Navigate to supervisor dashboard
            Navigator.pushReplacementNamed(context, '/supervisor');
          } else {
            // Admin or other roles not allowed here
            await supabase.auth.signOut();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Accès non autorisé'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de connexion: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Illustration
                      Image.asset(
                        'assets/Checking_boxes.png',
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        'Bienvenue',
                        style: AppTextStyles.screenTitle.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connectez-vous à votre compte',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Form Container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Email Field
                            Text(
                              'Email',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Entrez votre email',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.5,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.textSecondary.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.textSecondary.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.failure,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              style: AppTextStyles.bodyMedium,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password Field
                            Text(
                              'Mot de passe',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                hintText: 'Entrez votre mot de passe',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.5,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.textSecondary.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.textSecondary.withOpacity(
                                      0.2,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.failure,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              style: AppTextStyles.bodyMedium,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre mot de passe';
                                }
                                if (value.length < 6) {
                                  return 'Le mot de passe doit contenir au moins 6 caractères';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            PrimaryButton(
                              text: 'Connexion',
                              icon: Icons.arrow_forward,
                              onPressed: _handleLogin,
                              isLoading: _isLoading,
                              backgroundColor: AppColors.primary,
                            ),
                            const SizedBox(height: 16),

                            // Forgot Password
                            SecondaryButton(
                              text: 'Mot de passe oublié',
                              onPressed: () {
                                // Handle forgot password
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Fonctionnalité bientôt disponible',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
