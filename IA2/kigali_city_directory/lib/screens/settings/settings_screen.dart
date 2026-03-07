import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../listings/my_listings_screen.dart';
import '../map/map_view_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _amber = Color(0xFFD4A84B);
  static const _cardColor = Color(0xFF1E2A3A);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final profile = authProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _amber.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, size: 40, color: _amber),
                ),
                const SizedBox(height: 12),
                Text(
                  profile?.displayName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      user?.emailVerified == true
                          ? Icons.verified
                          : Icons.warning,
                      size: 16,
                      color: user?.emailVerified == true
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user?.emailVerified == true
                          ? 'Email Verified'
                          : 'Email Not Verified',
                      style: TextStyle(
                        fontSize: 12,
                        color: user?.emailVerified == true
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Quick access
          const Text(
            'Quick Access',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.list_alt, color: _amber),
                  title: const Text('My Listings',
                      style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right,
                      color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyListingsScreen()),
                    );
                  },
                ),
                Divider(height: 1, color: Colors.grey[800]),
                ListTile(
                  leading: const Icon(Icons.map, color: _amber),
                  title: const Text('Map View',
                      style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.chevron_right,
                      color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MapViewScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Preferences
          const Text(
            'Preferences',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Location Notifications',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(
                'Get notified about nearby services',
                style: TextStyle(color: Colors.grey[500]),
              ),
              value: profile?.notificationsEnabled ?? true,
              onChanged: (value) {
                authProvider.updateNotificationPreference(value);
              },
              activeColor: _amber,
              secondary:
                  const Icon(Icons.notifications_outlined, color: _amber),
            ),
          ),
          const SizedBox(height: 24),
          // Account
          const Text(
            'Account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.info_outline, color: Colors.grey),
                  title: const Text('App Version',
                      style: TextStyle(color: Colors.white)),
                  trailing: Text('1.0.0',
                      style: TextStyle(color: Colors.grey[500])),
                ),
                Divider(height: 1, color: Colors.grey[800]),
                ListTile(
                  leading:
                      const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: _cardColor,
                        title: const Text('Sign Out',
                            style: TextStyle(color: Colors.white)),
                        content: const Text(
                          'Are you sure you want to sign out?',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('Cancel',
                                style:
                                    TextStyle(color: Colors.grey[400])),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              authProvider.signOut();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                            ),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
