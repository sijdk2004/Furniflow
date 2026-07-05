import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/format_helper.dart';
import '../data/bom_provider.dart';

class BomListScreen extends ConsumerStatefulWidget {
  const BomListScreen({super.key});

  @override
  ConsumerState<BomListScreen> createState() => _BomListScreenState();
}

class _BomListScreenState extends ConsumerState<BomListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bomProvider.notifier).loadBoms();
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
      case 'Approved':
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade700;
        break;
      case 'Active':
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
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
    final asyncBoms = ref.watch(bomProvider);

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
                    Text('Bill of Materials', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Manage BOMs and versions for products', style: theme.textTheme.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/bom/create'),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Create BOM'),
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
            child: asyncBoms.when(
              data: (data) {
                final boms = data.where((b) {
                  final productName = b.product?['product_name']?.toString().toLowerCase() ?? '';
                  return productName.contains(_searchQuery.toLowerCase());
                }).toList();

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
                              DataColumn(label: Text('Version', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Date Created', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Total Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: boms.map((b) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(b.product?['product_name'] ?? 'Unknown Product')),
                                  DataCell(
                                    Row(
                                      children: [
                                        Text('v${b.versionNumber}'),
                                        if (b.activeVersion) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                            child: const Text('Active', style: TextStyle(fontSize: 10, color: Colors.green)),
                                          )
                                        ]
                                      ],
                                    ),
                                  ),
                                  DataCell(Text(FormatHelper.formatDate(b.createdOn))),
                                  DataCell(Text(FormatHelper.formatCurrency(b.totalCost))),
                                  DataCell(_buildStatusBadge(b.status)),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(LucideIcons.eye, size: 18),
                                          tooltip: 'View BOM',
                                          onPressed: () => context.push('/bom/view/${b.id}'),
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
