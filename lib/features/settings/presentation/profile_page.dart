import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../auth/service/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: user == null
          ? const Center(child: Text('No user information available'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Avatar
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Email
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.email,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Email'),
                    subtitle: Text(user.email),
                  ),
                ),
                const SizedBox(height: 8),

                // User ID
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.fingerprint,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('User ID'),
                    subtitle: Text(
                      user.id,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Account Created
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Account Created'),
                    subtitle: Text(
                      DateFormat('MMMM dd, yyyy').format(user.createdAt),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Last Login
                if (user.lastLoginAt != null)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.login,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: const Text('Last Login'),
                      subtitle: Text(
                        DateFormat('MMMM dd, yyyy - hh:mm a')
                            .format(user.lastLoginAt!),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Sync Data Button
                FilledButton.icon(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Syncing data...')),
                    );

                    final success = await authProvider.syncData();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Data synced successfully'
                                : 'Sync failed. Please try again.',
                          ),
                          backgroundColor: success
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Data'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
    );
  }
}
