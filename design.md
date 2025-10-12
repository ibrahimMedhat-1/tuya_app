# Design Document: Tuya App

This document outlines the architectural and design choices for the Tuya Flutter application.

## 1. Architecture

The application follows a **Feature-Driven, Clean Architecture** approach. This isolates features into self-contained modules and separates concerns within each feature, promoting scalability and maintainability.

### 1.1. Directory Structure

- **`lib/src/`**: The main source code directory.
  - **`core/`**: Contains shared code used across multiple features, such as:
    - **`extensions/`**: Dart extension methods for convenience.
    - **`helpers/`**: Utility classes and functions.
    - **`utils/`**: Core utilities like dependency injection (`di.dart`), routing, and constants.
    - **`widgets/`**: Common UI widgets (e.g., `AppButton`, `AppCard`).
  - **`features/`**: Each subdirectory represents a distinct feature of the app (e.g., `auth`, `home`).

### 1.2. Feature Module Structure (Clean Architecture)

Each feature module is divided into three distinct layers:

1.  **Presentation**: The UI layer, responsible for displaying data and handling user input.
    - **`view/`**: Contains the Flutter widgets (Screens, custom widgets).
    - **`manager/`**: Contains the state management logic. We use **Bloc/Cubit** for this purpose. The Cubits react to user interactions and fetch data from the domain layer, emitting states that the UI consumes.

2.  **Domain**: The core business logic layer. It is independent of the other layers.
    - **`entities/`**: Defines the core business objects. These are plain Dart objects, often created using the `freezed` package for immutability.
    - **`repositories/`**: Defines abstract contracts (interfaces) for data sources.
    - **`usecases/`**: Encapsulates a single business operation (e.g., `LoginUser`, `GetHomeDeviceList`). Usecases orchestrate data flow from repositories to the presentation layer.

3.  **Data**: The data layer, responsible for retrieving data from various sources (API, local database, etc.).
    - **`models/`**: Data Transfer Objects (DTOs) that represent data from external sources. These models often include `fromJson`/`toJson` methods for serialization, generated via `json_serializable`.
    - **`repositories/`**: Concrete implementations of the repository contracts defined in the domain layer.
    - **`datasources/`**: The classes responsible for making the actual external data requests (e.g., making HTTP calls to the Tuya API).

## 2. State Management

**Flutter Bloc** (`flutter_bloc`) is the primary state management solution.

- **Cubit**: For simpler state management scenarios, we prefer using Cubits over full-blown Blocs.
- **State Classes**: UI states (e.g., `AuthState`, `HomeState`) are modeled as immutable classes, often using the `freezed` package to define all possible variations (e.g., `initial`, `loading`, `success`, `error`).
- **UI Consumption**: The UI listens to state changes from the Cubit using `BlocBuilder` or `BlocListener` and rebuilds itself accordingly.

## 3. Dependency Injection

**GetIt** (`get_it`) is used as a service locator to manage dependencies throughout the application.

- A central `di.dart` file is responsible for registering all dependencies, such as repositories, data sources, and Cubits.
- This decouples the layers and makes it easy to provide mock implementations for testing.

## 4. UI/UX

- **Framework**: The UI is built using **Flutter**.
- **Design System**: The app uses **Material Design** principles, as indicated by `uses-material-design: true` in `pubspec.yaml`.
- **Custom Widgets**: Reusable widgets are stored in `lib/src/core/widgets/` to ensure a consistent look and feel across the application.

## 5. Code Quality & Immutability

- **Linter**: `flutter_lints` is used to enforce a consistent code style and catch potential errors.
- **Immutability**: The `freezed` package is used to create immutable data classes for entities and states. This helps prevent side effects and makes the application state more predictable.
- **JSON Serialization**: `json_serializable` is used alongside `freezed` to automate the generation of `fromJson` and `toJson` methods for data models.
