import 'package:flutter/material.dart';
import '../l3_service/seed_data_service.dart';
import '../l3_service/workout_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoadingMockData = false;

  Future<void> _addMockData() async {
    setState(() {
      _isLoadingMockData = true;
    });

    try {
      final workoutService = WorkoutService();
      final seedService = SeedDataService(workoutService);
      final result = await seedService.loadMockData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Added ${result.added} workouts, skipped ${result.skipped} duplicates',
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to load mock data: $e'),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMockData = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // Account Section
            _buildSectionHeader('Account'),
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'User Profile',
              subtitle: 'Guest mode • Device ID: ...',
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // Preferences Section
            _buildSectionHeader('Preferences'),
            _buildSettingsTile(
              icon: Icons.straighten,
              title: 'Metric Preference',
              subtitle: 'Weight: lbs • Distance: miles',
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // Data Section
            _buildSectionHeader('Data'),
            _buildSettingsTile(
              icon: Icons.download_outlined,
              title: 'Export Data',
              subtitle: 'Download your workout history',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.science_outlined,
              title: 'Add Mock Data',
              subtitle: 'Load sample workouts for testing',
              onTap: _isLoadingMockData ? () {} : () => _addMockData(),
              trailing: _isLoadingMockData
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    )
                  : null,
            ),
            _buildSettingsTile(
              icon: Icons.delete_outline,
              title: 'Clear Data',
              subtitle: 'Delete all workout logs',
              onTap: () {},
              trailing: const Icon(
                Icons.warning_amber,
                color: Colors.orange,
                size: 20,
              ),
            ),

            const SizedBox(height: 20),

            // About Section
            _buildSectionHeader('About'),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'About Phil',
              subtitle: 'Version 3.0.4',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'View terms and conditions',
              onTap: () {},
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing:
            trailing ?? const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}
