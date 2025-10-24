import 'package:flutter/material.dart';
import 'package:tuya_app/src/features/home/presentation/view/screens/home_screen.dart';
import 'package:tuya_app/src/features/auth/presentation/view/screens/register_screen.dart';

import 'app_imports.dart' show LoginScreen;

abstract class Routes {
  static const String homeRoute = 'home';
  static const String loginRoute = 'login';
  static const String registerRoute = 'register';
  static const String controlDeviceRoute = 'control-devices';
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case Routes.loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      case Routes.registerRoute:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );
      // case Routes.controlDeviceRoute:
      //   return MaterialPageRoute(builder: (_) => ControlDeviceScreen());
      default:
        // If the route is not found, you can show an error screen or navigate to a default screen
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
