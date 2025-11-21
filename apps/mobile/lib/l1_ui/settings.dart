import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          
          // Account Section
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Manage your profile information',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.devices,
            title: 'Device ID',
            subtitle: 'Currently using guest mode',
            onTap: () {},
          ),
          
          const SizedBox(height: 20),
          
          // Preferences Section
          _buildSectionHeader('Preferences'),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.color_lens_outlined,
            title: 'Theme',
            subtitle: 'Dark',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
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
            icon: Icons.delete_outline,
            title: 'Clear Data',
            subtitle: 'Delete all workout logs',
            onTap: () {},
            trailing: const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
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
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}
