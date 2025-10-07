import 'package:flutter/material.dart';
import 'package:tuya_app/src/core/utils/constants.dart';
import 'package:tuya_app/src/features/device_pairing/presentation/view/widgets/device_pairing_wrapper.dart';
import 'package:tuya_app/src/features/home/presentation/view/screens/device_control_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Modern Home Screen - Displays user's devices with beautiful UI
/// Based on stable app structure but with better Flutter UI/UX
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = true;
  String _error = '';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadDevices();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final result = await AppConstants.channel.invokeMethod('getDeviceList');
      final deviceList = result['devices'] as List<dynamic>;

      setState(() {
        _devices = deviceList
            .map((d) => Map<String, dynamic>.from(d as Map))
            .toList();
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = 'Failed to load devices: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern App Bar
              _buildAppBar(),

              // Status Overview
              _buildStatusOverview(),

              // Devices Grid/List
              Expanded(child: _buildDevicesList()),
            ],
          ),
        ),
      ),

      // Floating Action Button for adding devices
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddDevice,
        icon: const Icon(Icons.add),
        label: const Text('Add Device'),
        elevation: 4,
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Logo/Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Home',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Welcome back!',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Refresh Button
          IconButton(
            onPressed: _loadDevices,
            icon: Icon(Icons.refresh, color: Colors.blue.shade700),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOverview() {
    final onlineCount = _devices.where((d) => d['isOnline'] == true).length;
    final totalCount = _devices.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Online Devices
          Expanded(
            child: _buildStatCard(
              icon: Icons.devices,
              label: 'Online',
              value: '$onlineCount',
              color: Colors.white,
            ),
          ),

          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),

          // Total Devices
          Expanded(
            child: _buildStatCard(
              icon: Icons.grid_view,
              label: 'Total',
              value: '$totalCount',
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildDevicesList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your devices...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDevices,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_devices.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadDevices,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          return FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.3, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        index / _devices.length,
                        1.0,
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
              child: _buildDeviceCard(_devices[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> device) {
    final isOnline = device['isOnline'] == true;
    final deviceName = device['name'] as String? ?? 'Unknown Device';
    final deviceId = device['id'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _onDeviceTap(device),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Device Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isOnline ? Colors.blue.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDeviceIcon(device['category'] as String?),
                  color: isOnline ? Colors.blue.shade700 : Colors.grey.shade400,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // Device Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOnline
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.devices_other, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'No Devices Yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first smart device to get started',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToAddDevice,
            icon: const Icon(Icons.add),
            label: const Text('Add Device'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue.shade700,
      unselectedItemColor: Colors.grey.shade400,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.scatter_plot),
          label: 'Scenes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome),
          label: 'Automation',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      onTap: (index) {
        if (index != 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${['Home', 'Scenes', 'Automation', 'Profile'][index]} - Coming Soon!',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }

  IconData _getDeviceIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'light':
      case 'dj':
        return Icons.lightbulb;
      case 'switch':
      case 'kg':
        return Icons.power_settings_new;
      case 'socket':
      case 'cz':
        return Icons.electrical_services;
      case 'curtain':
      case 'cl':
        return Icons.curtains;
      case 'fan':
      case 'fs':
        return Icons.air;
      case 'sensor':
      case 'pir':
        return Icons.sensors;
      case 'lock':
      case 'ms':
        return Icons.lock;
      case 'camera':
      case 'sp':
        return Icons.videocam;
      default:
        return Icons.devices;
    }
  }

  void _onDeviceTap(Map<String, dynamic> device) {
    // Navigate to device control screen
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => DeviceControlScreen(device: device),
          ),
        )
        .then((_) {
          // Reload devices after returning from control screen
          _loadDevices();
        });
  }

  void _navigateToAddDevice() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const DevicePairingWrapper()))
        .then((_) {
          // Reload devices after coming back
          _loadDevices();
        });
  }
}
