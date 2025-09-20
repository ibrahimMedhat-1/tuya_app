import 'package:tuya_app/src/core/utils/app_imports.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Logo
        Container(
          width: context.isMobile ? 80 : 100,
          height: context.isMobile ? 80 : 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(context.isMobile ? 16 : 20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: context.isMobile ? 15 : 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.home_outlined,
            size: context.isMobile ? 40 : 50,
            color: Colors.white,
          ),
        ),

        (context.isMobile ? 16 : 24).height,

        // App Title
        Text(
          'Tuya Smart Home',
          style: TextStyle(
            fontSize: context.isMobile ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),

        (context.isMobile ? 6 : 8).height,

        // Subtitle
        Text(
          'Welcome back! Please sign in to continue',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.isMobile ? 14 : 16,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
