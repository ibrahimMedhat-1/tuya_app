import 'package:tuya_app/src/core/utils/app_imports.dart';

class SignUpLink extends StatelessWidget {
  final VoidCallback? onTap;

  const SignUpLink({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: context.isMobile ? 14 : 16,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
