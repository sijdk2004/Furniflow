import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/users_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class UserViewScreen extends ConsumerWidget {
  final String id;
  const UserViewScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailsProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: () => context.go('/users/edit/$id'),
              icon: const Icon(LucideIcons.edit2, size: 18),
              label: const Text('Edit'),
            ),
          )
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${user.firstName} ${user.lastName ?? ''}', style: Theme.of(context).textTheme.headlineSmall),
                              Text(user.email, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(user.isActive ? 'Active' : 'Inactive'),
                          backgroundColor: user.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: user.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text('Account Information', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildInfoRow('Username', user.username),
                    const SizedBox(height: 16),
                    _buildInfoRow('First Name', user.firstName),
                    const SizedBox(height: 16),
                    _buildInfoRow('Last Name', user.lastName ?? '-'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}
