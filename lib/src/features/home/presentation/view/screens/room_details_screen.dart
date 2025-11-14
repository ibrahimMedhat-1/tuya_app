import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_app/src/core/helpers/responsive_extensions.dart';
import 'package:tuya_app/src/core/helpers/spacing_extensions.dart';
import 'package:tuya_app/src/features/home/domain/entities/device.dart';
import 'package:tuya_app/src/features/home/domain/entities/room.dart';
import 'package:tuya_app/src/features/home/presentation/manager/home_cubit.dart';
import 'package:tuya_app/src/features/home/presentation/view/widgets/device_card.dart';

class RoomDetailsScreen extends StatefulWidget {
  final RoomEntity room;
  final int homeId;
  final String homeName;

  const RoomDetailsScreen({
    super.key,
    required this.room,
    required this.homeId,
    required this.homeName,
  });

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load room devices when screen opens
    context.read<HomeCubit>().selectRoom(widget.homeId, widget.room.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.room.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // Rename room button
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () => _showRenameRoomDialog(context),
          ),
          // Delete room button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteRoomDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.status == HomeStatus.loading) {
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
                    onPressed: () => context
                        .read<HomeCubit>()
                        .selectRoom(widget.homeId, widget.room.roomId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final devices = state.devices;

          return Column(
            children: [
              // Room info card
              Container(
                margin: EdgeInsets.all(context.responsivePadding.horizontal),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.room,
                        color: Colors.green.shade700,
                        size: 32,
                      ),
                    ),
                    16.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.room.name,
                            style: TextStyle(
                              fontSize: 20 * context.responsiveFontMultiplier,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          4.height,
                          Text(
                            '${devices.length} device${devices.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 14 * context.responsiveFontMultiplier,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Add device button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsivePadding.horizontal,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddDeviceDialog(context, state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add Device to Room',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Devices grid
              Expanded(
                child: devices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.devices_other,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            16.height,
                            Text(
                              'No devices in this room',
                              style: TextStyle(
                                fontSize: 16 * context.responsiveFontMultiplier,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            8.height,
                            Text(
                              'Add devices to organize your smart home',
                              style: TextStyle(
                                fontSize: 14 * context.responsiveFontMultiplier,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(
                          context.responsivePadding.horizontal,
                        ),
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
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return _buildDeviceCardWithRemove(
                            context,
                            device,
                            state,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeviceCardWithRemove(
    BuildContext context,
    DeviceEntity device,
    HomeState state,
  ) {
    return Stack(
      children: [
        DeviceCard(
          device: device,
          homeId: widget.homeId,
          homeName: widget.homeName,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _showRemoveDeviceDialog(context, device),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Icon(
                Icons.close,
                color: Colors.red.shade700,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddDeviceDialog(BuildContext context, HomeState state) {
    // Get all home devices
    context.read<HomeCubit>().loadAllHomeDevices(widget.homeId);

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<HomeCubit>(),
        child: AlertDialog(
          title: const Text('Add Device to Room'),
          content: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.status == HomeStatus.loading) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Filter out devices already in this room
              final availableDevices = state.devices.where((device) {
                // Check if device is already in this room
                return state.selectedRoomId != widget.room.roomId;
              }).toList();

              if (availableDevices.isEmpty) {
                return const SizedBox(
                  height: 100,
                  child: Center(
                    child: Text('No available devices to add'),
                  ),
                );
              }

              return SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: availableDevices.length,
                  itemBuilder: (context, index) {
                    final device = availableDevices[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Icon(
                          Icons.devices,
                          color: Colors.green.shade700,
                        ),
                      ),
                      title: Text(device.name),
                      subtitle: Text(
                        device.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: device.isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _addDeviceToRoom(context, device.deviceId);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Reload room devices
                context
                    .read<HomeCubit>()
                    .selectRoom(widget.homeId, widget.room.roomId);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _addDeviceToRoom(BuildContext context, String deviceId) {
    context.read<HomeCubit>().addDeviceToRoom(
          homeId: widget.homeId,
          roomId: widget.room.roomId,
          deviceId: deviceId,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Device added to room'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showRemoveDeviceDialog(BuildContext context, DeviceEntity device) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Device'),
        content: Text('Remove "${device.name}" from this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<HomeCubit>().removeDeviceFromRoom(
                    homeId: widget.homeId,
                    roomId: widget.room.roomId,
                    deviceId: device.deviceId,
                  );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Device removed from room'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showRenameRoomDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.room.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Room'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Room Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(dialogContext).pop();
                context.read<HomeCubit>().updateRoomName(
                      homeId: widget.homeId,
                      roomId: widget.room.roomId,
                      name: controller.text.trim(),
                    );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Room renamed'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Update local name for immediate UI feedback
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showDeleteRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text(
          'Are you sure you want to delete "${widget.room.name}"?\n\nDevices in this room will not be deleted, just unassigned from the room.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<HomeCubit>().deleteRoom(
                    homeId: widget.homeId,
                    roomId: widget.room.roomId,
                  );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Room deleted'),
                  backgroundColor: Colors.red,
                ),
              );

              // Go back to home screen
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

