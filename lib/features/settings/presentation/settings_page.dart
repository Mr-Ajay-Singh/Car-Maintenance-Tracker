import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/service/auth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Section
          if (authProvider.currentUser != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        authProvider.currentUser?.email ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const Divider(),
          const SizedBox(height: 8),

          // Settings Menu
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/profile'),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/preferences'),
          ),

          const Divider(),
          const SizedBox(height: 8),

          // Data Section
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Download your maintenance records'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/export'),
          ),

          const Divider(),
          const SizedBox(height: 8),

          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings/about'),
          ),

          const SizedBox(height: 24),

          // Sign Out Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final shouldSignOut = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out'),
                    content:
                        const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );

                if (shouldSignOut == true && context.mounted) {
                  await authProvider.signOut();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Theme.of(context).colorScheme.error,
                side: BorderSide(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
