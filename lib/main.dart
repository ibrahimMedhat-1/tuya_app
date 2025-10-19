import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_app/src/core/utils/di.dart';
import 'package:tuya_app/src/core/utils/routing.dart';
import 'package:tuya_app/src/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:tuya_app/src/features/auth/presentation/view/screens/login_screen.dart';
import 'package:tuya_app/src/features/home/presentation/manager/home_cubit.dart';
import 'src/features/home/presentation/view/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getItInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuthCubit>()..checkLoginStatus()),
        BlocProvider(create: (context) => sl<HomeCubit>()),
      ],
      child: MaterialApp(
        title: 'Zero Code',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: BlocListener<AuthCubit, AuthCubitState>(
          listener: (context, state) {
            if (state is AuthCubitAuthenticated) {
              context.read<HomeCubit>().loadHomes();
            }
          },
          child: BlocBuilder<AuthCubit, AuthCubitState>(
            builder: (context, state) {
              if (state is AuthCubitLoading || state is AuthCubitInitial) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (state is AuthCubitAuthenticated) {
                return const HomeScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
        ),
        onGenerateRoute: RouteGenerator.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
