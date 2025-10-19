import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_app/src/core/helpers/responsive_extensions.dart';
import 'package:tuya_app/src/core/helpers/spacing_extensions.dart';
import 'package:tuya_app/src/features/home/domain/entities/home.dart';
import 'package:tuya_app/src/features/home/presentation/manager/home_cubit.dart';
import 'package:tuya_app/src/features/home/presentation/view/widgets/device_card.dart';
import 'package:tuya_app/src/features/auth/presentation/manager/cubit/auth_cubit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Smart Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings_outlined),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthCubit>().logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading && state.homes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == HomeStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  16.height,
                  Text(
                    state.errorMessage ?? 'Something went wrong',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  16.height,
                  ElevatedButton(
                    onPressed: () => context.read<HomeCubit>().loadHomes(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Container(
                  padding: context.responsivePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Message
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 28 * context.responsiveFontMultiplier,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      8.height,
                      Text(
                        'Control your smart devices',
                        style: TextStyle(
                          fontSize: 16 * context.responsiveFontMultiplier,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      24.height,

                      // Home Selector
                      _buildHomeSelector(context, state),
                    ],
                  ),
                ),
              ),

              // Devices Section
              if (state.status == HomeStatus.devicesLoaded)
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsivePadding.horizontal / 2,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: context.isMobile ? 2 : context.isTablet ? 3 : 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final device = state.devices[index];
                        // Get home name from the selected home
                        final selectedHome = state.homes.firstWhere(
                          (home) => home.homeId == state.selectedHomeId,
                          orElse: () => state.homes.first,
                        );
                        return DeviceCard(
                          device: device,
                          homeId: state.selectedHomeId,
                          homeName: selectedHome.name,
                        );
                      },
                      childCount: state.devices.length,
                    ),
                  ),
                )
              else if (state.selectedHomeId != null)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.home_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          16.height,
                          Text(
                            'Select a home to view devices',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Add some bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<HomeCubit>().pairDevices(),
        icon: const Icon(Icons.add),
        label: const Text('Add Device'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHomeSelector(BuildContext context, HomeState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: state.selectedHomeId ?? (state.homes.isNotEmpty ? state.homes.first.homeId : null),
          hint: const Text('Select Home'),
          items: state.homes
              .map((HomeEntity h) => DropdownMenuItem<int>(
                    value: h.homeId,
                    child: Text(
                      h.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<HomeCubit>().loadDevices(value);
            }
          },
        ),
      ),
    );
  }


}
