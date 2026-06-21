import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/sales_order_provider.dart';
import '../../../core/utils/shared_dialogs.dart';

class SalesOrdersScreen extends ConsumerStatefulWidget {
  const SalesOrdersScreen({super.key});

  @override
  ConsumerState<SalesOrdersScreen> createState() => _SalesOrdersScreenState();
}

class _SalesOrdersScreenState extends ConsumerState<SalesOrdersScreen> {
  String _searchQuery = '';
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(salesOrderProvider.notifier).loadSalesOrders();
    });
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'Draft':
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey.shade700;
        break;
      case 'Confirmed':
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade700;
        break;
      case 'In Production':
        bgColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple.shade700;
        break;
      case 'Ready For Delivery':
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        break;
      case 'Delivered':
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        break;
      case 'Cancelled':
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asyncOrders = ref.watch(salesOrderProvider);

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
                    Text('Sales Orders', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Manage converted orders and track production', style: theme.textTheme.bodyMedium),
                  ],
                ),
                // No Create button, generated from Quotations
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
                        hintText: 'Search orders by ID or customer...',
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
              ],
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
          ),

          const SizedBox(height: 24),

          // Content
          Expanded(
            child: asyncOrders.when(
              data: (data) {
                final orders = data.where((o) {
                  final matchesId = o.id.toLowerCase().contains(_searchQuery.toLowerCase());
                  final customerName = o.customer?['name']?.toString().toLowerCase() ?? '';
                  final matchesCustomer = customerName.contains(_searchQuery.toLowerCase());
                  return matchesId || matchesCustomer;
                }).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Card(
                    child: ListView(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Expected Delivery', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: orders.map((o) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      o.id,
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(o.customer?['name'] ?? 'Unknown Customer')),
                                  DataCell(Text(_dateFormat.format(o.orderDate.toLocal()))),
                                  DataCell(Text(o.expectedDeliveryDate != null 
                                      ? _dateFormat.format(o.expectedDeliveryDate!.toLocal()) 
                                      : 'Not Set')),
                                  DataCell(Text(_currencyFormat.format(o.totalAmount))),
                                  DataCell(_buildStatusBadge(o.status)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(LucideIcons.eye, size: 18),
                                          tooltip: 'View Order',
                                          onPressed: () {
                                            context.push('/sales-orders/view/${o.id}');
                                          },
                                        ),
                                        if (o.status == 'Draft')
                                          IconButton(
                                            icon: const Icon(LucideIcons.penLine, size: 18),
                                            tooltip: 'Edit Order',
                                            onPressed: () {
                                              context.push('/sales-orders/edit/${o.id}');
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 200.ms),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
