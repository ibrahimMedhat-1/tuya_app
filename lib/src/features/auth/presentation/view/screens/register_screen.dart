import 'dart:async';
import 'package:tuya_app/src/core/utils/app_imports.dart';
import 'package:tuya_app/src/features/auth/presentation/view/widgets/common/auth_tabs.dart';
import 'package:tuya_app/src/features/auth/presentation/view/widgets/forms/modern_text_field.dart';
import 'package:tuya_app/src/features/auth/presentation/view/widgets/forms/modern_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFormValid = false;
  bool _verificationCodeSent = false;
  int _countdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
    _verificationCodeController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _fullNameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty &&
        _confirmPasswordController.text.trim().isNotEmpty &&
        _verificationCodeController.text.trim().isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;
    
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
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateVerificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Verification code is required';
    }
    if (value.length < 4) {
      return 'Verification code must be at least 4 characters';
    }
    return null;
  }

  Future<void> _sendVerificationCode() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<AuthCubit>().sendVerificationCode(_emailController.text.trim());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<AuthCubit>().register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _verificationCodeController.text.trim(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _countdown = 60;
      _verificationCodeSent = true;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0 && mounted) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _verificationCodeSent = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthCubitState>(
      listener: (context, state) {
        if (state is AuthCubitVerificationCodeSent) {
          _startCountdown();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code sent to your email!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        } else if (state is AuthCubitAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Welcome!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          // Navigate to home or login screen
          Navigator.of(context).pop();
        } else if (state is AuthCubitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
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
                      'Welcome',
                      style: TextStyle(
                        fontSize: context.isMobile ? 28 : 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    
                    SizedBox(height: context.isMobile ? 8 : 12),
                    
                    Text(
                      'Register to get Started',
                      style: TextStyle(
                        fontSize: context.isMobile ? 16 : 18,
                        color: const Color(0xFF666666),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    
                    SizedBox(height: context.isMobile ? 40 : 60),
                    
                    // Auth Tabs
                    AuthTabs(
                      selectedTab: AuthTab.register,
                      onTabChanged: (tab) {
                        if (tab == AuthTab.login) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    
                    SizedBox(height: context.isMobile ? 32 : 40),
                    
                    // Register Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Full Name Field
                          ModernTextField(
                            label: 'Full Name',
                            hint: 'Enter your Full Name',
                            controller: _fullNameController,
                            enabled: !_isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: context.isMobile ? 20 : 24),
                          
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
                          
                          // Verification Code Field
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: ModernTextField(
                                  label: 'Verification Code',
                                  hint: 'verification code',
                                  controller: _verificationCodeController,
                                  keyboardType: TextInputType.number,
                                  enabled: !_isLoading,
                                  validator: _validateVerificationCode,
                                ),
                              ),
                              SizedBox(width: context.isMobile ? 12 : 16),
                              SizedBox(
                                width: context.isMobile ? 120 : 140,
                                child: ModernButton(
                                  text: _verificationCodeSent 
                                      ? 'Resend ($_countdown)'
                                      : 'Send Code',
                                  onPressed: _verificationCodeSent ? null : _sendVerificationCode,
                                  isLoading: false,
                                  isEnabled: !_verificationCodeSent && !_isLoading,
                                ),
                              ),
                            ],
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
                          
                          SizedBox(height: context.isMobile ? 20 : 24),
                          
                          // Confirm Password Field
                          ModernTextField(
                            label: 'Confirm Password',
                            hint: 'Enter your password',
                            controller: _confirmPasswordController,
                            isPassword: true,
                            enabled: !_isLoading,
                            validator: _validateConfirmPassword,
                          ),
                          
                          SizedBox(height: context.isMobile ? 32 : 40),
                          
                          // Register Button
                          ModernButton(
                            text: 'Register',
                            onPressed: _handleRegister,
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
      ),
    );
  }
}