import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/format_helper.dart';
import '../data/delivery_provider.dart';

class DeliveryListScreen extends ConsumerStatefulWidget {
  const DeliveryListScreen({super.key});

  @override
  ConsumerState<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends ConsumerState<DeliveryListScreen> {
  String _searchQuery = '';


  Color _getStatusColor(String status) {
    switch (status) {
      case 'Scheduled': return Colors.blue;
      case 'Dispatched': return Colors.orange;
      case 'In Transit': return Colors.purple;
      case 'Delivered': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deliveriesState = ref.watch(deliveriesProvider);

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
                    Text('Delivery Management',
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('View and manage all deliveries', style: theme.textTheme.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/delivery/create'),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Schedule Delivery'),
                ),
              ],
            ).animate().fade().slideY(begin: -0.2),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search by delivery no, customer...',
                  prefixIcon: Icon(LucideIcons.search, size: 18),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ).animate().fade(delay: 100.ms).slideY(begin: 0.1),

          const SizedBox(height: 16),

          // Table
          Expanded(
            child: deliveriesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
              data: (items) {
                final filtered = items.where((item) {
                  final q = _searchQuery.toLowerCase();
                  return (item['delivery_number'] ?? '').toString().toLowerCase().contains(q) ||
                      (item['customer_name'] ?? '').toString().toLowerCase().contains(q) ||
                      (item['order_number'] ?? '').toString().toLowerCase().contains(q);
                }).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Card(
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        // Header Row
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          child: Row(
                            children: [
                              _hdr('Delivery No', flex: 20),
                              _hdr('PO No', flex: 15),
                              _hdr('Customer', flex: 20),
                              _hdr('Expected Date', flex: 16),
                              _hdr('Status', flex: 16),
                              _hdr('', flex: 8),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Data Rows
                        Expanded(
                          child: filtered.isEmpty
                              ? const Center(child: Text('No deliveries found'))
                              : ListView.separated(
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, i) {
                                    final item = filtered[i];
                                    final expectedDate = DateTime.tryParse(
                                        item['expected_delivery_date'] ?? '');
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 20,
                                            child: Text(
                                              item['delivery_number'] ?? '-',
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 15,
                                            child: Text(
                                              item['order_number'] ?? '-',
                                              style: theme.textTheme.bodyMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 20,
                                            child: Text(
                                              item['customer_name'] ?? 'N/A',
                                              style: theme.textTheme.bodyMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 16,
                                            child: Text(
                                              expectedDate != null
                                                  ? FormatHelper.formatDate(expectedDate)
                                                  : '-',
                                              style: theme.textTheme.bodyMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 16,
                                            child: _buildStatusBadge(item['status'] ?? ''),
                                          ),
                                          Expanded(
                                            flex: 8,
                                            child: IconButton(
                                              icon: const Icon(LucideIcons.eye, size: 16),
                                              tooltip: 'View Delivery',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                  minWidth: 32, minHeight: 32),
                                              onPressed: () =>
                                                  context.go('/delivery/view/${item['id']}'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 200.ms),
                );
              },
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
}
