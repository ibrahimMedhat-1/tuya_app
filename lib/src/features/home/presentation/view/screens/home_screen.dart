import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_app/src/core/helpers/responsive_extensions.dart';
import 'package:tuya_app/src/core/helpers/spacing_extensions.dart';
import 'package:tuya_app/src/features/auth/presentation/view/screens/me_screen.dart';
import 'package:tuya_app/src/features/home/domain/entities/home.dart';
import 'package:tuya_app/src/features/home/presentation/manager/home_cubit.dart';
import 'package:tuya_app/src/features/home/presentation/view/widgets/device_card.dart';
import 'package:tuya_app/src/features/home/presentation/view/widgets/room_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          // Handle different tabs based on selectedBottomNavIndex
          if (state.selectedBottomNavIndex == 4) {
            // Me tab
            return const MeScreen();
          }

          if (state.status == HomeStatus.loading && state.homes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
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

          return SafeArea(
            child: Column(
              children: [
                // Header Section
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsivePadding.horizontal,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo Section
                      _buildLogoSection(context),
                      24.height,

                      // Greeting Section
                      _buildGreetingSection(context, state),
                      24.height,

                      // Home Selector
                      _buildHomeSelector(context, state),
                      24.height,

                      // Rooms Section
                      if (state.rooms.isNotEmpty) ...[
                        _buildRoomsSection(context, state),
                        24.height,
                      ] else if (state.selectedHomeId != null &&
                          state.status == HomeStatus.loading) ...[
                        // Loading rooms state
                        Container(
                          height: context.isMobile
                              ? 80
                              : context.isTablet
                              ? 90
                              : 100,
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                context.responsivePadding.horizontal / 2,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ] else if (state.selectedHomeId != null &&
                          state.status != HomeStatus.loading) ...[
                        // Empty rooms state
                        Container(
                          padding: EdgeInsets.all(context.isMobile ? 32 : 48),
                          child: Column(
                            children: [
                              Icon(
                                Icons.room_outlined,
                                size: context.isMobile ? 48 : 64,
                                color: Colors.grey.shade400,
                              ),
                              (context.isMobile ? 16 : 20).height,
                              Text(
                                'No rooms found',
                                style: TextStyle(
                                  fontSize:
                                      16 * context.responsiveFontMultiplier,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              (context.isMobile ? 8 : 12).height,
                              Text(
                                'Add rooms to organize your devices',
                                style: TextStyle(
                                  fontSize:
                                      14 * context.responsiveFontMultiplier,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Devices Section
                Expanded(child: _buildDevicesSection(context, state)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    final logoSize = context.isMobile
        ? 40.0
        : context.isTablet
        ? 45.0
        : 50.0;
    final iconSize = context.isMobile
        ? 24.0
        : context.isTablet
        ? 28.0
        : 32.0;
    final fontSize = context.isMobile
        ? 24.0
        : context.isTablet
        ? 28.0
        : 32.0;

    return Row(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(logoSize / 2),
          ),
          child: Icon(Icons.power, color: Colors.white, size: iconSize),
        ),
        (context.isMobile ? 12 : 16).width,
        Text(
          'ZERO TECH',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingSection(BuildContext context, HomeState state) {
    final buttonSize = context.isMobile
        ? 40.0
        : context.isTablet
        ? 45.0
        : 50.0;
    final iconSize = context.isMobile
        ? 24.0
        : context.isTablet
        ? 28.0
        : 32.0;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, User Name',
                style: TextStyle(
                  fontSize: 18 * context.responsiveFontMultiplier,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              4.height,
              Text(
                'you have ${state.homes.length} Available Home.',
                style: TextStyle(
                  fontSize: 14 * context.responsiveFontMultiplier,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            _showAddHouseDialog(context);
          },
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(context.isMobile ? 8 : 10),
            ),
            child: Icon(Icons.add, color: Colors.white, size: iconSize),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsSection(BuildContext context, HomeState state) {
    final roomHeight = context.isMobile
        ? 80.0
        : context.isTablet
        ? 90.0
        : 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rooms',
              style: TextStyle(
                fontSize: 20 * context.responsiveFontMultiplier,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            if (state.selectedHomeId != null)
              GestureDetector(
                onTap: () {
                  _showAddRoomDialog(context, state.selectedHomeId!);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 16),
                      4.width,
                      Text(
                        'Add Room',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12 * context.responsiveFontMultiplier,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        16.height,
        SizedBox(
          height: roomHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.rooms.length + 1, // +1 for add room button
            itemBuilder: (context, index) {
              if (index == state.rooms.length) {
                // Add room button
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {
                      if (state.selectedHomeId != null) {
                        _showAddRoomDialog(context, state.selectedHomeId!);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.grey.shade600,
                            size: 24,
                          ),
                          8.height,
                          Text(
                            'Add Room',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final room = state.rooms[index];
              return RoomCard(
                room: room,
                isSelected: state.selectedRoomId == room.roomId,
                onTap: () {
                  context.read<HomeCubit>().selectRoom(
                    state.selectedHomeId ?? 0,
                    room.roomId,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDevicesSection(BuildContext context, HomeState state) {
    if (state.status == HomeStatus.devicesLoaded && state.devices.isNotEmpty) {
      return Column(
        children: [
          // Device view toggle
          if (state.selectedHomeId != null && state.rooms.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsivePadding.horizontal / 2,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (state.selectedRoomId != null) {
                          // Show all home devices
                          context.read<HomeCubit>().loadAllHomeDevices(
                            state.selectedHomeId!,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: state.selectedRoomId == null
                              ? Colors.green
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'All Devices',
                          style: TextStyle(
                            color: state.selectedRoomId == null
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 14 * context.responsiveFontMultiplier,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  8.width,
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (state.selectedRoomId == null &&
                            state.rooms.isNotEmpty) {
                          // Show room devices (select first room)
                          context.read<HomeCubit>().selectRoom(
                            state.selectedHomeId!,
                            state.rooms.first.roomId,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: state.selectedRoomId != null
                              ? Colors.green
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Room Devices',
                          style: TextStyle(
                            color: state.selectedRoomId != null
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 14 * context.responsiveFontMultiplier,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Devices grid
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsivePadding.horizontal / 2,
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.isMobile
                      ? 2
                      : context.isTablet
                      ? 3
                      : 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: state.devices.length,
                itemBuilder: (context, index) {
                  final device = state.devices[index];
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
              ),
            ),
          ),
        ],
      );
    } else if (state.selectedHomeId != null && state.selectedRoomId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.room_outlined,
              size: context.isMobile
                  ? 48
                  : context.isTablet
                  ? 56
                  : 64,
              color: Colors.grey.shade400,
            ),
            (context.isMobile ? 16 : 20).height,
            Text(
              'Select a room to view devices',
              style: TextStyle(
                fontSize: 16 * context.responsiveFontMultiplier,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            (context.isMobile ? 8 : 12).height,
            Text(
              'Choose a room from the list above to see its devices',
              style: TextStyle(
                fontSize: 14 * context.responsiveFontMultiplier,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else if (state.selectedHomeId != null &&
        state.selectedRoomId != null &&
        state.devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices_other_outlined,
              size: context.isMobile
                  ? 48
                  : context.isTablet
                  ? 56
                  : 64,
              color: Colors.grey.shade400,
            ),
            (context.isMobile ? 16 : 20).height,
            Text(
              'No devices in this room',
              style: TextStyle(
                fontSize: 16 * context.responsiveFontMultiplier,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            (context.isMobile ? 8 : 12).height,
            Text(
              'This room doesn\'t have any devices yet',
              style: TextStyle(
                fontSize: 14 * context.responsiveFontMultiplier,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else if (state.selectedHomeId != null &&
        state.status == HomeStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: context.isMobile
                  ? 64
                  : context.isTablet
                  ? 72
                  : 80,
              color: Colors.grey.shade400,
            ),
            (context.isMobile ? 16 : 20).height,
            Text(
              'Select a home to view devices',
              style: TextStyle(
                fontSize: 16 * context.responsiveFontMultiplier,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final navHeight = context.isMobile
            ? 80.0
            : context.isTablet
            ? 90.0
            : 100.0;
        final centerButtonSize = context.isMobile
            ? 60.0
            : context.isTablet
            ? 70.0
            : 80.0;

        return Container(
          height: navHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                Icons.home,
                'Home',
                state.selectedBottomNavIndex == 0,
                onTap: () => context.read<HomeCubit>().selectBottomNavIndex(0),
              ),
              _buildNavItem(
                context,
                Icons.favorite,
                'Favorites',
                state.selectedBottomNavIndex == 1,
                onTap: () => context.read<HomeCubit>().selectBottomNavIndex(1),
              ),
              _buildNavItem(
                context,
                Icons.graphic_eq,
                '',
                false,
                isCenter: true,
                centerButtonSize: centerButtonSize,
              ),
              _buildNavItem(
                context,
                Icons.grid_view,
                'Scene',
                state.selectedBottomNavIndex == 3,
                onTap: () => context.read<HomeCubit>().selectBottomNavIndex(3),
              ),
              _buildNavItem(
                context,
                Icons.person,
                'Me',
                state.selectedBottomNavIndex == 4,
                onTap: () => context.read<HomeCubit>().selectBottomNavIndex(4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isSelected, {
    bool isCenter = false,
    double? centerButtonSize,
    VoidCallback? onTap,
  }) {
    if (isCenter) {
      final size =
          centerButtonSize ??
          (context.isMobile
              ? 60.0
              : context.isTablet
              ? 70.0
              : 80.0);
      final iconSize = context.isMobile
          ? 24.0
          : context.isTablet
          ? 28.0
          : 32.0;

      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      );
    }

    final iconSize = context.isMobile
        ? 24.0
        : context.isTablet
        ? 28.0
        : 32.0;
    final fontSize = context.isMobile
        ? 12.0
        : context.isTablet
        ? 14.0
        : 16.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.green : Colors.grey,
            size: iconSize,
          ),
          4.height,
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: isSelected ? Colors.green : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeSelector(BuildContext context, HomeState state) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsivePadding.horizontal / 2,
        vertical: context.isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(context.isMobile ? 12 : 16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value:
              state.selectedHomeId ??
              (state.homes.isNotEmpty ? state.homes.first.homeId : null),
          hint: Text(
            'Home 1',
            style: TextStyle(
              fontSize: 16 * context.responsiveFontMultiplier,
              fontWeight: FontWeight.w500,
            ),
          ),
          items: state.homes
              .map(
                (HomeEntity h) => DropdownMenuItem<int>(
                  value: h.homeId,
                  child: Text(
                    h.name,
                    style: TextStyle(
                      fontSize: 16 * context.responsiveFontMultiplier,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<HomeCubit>().loadRooms(value);
              // Also load all home devices by default
              context.read<HomeCubit>().loadAllHomeDevices(value);
            }
          },
        ),
      ),
    );
  }

  void _showAddHouseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final geoNameController = TextEditingController();
    final lonController = TextEditingController();
    final latController = TextEditingController();
    final roomNamesController = TextEditingController();

    // Default room names
    final defaultRooms = [
      'Living Room',
      'Kitchen',
      'Bedroom',
      'Bathroom',
      'Garage',
      'Garden',
    ];

    List<String> selectedRooms = List.from(defaultRooms);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add New House',
                style: TextStyle(
                  fontSize: 20 * context.responsiveFontMultiplier,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // House Name
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'House Name *',
                        border: OutlineInputBorder(),
                        hintText: 'Enter house name',
                        prefixIcon: Icon(Icons.home),
                      ),
                    ),
                    16.height,

                    // Location Section
                    Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16 * context.responsiveFontMultiplier,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    8.height,
                    TextField(
                      controller: geoNameController,
                      decoration: const InputDecoration(
                        labelText: 'Address (Optional)',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., 123 Main St, New York, NY',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    12.height,

                    // Coordinates Section
                    Text(
                      'Coordinates',
                      style: TextStyle(
                        fontSize: 16 * context.responsiveFontMultiplier,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    8.height,
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lonController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder(),
                              hintText: '-74.006',
                              prefixIcon: Icon(Icons.east),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        12.width,
                        Expanded(
                          child: TextField(
                            controller: latController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder(),
                              hintText: '40.7128',
                              prefixIcon: Icon(Icons.north),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    8.height,

                    // Location picker button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showLocationPicker(
                            context,
                            lonController,
                            latController,
                            geoNameController,
                          );
                        },
                        icon: const Icon(Icons.my_location),
                        label: const Text('Pick Location'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    16.height,

                    // Rooms Section
                    Text(
                      'Default Rooms',
                      style: TextStyle(
                        fontSize: 16 * context.responsiveFontMultiplier,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    8.height,

                    // Room selection chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: defaultRooms.map((room) {
                        final isSelected = selectedRooms.contains(room);
                        return FilterChip(
                          label: Text(room),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedRooms.add(room);
                              } else {
                                selectedRooms.remove(room);
                              }
                            });
                          },
                          selectedColor: Colors.green.shade100,
                          checkmarkColor: Colors.green.shade700,
                        );
                      }).toList(),
                    ),
                    12.height,

                    // Custom room input
                    TextField(
                      controller: roomNamesController,
                      decoration: const InputDecoration(
                        labelText: 'Add Custom Room',
                        border: OutlineInputBorder(),
                        hintText: 'Enter room name and press Enter',
                        prefixIcon: Icon(Icons.room),
                        suffixIcon: Icon(Icons.add),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty &&
                            !selectedRooms.contains(value.trim())) {
                          setState(() {
                            selectedRooms.add(value.trim());
                            roomNamesController.clear();
                          });
                        }
                      },
                    ),
                    8.height,

                    // Selected rooms display
                    if (selectedRooms.isNotEmpty) ...[
                      Text(
                        'Selected Rooms (${selectedRooms.length})',
                        style: TextStyle(
                          fontSize: 14 * context.responsiveFontMultiplier,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      4.height,
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          selectedRooms.join(', '),
                          style: TextStyle(
                            fontSize: 12 * context.responsiveFontMultiplier,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      final name = nameController.text.trim();
                      final geoName = geoNameController.text.trim().isEmpty
                          ? null
                          : geoNameController.text.trim();
                      final lon = double.tryParse(lonController.text.trim());
                      final lat = double.tryParse(latController.text.trim());

                      context.read<HomeCubit>().addHouse(
                        name: name,
                        geoName: geoName,
                        lon: lon,
                        lat: lat,
                        roomNames: selectedRooms,
                      );

                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create House'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddRoomDialog(BuildContext context, int homeId) {
    final nameController = TextEditingController();
    final iconUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add New Room',
            style: TextStyle(
              fontSize: 20 * context.responsiveFontMultiplier,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Room Name *',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Living Room, Kitchen',
                  ),
                ),
                16.height,
                TextField(
                  controller: iconUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Icon URL (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/icon.png',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final name = nameController.text.trim();
                  final iconUrl = iconUrlController.text.trim().isEmpty
                      ? null
                      : iconUrlController.text.trim();

                  context.read<HomeCubit>().addRoom(
                    homeId: homeId,
                    name: name,
                    iconUrl: iconUrl,
                  );

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Room'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationPicker(
    BuildContext context,
    TextEditingController lonController,
    TextEditingController latController,
    TextEditingController geoNameController,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Pick Location',
            style: TextStyle(
              fontSize: 18 * context.responsiveFontMultiplier,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.my_location, color: Colors.blue),
                title: const Text('Use Current Location'),
                subtitle: const Text('Get your current GPS coordinates'),
                onTap: () {
                  _getCurrentLocation(
                    lonController,
                    latController,
                    geoNameController,
                  );
                  Navigator.of(context).pop();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.map, color: Colors.green),
                title: const Text('Search Location'),
                subtitle: const Text('Search for a specific address'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showLocationSearchDialog(
                    context,
                    lonController,
                    latController,
                    geoNameController,
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit_location, color: Colors.orange),
                title: const Text('Manual Entry'),
                subtitle: const Text('Enter coordinates manually'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showManualLocationDialog(
                    context,
                    lonController,
                    latController,
                    geoNameController,
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _getCurrentLocation(
    TextEditingController lonController,
    TextEditingController latController,
    TextEditingController geoNameController,
  ) {
    // For now, we'll use a mock location
    // In a real app, you would use geolocator package
    lonController.text = '-74.0060';
    latController.text = '40.7128';
    geoNameController.text = 'New York, NY, USA';

    // Show a snackbar or dialog to inform user
    // You can implement actual GPS location here using geolocator package
  }

  void _showLocationSearchDialog(
    BuildContext context,
    TextEditingController lonController,
    TextEditingController latController,
    TextEditingController geoNameController,
  ) {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Search Location',
            style: TextStyle(
              fontSize: 18 * context.responsiveFontMultiplier,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Search for location',
                  hintText: 'e.g., Times Square, New York',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              16.height,
              // Mock search results
              Container(
                height: 200,
                child: ListView(
                  children: [
                    _buildLocationResult(
                      context,
                      'Times Square, New York, NY',
                      '-73.9857',
                      '40.7580',
                      searchController,
                      lonController,
                      latController,
                      geoNameController,
                    ),
                    _buildLocationResult(
                      context,
                      'Central Park, New York, NY',
                      '-73.9654',
                      '40.7829',
                      searchController,
                      lonController,
                      latController,
                      geoNameController,
                    ),
                    _buildLocationResult(
                      context,
                      'Brooklyn Bridge, New York, NY',
                      '-73.9969',
                      '40.7061',
                      searchController,
                      lonController,
                      latController,
                      geoNameController,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationResult(
    BuildContext context,
    String name,
    String lon,
    String lat,
    TextEditingController searchController,
    TextEditingController lonController,
    TextEditingController latController,
    TextEditingController geoNameController,
  ) {
    return ListTile(
      leading: const Icon(Icons.location_on, color: Colors.red),
      title: Text(name),
      subtitle: Text('Lat: $lat, Lon: $lon'),
      onTap: () {
        lonController.text = lon;
        latController.text = lat;
        geoNameController.text = name;
        Navigator.of(context).pop();
      },
    );
  }

  void _showManualLocationDialog(
    BuildContext context,
    TextEditingController lonController,
    TextEditingController latController,
    TextEditingController geoNameController,
  ) {
    final manualLonController = TextEditingController(text: lonController.text);
    final manualLatController = TextEditingController(text: latController.text);
    final manualGeoController = TextEditingController(
      text: geoNameController.text,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Manual Location Entry',
            style: TextStyle(
              fontSize: 18 * context.responsiveFontMultiplier,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: manualGeoController,
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                  hintText: 'e.g., My Home',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              12.height,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: manualLonController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: '-74.006',
                        prefixIcon: Icon(Icons.east),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: TextField(
                      controller: manualLatController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: '40.7128',
                        prefixIcon: Icon(Icons.north),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                lonController.text = manualLonController.text;
                latController.text = manualLatController.text;
                geoNameController.text = manualGeoController.text;
                Navigator.of(context).pop();
              },
              child: const Text('Set Location'),
            ),
          ],
        );
      },
    );
  }
}
