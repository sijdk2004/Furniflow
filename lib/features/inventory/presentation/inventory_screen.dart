import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/format_helper.dart';
import '../data/inventory_providers.dart';
import '../../../core/presentation/widgets/searchable_dropdown.dart';
import '../domain/inventory_model.dart';
import '../../../core/utils/shared_dialogs.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';
  String _selectedType = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allItems = ref.watch(inventoryProvider);
    
    final filteredItems = allItems.where((i) {
      final matchesSearch = i.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            i.sku.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _selectedType == 'All' || i.type == _selectedType;
      return matchesSearch && matchesType;
    }).toList();

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
                    Text('Inventory Management', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Track raw materials and finished goods', style: theme.textTheme.bodyMedium),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showStockMovementDialog(context),
                      icon: const Icon(LucideIcons.arrowRightLeft, size: 18),
                      label: const Text('Stock Movement'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddItemDialog(context),
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: const Text('Add Item'),
                    ),
                  ],
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
                        hintText: 'Search by SKU or Name...',
                        prefixIcon: const Icon(LucideIcons.search, size: 20),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      items: ['All', 'Raw Material', 'Finished Good'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: theme.textTheme.bodyMedium),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedType = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
          ),

          const SizedBox(height: 24),

          // Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Items', 
                    '${allItems.length}', 
                    LucideIcons.boxes, 
                    theme.colorScheme.primary, 
                    theme
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Low Stock Alerts', 
                    '${allItems.where((i) => i.isLowStock).length}', 
                    LucideIcons.alertTriangle, 
                    Colors.red, 
                    theme
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Inventory Value', 
                    FormatHelper.formatCurrency(allItems.fold(0.0, (sum, item) => sum + item.totalValue)), 
                    LucideIcons.dollarSign, 
                    Colors.teal, 
                    theme
                  ),
                ),
              ],
            ).animate().fade(delay: 150.ms).slideY(begin: 0.1),
          ),

          const SizedBox(height: 24),

          // Content
          Expanded(
            child: Padding(
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
                                DataColumn(label: Text('Item Name & SKU')),
                                DataColumn(label: Text('Type')),
                                DataColumn(label: Text('Location')),
                                DataColumn(label: Text('Stock Level')),
                                DataColumn(label: Text('Total Value')),
                                DataColumn(label: Text('')),
                              ],
                              rows: filteredItems.map((item) => _buildDataRow(item, theme)).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(InventoryItem item, ThemeData theme) {
    final statusColor = item.isLowStock ? Colors.red : Colors.teal;

    return DataRow(
      cells: [
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(item.sku, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(item.type, style: const TextStyle(fontSize: 12)),
          ),
        ),
        DataCell(Text(item.location)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('${item.quantity} ${item.unit}', style: TextStyle(fontWeight: FontWeight.bold, color: item.isLowStock ? Colors.red : null)),
            ],
          ),
        ),
        DataCell(Text(FormatHelper.formatCurrency(item.totalValue), style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(
          IconButton(
            icon: const Icon(LucideIcons.moreHorizontal, size: 20),
            onPressed: () => _showAddItemDialog(context),
          ),
        ),
      ],
    );
  }

  void _showStockMovementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Stock Movement'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SearchableDropdown<String>(
                label: 'Movement Type',
                items: const ['Receive Goods', 'Issue to Production', 'Transfer Location', 'Adjustment'],
                itemAsString: (e) => e,
                onChanged: (v) {},
              ),
              const SizedBox(height: 16),
              SearchableDropdown<String>(
                label: 'Item',
                items: const ['Oak Wood Panels', 'Metal Desk Legs', 'Screws (M4)'],
                itemAsString: (e) => e,
                onChanged: (v) {},
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Quantity'))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SearchableDropdown<String>(
                      label: 'Target Location',
                      items: const ['Warehouse A', 'Warehouse B', 'Production Floor'],
                      itemAsString: (e) => e,
                      onChanged: (v) {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Record Movement')),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Inventory Item'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(decoration: const InputDecoration(labelText: 'Item Name')),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'SKU'))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SearchableDropdown<String>(
                      label: 'Category',
                      items: const ['Raw Material', 'Hardware', 'Finish', 'Packaging'],
                      itemAsString: (e) => e,
                      onChanged: (v) {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Add Item')),
        ],
      ),
    );
  }
}
