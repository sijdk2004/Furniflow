import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../domain/permission_model.dart';
import '../../data/roles_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RolePermissionsTab extends ConsumerStatefulWidget {
  final String roleId;
  const RolePermissionsTab({super.key, required this.roleId});

  @override
  ConsumerState<RolePermissionsTab> createState() => _RolePermissionsTabState();
}

class _RolePermissionsTabState extends ConsumerState<RolePermissionsTab> {
  Set<String> _selectedPermissionIds = {};
  bool _initialized = false;
  bool _isSaving = false;
  String _searchQuery = '';
  
  Map<String, bool> _expandedState = {};

  String _getModuleName(PermissionModel p) {
    if (p.moduleCode == 'DSH') return 'Executive Dashboard';
    if (p.moduleCode == 'MFG' && p.screenCode == 'DSH') return 'Manufacturing Dashboard';
    if (p.moduleCode == 'USR') return 'Users';
    if (p.moduleCode == 'ROL') return 'Roles';
    if (p.moduleCode == 'SYS') return 'Master Data';
    if (p.moduleCode == 'CUS') return 'Customers';
    if (p.moduleCode == 'CAT') return 'Catalog';
    if (p.moduleCode == 'QTN') return 'Quotations';
    if (p.moduleCode == 'SO') return 'Sales Orders';
    if (p.moduleCode == 'MFG' && p.screenCode == 'BOM') return 'BOM';
    if (p.moduleCode == 'MFG' && p.screenCode == 'PRD') return 'Production Orders';
    if (p.moduleCode == 'MFG' && p.screenCode == 'TRK') return 'Production Tracking';
    if (p.moduleCode == 'DLV') return 'Delivery';
    return p.moduleCode;
  }

  @override
  Widget build(BuildContext context) {
    final allPermsAsync = ref.watch(allPermissionsProvider);
    final rolePermsAsync = ref.watch(rolePermissionsProvider(widget.roleId));

    if (allPermsAsync.isLoading || rolePermsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allPermsAsync.hasError || rolePermsAsync.hasError) {
      return const Center(child: Text('Error loading permissions'));
    }

    final allPerms = allPermsAsync.value ?? [];
    final rolePerms = rolePermsAsync.value ?? [];

    if (!_initialized) {
      _selectedPermissionIds = rolePerms.map((e) => e.id).toSet();
      _initialized = true;
    }

    final filteredPerms = allPerms.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final title = p.displayName?.toLowerCase() ?? '';
      final desc = p.description?.toLowerCase() ?? '';
      final code = p.permissionCode.toLowerCase();
      return title.contains(q) || desc.contains(q) || code.contains(q);
    }).toList();

    final grouped = groupBy(filteredPerms, (PermissionModel p) => _getModuleName(p));
    final sortedModules = grouped.keys.toList()..sort();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0).copyWith(bottom: 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Permissions',
                    prefixIcon: Icon(LucideIcons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                icon: const Icon(LucideIcons.listPlus),
                label: const Text('Expand All'),
                onPressed: () {
                  setState(() {
                    for (var m in sortedModules) {
                      _expandedState[m] = true;
                    }
                  });
                },
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(LucideIcons.listMinus),
                label: const Text('Collapse All'),
                onPressed: () {
                  setState(() {
                    for (var m in sortedModules) {
                      _expandedState[m] = false;
                    }
                  });
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: sortedModules.length,
            itemBuilder: (context, index) {
              final module = sortedModules[index];
              final perms = grouped[module]!;
              final isExpanded = _expandedState[module] ?? true;

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: ExpansionTile(
                  key: Key('$module-$isExpanded'),
                  title: Text('$module (${perms.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  initiallyExpanded: isExpanded,
                  onExpansionChanged: (val) {
                    _expandedState[module] = val;
                  },
                  children: perms.map((perm) {
                    final isSelected = _selectedPermissionIds.contains(perm.id);
                    return CheckboxListTile(
                      title: Text(perm.displayName ?? perm.permissionCode),
                      subtitle: perm.description != null ? Text(perm.description!) : null,
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedPermissionIds.add(perm.id);
                          } else {
                            _selectedPermissionIds.remove(perm.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _savePermissions,
                icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                label: const Text('Save Permissions'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _savePermissions() async {
    setState(() {
      _isSaving = true;
    });
    try {
      await ref.read(roleRepositoryProvider).updateRolePermissions(widget.roleId, _selectedPermissionIds.toList());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissions updated successfully')));
      ref.invalidate(rolePermissionsProvider(widget.roleId));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
