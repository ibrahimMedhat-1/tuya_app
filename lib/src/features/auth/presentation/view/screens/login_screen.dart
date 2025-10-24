import 'package:tuya_app/src/core/utils/app_imports.dart';
import 'package:tuya_app/src/features/auth/presentation/view/widgets/common/auth_tabs.dart';
import 'package:tuya_app/src/features/auth/presentation/view/widgets/forms/modern_text_field.dart';
import 'package:tuya_app/src/features/auth/presentation/view/widgets/forms/modern_button.dart';
import 'package:tuya_app/src/features/auth/presentation/view/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;
    
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<AuthCubit>().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.isMobile ? 24 : 32,
            vertical: context.isMobile ? 20 : 32,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: context.screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset('assets/images/logo.png'),
                  
                  SizedBox(height: context.isMobile ? 40 : 60),
                  
                  // Welcome Text
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: context.isMobile ? 28 : 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  SizedBox(height: context.isMobile ? 8 : 12),
                  
                  Text(
                    'Login to access your account',
                    style: TextStyle(
                      fontSize: context.isMobile ? 16 : 18,
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  SizedBox(height: context.isMobile ? 40 : 60),
                  
                  // Auth Tabs
                  AuthTabs(
                    selectedTab: AuthTab.login,
                    onTabChanged: (tab) {
                      if (tab == AuthTab.register) {
                        _navigateToRegister();
                      }
                    },
                  ),
                  
                  SizedBox(height: context.isMobile ? 32 : 40),
                  
                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        ModernTextField(
                          label: 'Email Address',
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLoading,
                          validator: _validateEmail,
                        ),
                        
                        SizedBox(height: context.isMobile ? 20 : 24),
                        
                        // Password Field
                        ModernTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          isPassword: true,
                          enabled: !_isLoading,
                          validator: _validatePassword,
                        ),
                        
                        SizedBox(height: context.isMobile ? 16 : 20),
                        
                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isLoading ? null : () {
                              // TODO: Implement forgot password
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Forgot password feature coming soon!'),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: context.isMobile ? 14 : 16,
                                color: const Color(0xFF666666),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: context.isMobile ? 32 : 40),
                        
                        // Login Button
                        ModernButton(
                          text: 'Login',
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                          isEnabled: _isFormValid,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: context.isMobile ? 40 : 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
