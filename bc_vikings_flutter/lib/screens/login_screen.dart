import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../utils/constants.dart';
import '../widgets/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _playerLoginController = TextEditingController();
  final _playerPasswordController = TextEditingController();
  final _coachPasswordController = TextEditingController();
  final _playerFormKey = GlobalKey<FormState>();
  final _coachFormKey = GlobalKey<FormState>();
  
  bool _isCoachMode = false;

  @override
  void dispose() {
    _playerLoginController.dispose();
    _playerPasswordController.dispose();
    _coachPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Deep Blue
              Color(0xFF3B82F6), // Blue
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return LoadingOverlay(
                isLoading: authProvider.isLoading,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      // App Logo/Title
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon(
                          Icons.sports_basketball,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppStrings.appTitle,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Mode Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isCoachMode = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isCoachMode 
                                        ? Colors.white 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    AppStrings.playerMode,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: !_isCoachMode 
                                          ? const Color(0xFF1E3A8A)
                                          : Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isCoachMode = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isCoachMode 
                                        ? Colors.white 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    AppStrings.coachMode,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _isCoachMode 
                                          ? const Color(0xFF1E3A8A)
                                          : Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Login Forms
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isCoachMode 
                            ? _buildCoachLoginForm(authProvider)
                            : _buildPlayerLoginForm(authProvider),
                      ),
                      
                      if (authProvider.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            authProvider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerLoginForm(AuthProvider authProvider) {
    return Form(
      key: _playerFormKey,
      child: Column(
        key: const ValueKey('player'),
        children: [
          _buildTextField(
            controller: _playerLoginController,
            label: AppStrings.playerLogin,
            icon: Icons.person,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return AppStrings.fieldRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _playerPasswordController,
            label: AppStrings.playerPassword,
            icon: Icons.lock,
            isPassword: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return AppStrings.fieldRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildLoginButton(
            onPressed: () => _loginAsPlayer(authProvider),
            text: AppStrings.login,
          ),
        ],
      ),
    );
  }

  Widget _buildCoachLoginForm(AuthProvider authProvider) {
    return Form(
      key: _coachFormKey,
      child: Column(
        key: const ValueKey('coach'),
        children: [
          _buildTextField(
            controller: _coachPasswordController,
            label: AppStrings.coachPassword,
            icon: Icons.admin_panel_settings,
            isPassword: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return AppStrings.fieldRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildLoginButton(
            onPressed: () => _loginAsCoach(authProvider),
            text: AppStrings.login,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildLoginButton({
    required VoidCallback onPressed,
    required String text,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E3A8A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _loginAsPlayer(AuthProvider authProvider) async {
    if (_playerFormKey.currentState?.validate() ?? false) {
      authProvider.clearError();
      final success = await authProvider.loginAsPlayer(
        _playerLoginController.text,
        _playerPasswordController.text,
      );
      
      if (success && mounted) {
        // Navigation will be handled by the main app
      }
    }
  }

  Future<void> _loginAsCoach(AuthProvider authProvider) async {
    if (_coachFormKey.currentState?.validate() ?? false) {
      authProvider.clearError();
      final success = await authProvider.loginAsCoach(
        _coachPasswordController.text,
      );
      
      if (success && mounted) {
        // Navigation will be handled by the main app
      }
    }
  }
}