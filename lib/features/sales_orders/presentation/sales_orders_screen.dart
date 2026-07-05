import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/format_helper.dart';
import '../data/sales_order_provider.dart';
import '../../../core/utils/shared_dialogs.dart';

class SalesOrdersScreen extends ConsumerStatefulWidget {
  const SalesOrdersScreen({super.key});

  @override
  ConsumerState<SalesOrdersScreen> createState() => _SalesOrdersScreenState();
}

class _SalesOrdersScreenState extends ConsumerState<SalesOrdersScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(salesOrderProvider.notifier).loadSalesOrders();
    });
  }

  // Generate a stable 6-digit numeric ID from UUID
  String _displayId(String id) {
    // Use last 6 alphanumeric chars of UUID for a compact, readable ID
    final clean = id.replaceAll('-', '');
    return clean.length >= 6 ? clean.substring(clean.length - 6).toUpperCase() : clean.toUpperCase();
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'Draft':
        bgColor = Colors.grey.withOpacity(0.15); textColor = Colors.grey.shade600; break;
      case 'Confirmed':
        bgColor = Colors.blue.withOpacity(0.15); textColor = Colors.blue.shade700; break;
      case 'In Production':
        bgColor = Colors.purple.withOpacity(0.15); textColor = Colors.purple.shade700; break;
      case 'Ready For Delivery':
        bgColor = Colors.orange.withOpacity(0.15); textColor = Colors.orange.shade700; break;
      case 'Delivered':
        bgColor = Colors.green.withOpacity(0.15); textColor = Colors.green.shade700; break;
      case 'Cancelled':
        bgColor = Colors.red.withOpacity(0.15); textColor = Colors.red.shade700; break;
      default:
        bgColor = Colors.grey.withOpacity(0.15); textColor = Colors.grey.shade600;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sales Orders',
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Manage converted orders and track production',
                        style: theme.textTheme.bodyMedium),
                  ],
                ),
              ],
            ).animate().fade().slideY(begin: -0.2),
          ),

          const SizedBox(height: 16),

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
                      decoration: const InputDecoration(
                        hintText: 'Search by order ID or customer...',
                        prefixIcon: Icon(LucideIcons.search, size: 18),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => SharedDialogs.showFilterDialog(context),
                  icon: const Icon(LucideIcons.filter, size: 16),
                  label: const Text('Filter'),
                ),
              ],
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
          ),

          const SizedBox(height: 16),

          // Table
          Expanded(
            child: asyncOrders.when(
              data: (data) {
                final orders = data.where((o) {
                  final id = _displayId(o.id);
                  final q = _searchQuery.toLowerCase();
                  final cusName = o.customer?['name']?.toString().toLowerCase() ?? '';
                  return o.id.toLowerCase().contains(q) ||
                      id.toLowerCase().contains(q) ||
                      cusName.contains(q);
                }).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        // ── Header Row ──
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
                          child: Row(
                            children: [
                              _hdr('SO#', flex: 10),
                              _hdr('Customer', flex: 20),
                              _hdr('Date', flex: 14),
                              _hdr('Est. Delivery', flex: 14),
                              _hdr('Amount', flex: 14),
                              _hdr('Status', flex: 16),
                              _hdr('', flex: 8),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // ── Data Rows ──
                        Expanded(
                          child: orders.isEmpty
                              ? const Center(child: Text('No orders found'))
                              : ListView.separated(
                                  itemCount: orders.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, i) {
                                    final o = orders[i];
                                    return _buildRow(o, theme);
                                  },
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

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _hdr(String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRow(dynamic o, ThemeData theme) {
    final estDelivery = o.expectedDeliveryDate != null
        ? FormatHelper.formatDate(o.expectedDeliveryDate!)
        : 'Not Set';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // SO#
          Expanded(
            flex: 10,
            child: Text(
              _displayId(o.id),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Customer
          Expanded(
            flex: 20,
            child: Text(
              o.customer?['name'] ?? 'Unknown',
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          // Date
          Expanded(
            flex: 14,
            child: Text(
              FormatHelper.formatDate(o.orderDate),
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Est. Delivery
          Expanded(
            flex: 14,
            child: Text(
              estDelivery,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: estDelivery == 'Not Set' ? Colors.grey : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Amount
          Expanded(
            flex: 14,
            child: Text(
              FormatHelper.formatCurrency(o.totalAmount),
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Status
          Expanded(
            flex: 16,
            child: _buildStatusBadge(o.status),
          ),
          // Actions
          Expanded(
            flex: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.eye, size: 16),
                  tooltip: 'View Order',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => context.push('/sales-orders/view/${o.id}'),
                ),
                if (o.status == 'Draft')
                  IconButton(
                    icon: const Icon(LucideIcons.penLine, size: 16),
                    tooltip: 'Edit Order',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => context.push('/sales-orders/edit/${o.id}'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
