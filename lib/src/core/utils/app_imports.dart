// Flutter SDK
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';

// State Management
export 'package:flutter_bloc/flutter_bloc.dart';

// Core Helpers
export 'package:tuya_app/src/core/helpers/spacing_extensions.dart';
export 'package:tuya_app/src/core/helpers/responsive_extensions.dart';

// Core Utils
export 'package:tuya_app/src/core/utils/di.dart';
export 'package:json_annotation/json_annotation.dart';

// Core Widgets
export 'package:tuya_app/src/core/widgets/app_button.dart';
export 'package:tuya_app/src/core/widgets/app_text_field.dart';
export 'package:tuya_app/src/core/widgets/app_card.dart';

// App Screens
export 'package:tuya_app/src/features/auth/presentation/view/screens/login_screen.dart';

// App Widgets - Login
export 'package:tuya_app/src/features/auth/presentation/view/widgets/login/login_header.dart';
export 'package:tuya_app/src/features/auth/presentation/view/widgets/login/login_form_card.dart';
export 'package:tuya_app/src/features/auth/presentation/view/widgets/login/social_login_section.dart';
export 'package:tuya_app/src/features/auth/presentation/view/widgets/login/sign_up_link.dart';

// App Cubits/Blocs - Note: These files use part/part of, so they should be imported individually

// App Entities
export 'package:tuya_app/src/features/auth/domain/entities/user.dart';

// App Repositories
export 'package:tuya_app/src/features/auth/data/repositories/auth_repository.dart';
// Data layer exports
export 'package:tuya_app/src/features/auth/data/datasources/tuya_auth_data_source.dart';
export 'package:tuya_app/src/features/auth/data/repositories/tuya_impl.dart';
export 'package:tuya_app/src/features/auth/domain/usecases/auth_usecase.dart';
