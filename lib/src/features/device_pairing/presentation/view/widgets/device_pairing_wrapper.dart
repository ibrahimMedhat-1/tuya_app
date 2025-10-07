import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_app/src/core/utils/app_imports.dart';
import 'package:tuya_app/src/features/device_pairing/presentation/manager/cubit/device_pairing_cubit.dart';
import 'package:tuya_app/src/features/device_pairing/presentation/view/screens/device_pairing_screen.dart';

class DevicePairingWrapper extends StatelessWidget {
  const DevicePairingWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DevicePairingCubit>(),
      child: const DevicePairingScreen(),
    );
  }
}
