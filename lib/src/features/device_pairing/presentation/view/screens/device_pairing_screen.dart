import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_app/src/features/device_pairing/presentation/manager/cubit/device_pairing_cubit.dart';
import 'package:tuya_app/src/features/device_pairing/presentation/view/screens/wifi_network_list_screen.dart';

/// Main Device Pairing Screen
/// Entry point for adding new devices with beautiful modern UI
class DevicePairingScreen extends StatefulWidget {
  const DevicePairingScreen({super.key});

  @override
  State<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends State<DevicePairingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Start device pairing initialization
    context.read<DevicePairingCubit>().startDevicePairing();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Expanded(
                        child: Text(
                          'Add New Device',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hero Section
                Expanded(
                  child: BlocConsumer<DevicePairingCubit, DevicePairingState>(
                    listener: (context, state) {
                      if (state is DevicePairingError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is DevicePairingLoading) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Preparing device pairing...'),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            // Hero Icon
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_circle_outline,
                                size: 80,
                                color: Colors.blue.shade700,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Title
                            const Text(
                              'Choose Pairing Method',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Select how you want to add your device',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 48),

                            // WiFi Pairing Option (Recommended)
                            _buildPairingMethodCard(
                              context: context,
                              icon: Icons.wifi,
                              iconColor: Colors.blue,
                              title: 'WiFi Pairing',
                              subtitle: 'Most common for smart home devices',
                              badge: 'RECOMMENDED',
                              badgeColor: Colors.green,
                              onTap: () => _navigateToWiFiPairing(context),
                            ),

                            const SizedBox(height: 16),

                            // QR Code Pairing Option (Coming Soon)
                            _buildPairingMethodCard(
                              context: context,
                              icon: Icons.qr_code_scanner,
                              iconColor: Colors.purple,
                              title: 'QR Code Scanning',
                              subtitle: 'Scan device QR code for quick setup',
                              badge: 'COMING SOON',
                              badgeColor: Colors.orange,
                              onTap: () => _showComingSoonDialog(context),
                              enabled: false,
                            ),

                            const SizedBox(height: 16),

                            // Bluetooth Pairing Option (Coming Soon)
                            _buildPairingMethodCard(
                              context: context,
                              icon: Icons.bluetooth,
                              iconColor: Colors.indigo,
                              title: 'Bluetooth Pairing',
                              subtitle: 'For Bluetooth-enabled devices',
                              badge: 'COMING SOON',
                              badgeColor: Colors.orange,
                              onTap: () => _showComingSoonDialog(context),
                              enabled: false,
                            ),

                            const SizedBox(height: 32),

                            // Help section
                            Card(
                              color: Colors.amber.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.help_outline,
                                      color: Colors.amber.shade700,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Need Help?',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber.shade900,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Make sure your device is powered on and in pairing mode',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.amber.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPairingMethodCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Card(
      elevation: enabled ? 4 : 1,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: enabled
                      ? iconColor.withOpacity(0.1)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: enabled ? iconColor : Colors.grey,
                ),
              ),

              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: enabled ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        if (badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: enabled ? Colors.grey.shade600 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToWiFiPairing(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DevicePairingCubit>(),
          child: const WiFiNetworkListScreen(),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Coming Soon'),
          ],
        ),
        content: const Text(
          'This pairing method will be available in a future update. '
          'For now, please use WiFi pairing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
