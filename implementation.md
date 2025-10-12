# Implementation Document: Tuya App

This document details the implementation specifics of the Tuya Flutter application, including project structure, dependencies, and implemented features.

## 1. Project Structure

The project follows a feature-driven directory structure.

```
lib/
├── main.dart
└── src/
    ├── core/
    │   ├── extensions/
    │   ├── helpers/
    │   ├── utils/
    │   └── widgets/
    └── features/
        ├── auth/
        │   ├── data/
        │   ├── domain/
        │   └── presentation/
        └── home/
            ├── data/
            ├── domain/
            └── presentation/
```

- **`main.dart`**: The entry point of the application. It initializes dependency injection and sets up the root widget.
- **`src/core/`**: Contains shared code, utilities, and widgets.
- **`src/features/`**: Contains the application's feature modules.

## 2. Implemented Features

### 2.1. Authentication (`auth`)

- **Functionality**: Handles user authentication with the Tuya platform.
- **Layers**:
  - **Presentation**:
    - `login_screen.dart`: The main UI for the login flow.
    - `auth_cubit.dart`: Manages the state for authentication (e.g., `AuthInitial`, `AuthLoading`, `AuthSuccess`, `AuthError`).
    - `login_form_card.dart`: A widget containing the email/password fields and login button.
  - **Domain**:
    - `auth_repository.dart`: Abstract contract for authentication operations.
    - `auth_usecase.dart`: Business logic for logging in a user.
    - `user.dart`: The user entity.
  - **Data**:
    - `tuya_impl.dart`: The concrete implementation of the `AuthRepository`, which calls the Tuya data source.
    - `tuya_auth_data_source.dart`: Responsible for making the actual API calls to the Tuya authentication endpoints.

### 2.2. Home (`home`)

- **Functionality**: Fetches and displays a list of smart devices associated with the user's account.
- **Layers**:
  - **Presentation**:
    - `home_screen.dart`: The main UI that displays the list of devices.
    - `home_cubit.dart`: Manages the state for the home screen (e.g., fetching devices).
    - `device_card.dart`: A widget to display information about a single device.
  - **Domain**:
    - `home_repository.dart`: Abstract contract for home-related data (e.g., fetching devices).
    - `home_usecases.dart`: Business logic for getting the list of devices.
    - `device.dart`, `home.dart`: Business entities for the home and device concepts.
  - **Data**:
    - `home_repository_impl.dart`: Concrete implementation of the `HomeRepository`.
    - `tuya_home_data_source.dart`: Responsible for making API calls to fetch home and device data from Tuya.
    - `device_model.dart`, `home_model.dart`: Data models for parsing the API responses.

## 3. Key Dependencies

- **`flutter_bloc`**: For state management.
- **`get_it`**: For service location and dependency injection.
- **`freezed` & `freezed_annotation`**: For creating immutable data classes and states.
- **`json_serializable` & `json_annotation`**: For generating JSON serialization/deserialization code.
- **`build_runner`**: For running code generation tasks.

## 4. Getting Started

1.  **Install Dependencies**:
    ```sh
    flutter pub get
    ```

2.  **Run Code Generation**:
    This command is needed whenever you change data models (`*model.dart`) or entities (`*.dart`) that use `freezed` or `json_serializable`.
    ```sh
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

3.  **Run the App**:
    ```sh
    flutter run
    ```
