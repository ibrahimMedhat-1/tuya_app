import 'package:tuya_app/src/core/utils/app_imports.dart';

/// Dependency Injection Container
/// This class manages all the dependencies for the application
class DIContainer {
  static final DIContainer _instance = DIContainer._internal();
  factory DIContainer() => _instance;
  DIContainer._internal();

  // Lazy singletons
  TuyaAuthDataSource? _tuyaAuthDataSource;
  AuthRepository? _authRepository;
  AuthUseCase? _authUseCase;

  // Getters for dependencies
  TuyaAuthDataSource get tuyaAuthDataSource {
    _tuyaAuthDataSource ??= TuyaAuthDataSource();
    return _tuyaAuthDataSource!;
  }

  AuthRepository get authRepository {
    _authRepository ??= AuthRepositoryImpl(dataSource: tuyaAuthDataSource);
    return _authRepository!;
  }

  AuthUseCase get authUseCase {
    _authUseCase ??= AuthUseCase(authRepository);
    return _authUseCase!;
  }

  /// Reset all dependencies (useful for testing)
  void reset() {
    _tuyaAuthDataSource = null;
    _authRepository = null;
    _authUseCase = null;
  }

  /// Initialize all core dependencies
  void initialize() {
    // Pre-initialize core dependencies
    tuyaAuthDataSource;
    authRepository;
    authUseCase;
  }
}

/// Global instance for easy access
final di = DIContainer();

/// Extension methods for easy dependency access
extension DIExtensions on Object {
  /// Get Tuya Auth Data Source
  TuyaAuthDataSource get tuyaAuthDataSource => di.tuyaAuthDataSource;

  /// Get Auth Repository
  AuthRepository get authRepository => di.authRepository;

  /// Get Auth Use Case
  AuthUseCase get authUseCase => di.authUseCase;
}

/// Service Locator Pattern
class ServiceLocator {
  static final Map<Type, dynamic> _services = {};

  /// Register a service
  static void register<T>(T service) {
    _services[T] = service;
  }

  /// Get a service
  static T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception(
        'Service of type $T not found. Make sure to register it first.',
      );
    }
    return service as T;
  }

  /// Check if a service is registered
  static bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  /// Unregister a service
  static void unregister<T>() {
    _services.remove(T);
  }

  /// Clear all services
  static void clear() {
    _services.clear();
  }
}

/// Initialize all dependencies
void initializeDependencies() {
  // Register core services
  ServiceLocator.register<TuyaAuthDataSource>(di.tuyaAuthDataSource);
  ServiceLocator.register<AuthRepository>(di.authRepository);
  ServiceLocator.register<AuthUseCase>(di.authUseCase);

  // Initialize DI container
  di.initialize();
}

/// Get dependencies using Service Locator
T getDependency<T>() => ServiceLocator.get<T>();
