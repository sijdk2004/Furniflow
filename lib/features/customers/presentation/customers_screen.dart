import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/customer_provider.dart';
import '../domain/customer_model.dart';
import '../../../core/utils/shared_dialogs.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchQuery = '';

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncCustomers = ref.watch(customersProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Customers', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Manage your client relationships', style: theme.textTheme.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/customers/create'),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Add Customer'),
                ),
              ],
            ).animate().fade().slideY(begin: -0.2),
          ),
          
          // Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search customers by name or company...',
                        prefixIcon: const Icon(LucideIcons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => SharedDialogs.showFilterDialog(context),
                  icon: const Icon(LucideIcons.filter, size: 18),
                  label: const Text('Filter'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => SharedDialogs.showExportDialog(context),
                  icon: const Icon(LucideIcons.download, size: 18),
                  label: const Text('Export'),
                ),
              ],
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
          ),

          const SizedBox(height: 24),

          // Content
          Expanded(
            child: asyncCustomers.when(
              data: (data) {
                final customers = data.where((c) => 
                  c.name.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Card(
                    child: ListView(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                child: DataTable(
                                  columnSpacing: 24,
                                  horizontalMargin: 16,
                            headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            dataTextStyle: theme.textTheme.bodyMedium,
                            dividerThickness: 1,
                            columns: const [
                              DataColumn(label: Text('Customer')),
                              DataColumn(label: Text('Contact')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Credit Limit')),
                              DataColumn(label: Text('')),
                            ],
                            rows: customers.map((c) => _buildDataRow(c, theme)).toList(),
                                ),
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  DataRow _buildDataRow(CustomerModel customer, ThemeData theme) {
    final statusColor = customer.isActive ? Colors.teal : Colors.grey;

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(customer.name.isNotEmpty ? customer.name[0] : '?', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(customer.email ?? '-', style: const TextStyle(fontSize: 13)),
              Text(customer.phone ?? '-', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              customer.isActive ? 'Active' : 'Archived',
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataCell(Text('\$${customer.creditLimit.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreHorizontal, size: 20),
            onSelected: (value) async {
              if (value == 'View Details') {
                context.go('/customers/view/${customer.id}');
              } else if (value == 'Edit Customer') {
                context.go('/customers/edit/${customer.id}');
              } else if (value == 'Delete') {
                final confirmed = await SharedDialogs.showDeleteConfirmation(context, itemName: 'customer');
                if (confirmed == true) {
                  try {
                    await ref.read(customerRepositoryProvider).deleteCustomer(customer.id);
                    ref.refresh(customersProvider);
                    if (context.mounted) {
                      SharedDialogs.showSuccessSnackbar(context, 'Customer deleted successfully');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'View Details', child: ListTile(leading: Icon(LucideIcons.eye, size: 18), title: Text('View Details'), contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'Edit Customer', child: ListTile(leading: Icon(LucideIcons.edit, size: 18), title: Text('Edit Customer'), contentPadding: EdgeInsets.zero)),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'Delete', child: ListTile(leading: Icon(LucideIcons.trash2, size: 18, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero)),
            ],
          ),
        ),
      ],
    );
  }


}
