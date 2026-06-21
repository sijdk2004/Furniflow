import 'package:flutter/material.dart';
import '../../domain/role_model.dart';

class RoleOverviewTab extends StatelessWidget {
  final RoleModel role;
  
  const RoleOverviewTab({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Role Information', style: Theme.of(context).textTheme.titleLarge),
              const Divider(height: 32),
              _buildInfoRow('Role Code', role.roleCode),
              const SizedBox(height: 16),
              _buildInfoRow('Role Name', role.roleName),
              const SizedBox(height: 16),
              _buildInfoRow('System Role', role.isSystemRole ? 'Yes' : 'No'),
              // We could also format createdOn and updatedOn if available.
            ],
          ),
        ),
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
