import 'package:tuya_app/src/core/utils/app_imports.dart';

class LoginFormCard extends StatefulWidget {
  final VoidCallback? onLoginPressed;
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
    final bool isEnabled =
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;

    if (isEnabled != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
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
          ),

          (context.isMobile ? 20 : 24).height,

          // Password Field
          AppTextField(
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            controller: _passwordController,
          ),

          (context.isMobile ? 12 : 16).height,

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onForgotPasswordPressed,
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
            text: 'Sign In',
            onPressed: _isButtonEnabled ? widget.onLoginPressed : null,
            type: ButtonType.primary,
            isEnabled: _isButtonEnabled,
            height: context.isMobile ? 48 : 56,
          ),
        ],
      ),
    );
  }
}
