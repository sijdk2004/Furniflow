import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/master_data_provider.dart';
import '../domain/master_data_model.dart';
import '../../../core/utils/shared_dialogs.dart';

class MasterDataScreen extends ConsumerStatefulWidget {
  const MasterDataScreen({super.key});

  @override
  ConsumerState<MasterDataScreen> createState() => _MasterDataScreenState();
}

class _MasterDataScreenState extends ConsumerState<MasterDataScreen> {
  String _searchQuery = '';

  final Map<String, List<Map<String, String>>> _categories = {
    'Platform Masters': [
      {'id': 'currencies', 'label': 'Currencies', 'icon': 'dollarSign'},
      {'id': 'units_of_measure', 'label': 'Units of Measure', 'icon': 'ruler'},
      {'id': 'document_types', 'label': 'Document Types', 'icon': 'fileText'},
    ],
    'Organization Masters': [
      {'id': 'branches', 'label': 'Branches', 'icon': 'building'},
      {'id': 'departments', 'label': 'Departments', 'icon': 'users'},
      {'id': 'designations', 'label': 'Designations', 'icon': 'briefcase'},
    ],
    'Furniture Masters': [
      {'id': 'wood_types', 'label': 'Wood Types', 'icon': 'treePine'},
      {'id': 'product_variants', 'label': 'Product Variants', 'icon': 'layers'},
      {'id': 'production_stages', 'label': 'Production Stages', 'icon': 'hammer'},
      {'id': 'customer_types', 'label': 'Customer Types', 'icon': 'users'},
    ],
  };

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'dollarSign': return LucideIcons.dollarSign;
      case 'ruler': return LucideIcons.ruler;
      case 'fileText': return LucideIcons.fileText;
      case 'building': return LucideIcons.building;
      case 'users': return LucideIcons.users;
      case 'briefcase': return LucideIcons.briefcase;
      case 'treePine': return LucideIcons.treePine;
      case 'layers': return LucideIcons.layers;
      case 'hammer': return LucideIcons.hammer;
      default: return LucideIcons.circle;
    }
  }

  void _showAddEditDialog({MasterDataModel? record}) {
    final isEdit = record != null;
    final codeController = TextEditingController(text: record?.code);
    final nameController = TextEditingController(text: record?.name);
    final descController = TextEditingController(text: record?.description);
    final sortController = TextEditingController(text: record?.sortOrder.toString() ?? '0');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Record' : 'Add New Record'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Code *', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: sortController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sort Order', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final data = {
                'code': codeController.text,
                'name': nameController.text,
                'description': descController.text,
                'sort_order': int.tryParse(sortController.text) ?? 0,
                'is_active': true,
              };

              try {
                if (isEdit) {
                  await ref.read(masterDataProvider.notifier).updateRecord(record.id, data);
                } else {
                  await ref.read(masterDataProvider.notifier).createRecord(data);
                }
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(MasterDataModel record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Master Record'),
        content: Text('Are you sure you want to delete ${record.name}? This action cannot be undone and may break references if this code is in use.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(masterDataProvider.notifier).deleteRecord(record.id);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedType = ref.watch(selectedMasterDataTypeProvider);
    final asyncData = ref.watch(masterDataProvider);

    String selectedLabel = 'Master Data';
    for (var group in _categories.values) {
      for (var item in group) {
        if (item['id'] == selectedType) {
          selectedLabel = item['label']!;
        }
      }
    }

    return Scaffold(
      body: Row(
        children: [
          // Left Sidebar (Master Types)
          Container(
            width: 250,
            color: theme.colorScheme.surface,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text('Configuration', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ),
                ..._categories.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        child: Text(entry.key.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
                      ),
                      ...entry.value.map((item) {
                        final isSelected = selectedType == item['id'];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                          leading: Icon(_getIcon(item['icon']!), color: isSelected ? theme.colorScheme.primary : Colors.grey, size: 20),
                          title: Text(item['label']!, style: TextStyle(
                            color: isSelected ? theme.colorScheme.primary : null,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          )),
                          selected: isSelected,
                          selectedTileColor: theme.colorScheme.primary.withOpacity(0.05),
                          onTap: () {
                            ref.read(selectedMasterDataTypeProvider.notifier).setType(item['id']!);
                          },
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          // Right Main Area
          Expanded(
            child: Column(
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
                          Text(selectedLabel, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Manage reference data for $selectedLabel', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddEditDialog,
                        icon: const Icon(LucideIcons.plus, size: 18),
                        label: const Text('Add Record'),
                      ),
                    ],
                  ).animate().fade().slideY(begin: -0.2),
                ),

                // Toolbar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Search by code or name...',
                        prefixIcon: Icon(LucideIcons.search, size: 20),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ).animate().fade(delay: 100.ms),
                ),

                const SizedBox(height: 24),

                // Content
                Expanded(
                  child: asyncData.when(
                    data: (data) {
                      final filtered = data.where((d) {
                        return d.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                               d.code.toLowerCase().contains(_searchQuery.toLowerCase());
                      }).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Text('No records found.', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Card(
                          child: ListView(
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Sort Order', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                  rows: filtered.map((record) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(record.code, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary))),
                                        DataCell(Text(record.name)),
                                        DataCell(Text(record.description.length > 30 ? '${record.description.substring(0, 30)}...' : record.description)),
                                        DataCell(Text(record.sortOrder.toString())),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(LucideIcons.penLine, size: 18),
                                                tooltip: 'Edit',
                                                onPressed: () => _showAddEditDialog(record: record),
                                              ),
                                              IconButton(
                                                icon: const Icon(LucideIcons.trash2, size: 18),
                                                color: Colors.red,
                                                tooltip: 'Delete',
                                                onPressed: () => _confirmDelete(record),
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
          ),
        ],
      ),
    );
  }
}
