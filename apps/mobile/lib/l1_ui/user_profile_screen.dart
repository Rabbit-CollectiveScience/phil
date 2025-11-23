import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l3_service/device_info_service.dart';
import '../config.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  DeviceInformation? _deviceInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final info = await DeviceInfoService.getDeviceInfo();
      setState(() {
        _deviceInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3A3A3A),
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('User Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Guest Mode Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[800]!, width: 1),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_outline,
                              size: 48,
                              color: Colors.blue[300],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Guest Mode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your data is stored locally on this device',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Device Information Section
                    Text(
                      'Device Information',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Device ID
                    _buildInfoTile(
                      icon: Icons.fingerprint,
                      label: 'Device ID',
                      value: _deviceInfo?.deviceId ?? 'Unknown',
                      onTap: () => _copyToClipboard(
                        _deviceInfo?.deviceId ?? '',
                        'Device ID',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Platform
                    _buildInfoTile(
                      icon: Icons.phone_iphone,
                      label: 'Platform',
                      value:
                          '${_deviceInfo?.platform ?? 'Unknown'} ${_deviceInfo?.osVersion ?? ''}',
                      onTap: () => _copyToClipboard(
                        '${_deviceInfo?.platform ?? ''} ${_deviceInfo?.osVersion ?? ''}',
                        'Platform',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Device Model
                    _buildInfoTile(
                      icon: Icons.devices,
                      label: 'Device Model',
                      value: _deviceInfo?.model ?? 'Unknown',
                      onTap: () => _copyToClipboard(
                        _deviceInfo?.model ?? '',
                        'Device Model',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // App Version
                    _buildInfoTile(
                      icon: Icons.info_outline,
                      label: 'App Version',
                      value: Config.appVersion,
                      onTap: () =>
                          _copyToClipboard(Config.appVersion, 'App Version'),
                    ),

                    const SizedBox(height: 32),

                    // Future Sign In Section (Placeholder)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[800]!, width: 1),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_outlined,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sign In Coming Soon',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create an account to sync your workouts across devices',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[400], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.copy, color: Colors.grey[600], size: 20),
          ],
        ),
      ),
    );
  }
}
