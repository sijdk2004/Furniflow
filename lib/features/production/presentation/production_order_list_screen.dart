import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/production_order_provider.dart';

class ProductionOrderListScreen extends ConsumerStatefulWidget {
  const ProductionOrderListScreen({super.key});

  @override
  ConsumerState<ProductionOrderListScreen> createState() => _ProductionOrderListScreenState();
}

class _ProductionOrderListScreenState extends ConsumerState<ProductionOrderListScreen> {
  String _searchQuery = '';
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productionOrderProvider.notifier).loadOrders();
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
      case 'Released':
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade700;
        break;
      case 'In Progress':
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        break;
      case 'Completed':
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
    final asyncOrders = ref.watch(productionOrderProvider);

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
                    Text('Production Orders', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Manage manufacturing execution and timelines', style: theme.textTheme.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/production/create'),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('New Production Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
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
                        hintText: 'Search by Product...',
                        prefixIcon: const Icon(LucideIcons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
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
                  final productName = o.product?['product_name']?.toString().toLowerCase() ?? '';
                  return productName.contains(_searchQuery.toLowerCase());
                }).toList();

                if (orders.isEmpty) {
                  return const Center(child: Text('No Production Orders found.'));
                }

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
                                  columns: const [
                              DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Date Created', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Est. Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: orders.map((o) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(o.product?['product_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text('BOM v${o.bomVersion}', style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(o.quantity.toString())),
                                  DataCell(Text(_dateFormat.format(o.createdOn.toLocal()))),
                                  DataCell(Text(_currencyFormat.format(o.totalCost))),
                                  DataCell(_buildStatusBadge(o.status)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(LucideIcons.eye, size: 18),
                                          tooltip: 'View Order',
                                          onPressed: () => context.push('/production/view/${o.id}'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                                ),
                              ),
                            );
                          }
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
