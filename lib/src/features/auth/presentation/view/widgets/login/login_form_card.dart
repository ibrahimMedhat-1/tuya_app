import 'package:tuya_app/src/core/utils/app_imports.dart';

class LoginFormCard extends StatefulWidget {
  final Future<void> Function(String email,String password)? onLoginPressed; // Changed to allow async
  final VoidCallback? onForgotPasswordPressed;

  const LoginFormCard({
    super.key,
    this.onLoginPressed,
    this.onForgotPasswordPressed,
  });

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false; // Added isLoading state

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkButtonState);
    _passwordController.addListener(_checkButtonState);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkButtonState() {
    if (_isLoading) return; // Don't change button state if loading
    final bool isEnabled =
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;

    if (isEnabled != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (widget.onLoginPressed == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onLoginPressed!(_emailController.text, _passwordController.text);
    } finally {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _isLoading = false;
        });
        _checkButtonState(); // Re-evaluate button enabled state
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: context.isMobile
          ? const EdgeInsets.all(20)
          : const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          AppTextField(
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            enabled: !_isLoading, // Disable field when loading
          ),

          (context.isMobile ? 20 : 24).height,

          // Password Field
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            controller: _passwordController,
            enabled: !_isLoading, // Disable field when loading
          ),

          (context.isMobile ? 12 : 16).height,

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading ? null : widget.onForgotPasswordPressed, // Disable when loading
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: context.isMobile ? 14 : 16,
                ),
              ),
            ),
          ),

          (context.isMobile ? 24 : 32).height,

          // Login Button
          AppButton(
            isLoading: _isLoading,
            text:  'Sign In', // Show text only if not loading
            onPressed: (_isButtonEnabled && !_isLoading) ? _handleLogin : null,
            type: ButtonType.primary,
            isEnabled: _isButtonEnabled && !_isLoading, // Button is enabled if form is valid and not loading
            height: context.isMobile ? 48 : 56,
          ),
        ],
      ),
    );
  }
}
