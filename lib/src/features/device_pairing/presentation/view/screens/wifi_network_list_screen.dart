import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuya_app/src/features/device_pairing/presentation/manager/cubit/device_pairing_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// WiFi Network List Screen
/// Shows available WiFi networks for device pairing
class WiFiNetworkListScreen extends StatefulWidget {
  const WiFiNetworkListScreen({super.key});

  @override
  State<WiFiNetworkListScreen> createState() => _WiFiNetworkListScreenState();
}

class _WiFiNetworkListScreenState extends State<WiFiNetworkListScreen> {
  final _networkInfo = NetworkInfo();
  String? _currentSSID;
  bool _isLoadingPermissions = false;
  List<String> _availableNetworks = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadNetworks();
  }

  Future<void> _checkPermissionsAndLoadNetworks() async {
    setState(() => _isLoadingPermissions = true);

    // Request location permission (required for WiFi scanning on Android)
    final locationStatus = await Permission.location.request();

    if (locationStatus.isGranted) {
      await _loadCurrentNetwork();
      await _loadAvailableNetworks();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission required to scan WiFi networks'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }

    setState(() => _isLoadingPermissions = false);
  }

  Future<void> _loadCurrentNetwork() async {
    try {
      final wifiSSID = await _networkInfo.getWifiName();
      setState(() {
        // Remove quotes from SSID if present
        _currentSSID = wifiSSID?.replaceAll('"', '');
      });
    } catch (e) {
      debugPrint('Error getting WiFi SSID: $e');
    }
  }

  Future<void> _loadAvailableNetworks() async {
    // Note: Android/iOS don't provide a direct API to scan WiFi networks
    // We can only get the currently connected network
    // This is a limitation of both platforms for security/privacy reasons

    // For demo purposes, we'll show the current network and some mock networks
    // In a real app, you'd need to:
    // 1. Use platform channels to access native WiFi scanning APIs
    // 2. Or rely on the user manually entering the SSID

    final currentNetwork = _currentSSID;
    setState(() {
      _availableNetworks = [
        if (currentNetwork != null) currentNetwork,
        // In production, these would come from native platform code
      ];
    });
  }

  void _showPasswordDialog(String ssid) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Connect to $ssid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter WiFi Password:'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'WiFi Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final password = passwordController.text.trim();
              if (password.isNotEmpty) {
                Navigator.of(dialogContext).pop();
                _startWiFiPairing(ssid, password);
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a password'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _showManualSSIDDialog() {
    final ssidController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter Network Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ssidController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Network Name (SSID)',
                prefixIcon: Icon(Icons.wifi),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final ssid = ssidController.text.trim();
              final password = passwordController.text.trim();
              if (ssid.isNotEmpty && password.isNotEmpty) {
                Navigator.of(dialogContext).pop();
                _startWiFiPairing(ssid, password);
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _startWiFiPairing(String ssid, String password) {
    // Navigate to pairing progress screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<DevicePairingCubit>(),
          child: WiFiPairingProgressScreen(ssid: ssid, password: password),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select WiFi Network'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPermissionsAndLoadNetworks,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoadingPermissions
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Current network banner
                if (_currentSSID != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue.shade50,
                    child: Row(
                      children: [
                        Icon(Icons.wifi, color: Colors.blue.shade700, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Current Network',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _currentSSID!,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _showPasswordDialog(_currentSSID!),
                          child: const Text('Use This'),
                        ),
                      ],
                    ),
                  ),

                // Manual entry option
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.edit, color: Colors.blue),
                      title: const Text('Enter Network Manually'),
                      subtitle: const Text('If your network is hidden'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _showManualSSIDDialog,
                    ),
                  ),
                ),

                // Available networks (currently only shows current network)
                Expanded(
                  child: _availableNetworks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No networks detected',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Please enter network manually',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _availableNetworks.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final network = _availableNetworks[index];
                            final isCurrent = network == _currentSSID;

                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  isCurrent ? Icons.wifi : Icons.wifi_outlined,
                                  color: isCurrent ? Colors.blue : Colors.grey,
                                ),
                                title: Text(network),
                                subtitle: isCurrent
                                    ? const Text('Connected')
                                    : null,
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () => _showPasswordDialog(network),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

/// WiFi Pairing Progress Screen
/// Shows the progress of device pairing via WiFi
class WiFiPairingProgressScreen extends StatefulWidget {
  final String ssid;
  final String password;

  const WiFiPairingProgressScreen({
    super.key,
    required this.ssid,
    required this.password,
  });

  @override
  State<WiFiPairingProgressScreen> createState() =>
      _WiFiPairingProgressScreenState();
}

class _WiFiPairingProgressScreenState extends State<WiFiPairingProgressScreen> {
  @override
  void initState() {
    super.initState();
    _startPairing();
  }

  Future<void> _startPairing() async {
    // First, start device pairing to get the token
    context.read<DevicePairingCubit>().startDevicePairing();

    // Wait for the ready state to get token
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Get token from state or via method channel
    // For now, we'll pass an empty token and the backend will fetch it
    context.read<DevicePairingCubit>().startWifiPairing(
      ssid: widget.ssid,
      password: widget.password,
      token: '', // Token will be fetched by the backend
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pairing Device')),
      body: BlocConsumer<DevicePairingCubit, DevicePairingState>(
        listener: (context, state) {
          if (state is DevicePairingSuccess) {
            // Show success and navigate back
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Device paired: ${state.device?.name ?? "Unknown Device"}',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is DevicePairingError) {
            // Show error dialog
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Pairing Failed'),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated WiFi icon
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Icon(
                          Icons.wifi,
                          size: 120,
                          color: Colors.blue.withOpacity(0.5 + (0.5 * value)),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Progress indicator
                  const CircularProgressIndicator(),

                  const SizedBox(height: 24),

                  // Status text
                  Text(
                    state is DevicePairingLoading
                        ? 'Pairing device...'
                        : 'Preparing to pair',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Network info
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wifi, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Network',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      widget.ssid,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tips
                  const Text(
                    'Tips:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Keep your device close to the router\n'
                    '• Make sure the device is powered on\n'
                    '• Wait up to 2 minutes for pairing',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Cancel button
                  OutlinedButton(
                    onPressed: () {
                      context.read<DevicePairingCubit>().stopDevicePairing();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Cancel Pairing'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Stop pairing when leaving the screen
    context.read<DevicePairingCubit>().stopDevicePairing();
    super.dispose();
  }
}
