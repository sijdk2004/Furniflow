import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/roles_provider.dart';

class RoleAuditTab extends ConsumerWidget {
  final String roleId;
  const RoleAuditTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(roleAuditLogsProvider(roleId));

    return auditLogsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error loading audit logs')),
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(child: Text('No audit history found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24.0),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text(log.action),
                subtitle: Text('${log.details}\nDate: ${log.createdOn}'),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
