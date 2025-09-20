import 'package:tuya_app/src/core/utils/app_imports.dart';

/// Examples of how to use the Dependency Injection system
class DIExamples {
  /// Example 1: Using the global DI container
  static Future<void> example1_GlobalDI() async {
    // Get dependencies directly from the global container
    final authUseCase = di.authUseCase;

    try {
      final user = await authUseCase.login('user@example.com', 'password123');
      print('User logged in: ${user.name}');
    } catch (e) {
      print('Login failed: $e');
    }
  }

  /// Example 2: Using extension methods
  static Future<void> example2_ExtensionMethods() async {
    // Using extension methods (requires an object context)
    final example = DIExamples();
    final authRepository = example.authRepository;

    try {
      await authRepository.resetPassword('user@example.com');
      print('Password reset email sent');
    } catch (e) {
      print('Reset password failed: $e');
    }
  }

  /// Example 3: Using Service Locator
  static Future<void> example3_ServiceLocator() async {
    // Get dependencies using Service Locator
    final authUseCase = getDependency<AuthUseCase>();

    try {
      final user = await authUseCase.login('user@example.com', 'password123');
      print('User logged in via Service Locator: ${user.name}');
    } catch (e) {
      print('Login failed: $e');
    }
  }

  /// Example 4: Manual dependency registration
  static void example4_ManualRegistration() {
    // Create custom instances
    final customDataSource = TuyaAuthDataSource();
    final customRepository = AuthRepositoryImpl(dataSource: customDataSource);
    final customUseCase = AuthUseCase(customRepository);

    // Register them in Service Locator
    ServiceLocator.register<TuyaAuthDataSource>(customDataSource);
    ServiceLocator.register<AuthRepository>(customRepository);
    ServiceLocator.register<AuthUseCase>(customUseCase);

    // Now use them
    final authUseCase = getDependency<AuthUseCase>();
    print(
      'Custom dependencies registered and ready to use: ${authUseCase.runtimeType}',
    );
  }

  /// Example 5: Testing scenario
  static void example5_Testing() {
    // Reset all dependencies for testing
    di.reset();
    ServiceLocator.clear();

    // Register mock dependencies for testing
    // (You would create mock classes that implement the same interfaces)
    // ServiceLocator.register<AuthRepository>(MockAuthRepository());

    print('Dependencies reset for testing');
  }
}

/// Example of using DI in a Widget
class ExampleWidget extends StatelessWidget {
  const ExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Use DI in widget
            try {
              final user = await di.authUseCase.login(
                'test@example.com',
                'password',
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Welcome ${user.name}!')));
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
            }
          },
          child: const Text('Login with DI'),
        ),
      ),
    );
  }
}

/// Example of using DI in a Cubit/Bloc
class ExampleCubit extends Cubit<ExampleState> {
  ExampleCubit() : super(ExampleInitial());

  // Inject dependencies in constructor
  final AuthUseCase _authUseCase = di.authUseCase;

  Future<void> login(String email, String password) async {
    emit(ExampleLoading());

    try {
      final user = await _authUseCase.login(email, password);
      emit(ExampleSuccess(user));
    } catch (e) {
      emit(ExampleError(e.toString()));
    }
  }
}

/// Example states for the cubit
abstract class ExampleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExampleInitial extends ExampleState {}

class ExampleLoading extends ExampleState {}

class ExampleSuccess extends ExampleState {
  final User user;
  ExampleSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ExampleError extends ExampleState {
  final String message;
  ExampleError(this.message);

  @override
  List<Object?> get props => [message];
}
