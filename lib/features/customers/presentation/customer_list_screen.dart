import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/permission_guard.dart';
import '../data/customer_provider.dart';
import '../domain/customer_model.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  void _deleteCustomer(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text('Are you sure you want to delete this customer?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(customerRepositoryProvider).deleteCustomer(id);
        ref.refresh(customersProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(customersProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customers', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              PermissionGuard(
                requiredPermission: 'CUS.CUS_LIST.CREATE',
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/customers/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Customer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: asyncData.when(
                data: (data) => _buildDataTable(context, ref, data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, WidgetRef ref, List<CustomerModel> data) {
    if (data.isEmpty) return const Center(child: Text('No customers found.'));
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: data.map((item) => DataRow(
            cells: [
              DataCell(Text(item.name)),
              DataCell(Text(item.email ?? '-')),
              DataCell(Text(item.phone ?? '-')),
              DataCell(Text(item.customerType?.name ?? '-')),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(color: item.isActive ? Colors.green : Colors.red, fontSize: 12),
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PermissionGuard(
                      requiredPermission: 'CUS.CUS_LIST.VIEW',
                      child: IconButton(icon: const Icon(Icons.visibility, color: Colors.grey), onPressed: () => context.go('/customers/view/${item.id}')),
                    ),
                    PermissionGuard(
                      requiredPermission: 'CUS.CUS_LIST.UPDATE',
                      child: IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => context.go('/customers/edit/${item.id}')),
                    ),
                    PermissionGuard(
                      requiredPermission: 'CUS.CUS_LIST.DELETE',
                      child: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteCustomer(context, ref, item.id)),
                    ),
                  ],
                ),
              ),
            ]
          )).toList(),
        ),
      ),
    );
  }
}
