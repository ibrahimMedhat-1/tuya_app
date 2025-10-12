 import 'package:tuya_app/src/core/utils/app_imports.dart';
import 'package:tuya_app/src/features/auth/presentation/manager/cubit/auth_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthCubitState>(
        listener: (context, state) {
          if (state is AuthCubitError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: context.responsiveHorizontalPadding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: context.screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LoginHeader(),
                      (context.isMobile ? 40.0 : 60.0).height,
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: context.responsiveMaxWidth),
                          child: LoginFormCard(
                            onLoginPressed: (email, password) async{
                              context.read<AuthCubit>().login(email, password);
                            },
                          ),
                        ),
                      ),
                      (context.isMobile ? 30.0 : 40.0).height,
                      (context.isMobile ? 20.0 : 30.0).height,
                      const SignUpLink(),
                      (context.isMobile ? 20.0 : 40.0).height,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
