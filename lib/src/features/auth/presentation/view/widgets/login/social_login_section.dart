import 'package:tuya_app/src/core/utils/app_imports.dart';

class SocialLoginSection extends StatelessWidget {
  final VoidCallback? onGoogleLogin;
  final VoidCallback? onAppleLogin;

  const SocialLoginSection({super.key, this.onGoogleLogin, this.onAppleLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.isMobile ? 12 : 16,
              ),
              child: Text(
                'Or continue with',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: context.isMobile ? 12 : 14,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),

        (context.isMobile ? 20 : 24).height,

        // Social Login Buttons
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Google',
                onPressed:
                    onGoogleLogin ??
                    () {
                      // TODO: Implement Google login
                    },
                type: ButtonType.outline,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                textColor: Colors.white,
                borderRadius: context.isMobile ? 10 : 12,
                height: context.isMobile ? 48 : 56,
              ),
            ),
            (context.isMobile ? 12 : 16).width,
            Expanded(
              child: AppButton(
                text: 'Apple',
                onPressed:
                    onAppleLogin ??
                    () {
                      // TODO: Implement Apple login
                    },
                type: ButtonType.outline,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                textColor: Colors.white,
                borderRadius: context.isMobile ? 10 : 12,
                height: context.isMobile ? 48 : 56,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
