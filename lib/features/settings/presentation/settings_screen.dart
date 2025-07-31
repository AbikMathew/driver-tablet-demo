import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.person,
                title: 'Profile',
                subtitle: 'Edit your profile information',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.security,
                title: 'Security',
                subtitle: 'Change password and security settings',
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'App Preferences',
            children: [
              _SettingsTile(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.volume_up,
                title: 'Audio & TTS',
                subtitle: 'Configure text-to-speech settings',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.map,
                title: 'Map Settings',
                subtitle: 'Offline maps and route preferences',
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'Data & Sync',
            children: [
              _SettingsTile(
                icon: Icons.sync,
                title: 'Data Sync',
                subtitle: 'Manage offline data synchronization',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.storage,
                title: 'Storage',
                subtitle: 'Manage app storage and cache',
                onTap: () {},
              ),
            ],
          ),
          _SettingsSection(
            title: 'Support',
            children: [
              _SettingsTile(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement logout
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
