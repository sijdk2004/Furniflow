import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/bom_provider.dart';
import '../domain/bom_model.dart';
import '../../../core/utils/shared_dialogs.dart';
import '../../../core/presentation/widgets/searchable_dropdown.dart';

class BomScreen extends ConsumerStatefulWidget {
  const BomScreen({super.key});

  @override
  ConsumerState<BomScreen> createState() => _BomScreenState();
}

class _BomScreenState extends ConsumerState<BomScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bomsState = ref.watch(bomProvider);
    final boms = bomsState.maybeWhen(
      data: (data) => data.where((b) => 
        (b.product?['product_name']?.toString().toLowerCase() ?? 'unknown').contains(_searchQuery.toLowerCase()) || 
        b.id.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList(),
      orElse: () => <Bom>[],
    );

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
                    Text('Bill of Materials (BOM)', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Manage product structures and components', style: theme.textTheme.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateBomDialog(context),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Create BOM'),
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
                        hintText: 'Search by Product Name or BOM ID...',
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
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              itemCount: boms.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final bom = boms[index];
                return _buildBomCard(bom, theme).animate().fade(delay: (50 * index).ms).slideX(begin: 0.1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBomCard(Bom bom, ThemeData theme) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedBackgroundColor: theme.colorScheme.surface,
          backgroundColor: theme.colorScheme.surface,
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.gitCommit, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(bom.product?['product_name'] ?? 'Unknown', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('v${bom.versionNumber}', style: theme.textTheme.bodySmall),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(bom.id, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Text('${bom.items.length} components', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                          const SizedBox(width: 12),
                          Text('Est. Cost: \$${bom.totalCost.toStringAsFixed(2)}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bom.status == 'Active' ? Colors.teal.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    bom.status,
                    style: TextStyle(
                      color: bom.status == 'Active' ? Colors.teal : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          children: [
            Container(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('COMPONENTS', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  ...bom.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        Icon(LucideIcons.cornerDownRight, size: 16, color: theme.dividerColor),
                        const SizedBox(width: 12),
                        Text(item.componentId, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        Expanded(child: Text(item.component?['product_name'] ?? 'Unknown Component')),
                        Text('${item.quantity} ${item.uom?['code'] ?? 'Units'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _showCreateBomDialog(context),
                      icon: const Icon(LucideIcons.edit, size: 16),
                      label: const Text('Edit BOM'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateBomDialog(BuildContext context) {
    int componentCount = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Create New BOM'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SearchableDropdown<String>(
                      label: 'Target Product',
                      items: const ['Executive Desk', 'Dining Chair', 'Minimalist Wardrobe'],
                      itemAsString: (e) => e,
                      onChanged: (v) {},
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'BOM Reference No.'))),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SearchableDropdown<String>(
                            label: 'Status',
                            items: const ['Draft', 'Active'],
                            itemAsString: (e) => e,
                            onChanged: (v) {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Materials / Components', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...List.generate(componentCount, (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: TextFormField(decoration: const InputDecoration(labelText: 'Material Name', isDense: true))),
                          const SizedBox(width: 8),
                          Expanded(flex: 1, child: TextFormField(decoration: const InputDecoration(labelText: 'Qty', isDense: true))),
                          const SizedBox(width: 8),
                          Expanded(flex: 2, child: SearchableDropdown<String>(
                            label: 'Unit',
                            items: const ['pcs', 'm', 'sqm', 'kg'],
                            itemAsString: (e) => e,
                            onChanged: (v) {},
                          )),
                          IconButton(
                            icon: const Icon(LucideIcons.trash, size: 18, color: Colors.red),
                            onPressed: () => setState(() => componentCount--),
                          ),
                        ],
                      ),
                    )),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(LucideIcons.plusCircle, color: Colors.blue),
                      title: const Text('Add Component', style: TextStyle(color: Colors.blue)),
                      onTap: () => setState(() => componentCount++),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save BOM')),
            ],
          );
        }
      ),
    );
  }
}
