import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/bom_provider.dart';

class BomViewScreen extends ConsumerStatefulWidget {
  final String bomId;

  const BomViewScreen({super.key, required this.bomId});

  @override
  ConsumerState<BomViewScreen> createState() => _BomViewScreenState();
}

class _BomViewScreenState extends ConsumerState<BomViewScreen> {
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  final _dateFormat = DateFormat('MMM dd, yyyy');

  Future<void> _updateStatus(String newStatus) async {
    try {
      await ref.read(bomProvider.notifier).updateStatus(widget.bomId, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  Widget _buildNextAction(String currentStatus) {
    if (currentStatus == 'Draft') {
      return ElevatedButton.icon(
        onPressed: () => _updateStatus('Approved'),
        icon: const Icon(LucideIcons.checkCircle, size: 18),
        label: const Text('Approve BOM'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
      );
    } else if (currentStatus == 'Approved') {
      return ElevatedButton.icon(
        onPressed: () => _updateStatus('Active'),
        icon: const Icon(LucideIcons.playCircle, size: 18),
        label: const Text('Mark as Active Version'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bomsState = ref.watch(bomProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        title: const Text('View Bill of Materials'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.printer),
            onPressed: () {},
          ),
        ],
      ),
      body: bomsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (boms) {
          final bom = boms.firstWhere((b) => b.id == widget.bomId, orElse: () => throw Exception('Not found'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bom.product?['product_name'] ?? 'Unknown Product', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('Version: ${bom.versionNumber}', style: theme.textTheme.bodyLarge),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                                  child: Text('Status: ${bom.status}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                if (bom.activeVersion) ...[
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                    child: const Text('ACTIVE BOM', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                        _buildNextAction(bom.status),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cost Breakdown', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              _buildCostRow('Total Material Cost', bom.materialCost),
                              _buildCostRow('Total Labor Cost', bom.laborCost),
                              _buildCostRow('Total Overhead Cost', bom.overheadCost),
                              const Divider(),
                              _buildCostRow('Estimated Total Cost', bom.totalCost, isBold: true),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 3,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Materials & Components', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              DataTable(
                                columns: const [
                                  DataColumn(label: Text('Component')),
                                  DataColumn(label: Text('Quantity')),
                                  DataColumn(label: Text('Unit Cost')),
                                  DataColumn(label: Text('Total Cost')),
                                ],
                                rows: bom.items.map((item) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(item.component?['product_name'] ?? 'Unknown Component')),
                                      DataCell(Text('${item.quantity} ${item.uom?['code'] ?? ''}')),
                                      DataCell(Text(_currencyFormat.format(item.unitCost))),
                                      DataCell(Text(_currencyFormat.format(item.totalCost))),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCostRow(String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14)),
          Text(
            _currencyFormat.format(value),
            style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 16 : 14),
          ),
        ],
      ),
    );
  }
}
