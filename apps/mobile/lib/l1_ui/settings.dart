import 'package:flutter/material.dart';
import '../l3_service/seed_data_service.dart';
import '../l3_service/workout_service.dart';
import '../l3_service/settings_service.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onNavigateToDashboard;

  const SettingsPage({super.key, required this.onNavigateToDashboard});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoadingMockData = false;
  bool _isClearingData = false;
  String _weightUnit = 'kg';
  String _distanceUnit = 'km';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final settings = await SettingsService.getInstance();
    setState(() {
      _weightUnit = settings.weightUnit;
      _distanceUnit = settings.distanceUnit;
    });
  }

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
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to dashboard after success
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        widget.onNavigateToDashboard();
      }
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

  Future<void> _clearAllData() async {
    final workoutService = WorkoutService();
    final workoutCount = workoutService.workoutCount;

    // Check if there's any data to clear
    if (workoutCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('ℹ️ No workout data to clear'),
          backgroundColor: Colors.blue[700],
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // First confirmation dialog
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Delete All Workouts?', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'You have $workoutCount workout${workoutCount == 1 ? '' : 's'}. This action cannot be undone.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );

    if (firstConfirm != true || !mounted) return;

    // Second confirmation dialog with text input
    final textController = TextEditingController();
    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Final Warning', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type DELETE to confirm deletion of $workoutCount workout${workoutCount == 1 ? '' : 's'}:',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'DELETE',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim() == 'DELETE') {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please type DELETE to confirm'),
                    backgroundColor: Colors.red[700],
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (secondConfirm != true || !mounted) return;

    // Perform the clear operation
    setState(() {
      _isClearingData = true;
    });

    try {
      await workoutService.clearAll();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Deleted $workoutCount workout${workoutCount == 1 ? '' : 's'}',
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to dashboard after success
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        widget.onNavigateToDashboard();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to clear data: $e'),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isClearingData = false;
        });
      }
    }
  }

  Future<void> _showUnitsDialog() async {
    String selectedWeightUnit = _weightUnit;
    String selectedDistanceUnit = _distanceUnit;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Unit Preferences',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weight Section
              const Text(
                'Weight',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'kg',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: 'kg',
                      groupValue: selectedWeightUnit,
                      activeColor: Colors.white,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedWeightUnit = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'lbs',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: 'lbs',
                      groupValue: selectedWeightUnit,
                      activeColor: Colors.white,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedWeightUnit = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Distance Section
              const Text(
                'Distance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'km',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: 'km',
                      groupValue: selectedDistanceUnit,
                      activeColor: Colors.white,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedDistanceUnit = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(
                        'miles',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: 'miles',
                      groupValue: selectedDistanceUnit,
                      activeColor: Colors.white,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedDistanceUnit = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final settings = await SettingsService.getInstance();
      await settings.setWeightUnit(selectedWeightUnit);
      await settings.setDistanceUnit(selectedDistanceUnit);

      setState(() {
        _weightUnit = selectedWeightUnit;
        _distanceUnit = selectedDistanceUnit;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Unit preferences updated'),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );
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
              title: 'Units',
              subtitle: 'Weight: $_weightUnit • Distance: $_distanceUnit',
              onTap: () => _showUnitsDialog(),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white70,
                        ),
                      ),
                    )
                  : null,
            ),
            _buildSettingsTile(
              icon: Icons.delete_outline,
              title: 'Clear Data',
              subtitle: 'Delete all workout logs',
              onTap: _isClearingData ? () {} : () => _clearAllData(),
              trailing: _isClearingData
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    )
                  : const Icon(
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
