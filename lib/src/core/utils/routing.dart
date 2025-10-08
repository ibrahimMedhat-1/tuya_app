// Route Constants
import 'package:flutter/material.dart';
import 'package:tuya_app/src/features/home/presentation/view/screens/home_screen.dart';

import 'app_imports.dart' show LoginScreen;

abstract class Routes {
  static const String homeRoute = 'home';
  static const String loginRoute = 'login';
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case Routes.loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ); // Example for LoginScreen

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
