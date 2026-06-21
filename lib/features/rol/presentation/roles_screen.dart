import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../data/roles_provider.dart';
import '../domain/role_model.dart';

class RolesScreen extends ConsumerWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsyncValue = ref.watch(rolesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Roles & Permissions'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: FilledButton.icon(
              onPressed: () => _showAddRoleDialog(context, ref),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Add Role'),
            ),
          ),
        ],
      ),
      body: rolesAsyncValue.when(
        data: (roles) {
          if (roles.isEmpty) {
            return const Center(child: Text('No roles found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24.0),
            itemCount: roles.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final role = roles[index];
              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.shield,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                title: Text(role.roleName),
                subtitle: Text('Code: ${role.roleCode}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (role.isSystemRole)
                      Chip(
                        label: const Text('System Role'),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        labelStyle: const TextStyle(color: Colors.blue, fontSize: 12),
                        side: BorderSide.none,
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.pencil, size: 18),
                      tooltip: role.isSystemRole ? 'System roles cannot be modified' : 'Edit Role',
                      onPressed: () => _showEditRoleDialog(context, ref, role),
                    ),
                    if (!role.isSystemRole)
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                        tooltip: 'Delete Role',
                        onPressed: () => _showDeleteRoleDialog(context, ref, role),
                      ),
                  ],
                ),
                onTap: () => context.go('/roles/view/${role.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showAddRoleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddRoleDialog(
        onSave: (roleCode, roleName) async {
          await ref.read(roleRepositoryProvider).createRole(
            roleCode: roleCode,
            roleName: roleName,
          );
          ref.invalidate(rolesProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Role "$roleName" created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditRoleDialog(BuildContext context, WidgetRef ref, RoleModel role) {
    if (role.isSystemRole) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('System roles cannot be modified'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => _EditRoleDialog(
        role: role,
        onSave: (roleCode, roleName) async {
          await ref.read(roleRepositoryProvider).updateRole(
            roleId: role.id,
            roleCode: roleCode,
            roleName: roleName,
          );
          ref.invalidate(rolesProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Role "$roleName" updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteRoleDialog(BuildContext context, WidgetRef ref, RoleModel role) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text('Are you sure you want to delete the role "${role.roleName}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(roleRepositoryProvider).deleteRole(role.id);
                ref.invalidate(rolesProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Role "${role.roleName}" deleted'),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Add Role Dialog ──────────────────────────────────────────────────────────

class _AddRoleDialog extends StatefulWidget {
  final Future<void> Function(String roleCode, String roleName) onSave;
  const _AddRoleDialog({required this.onSave});

  @override
  State<_AddRoleDialog> createState() => _AddRoleDialogState();
}

class _AddRoleDialogState extends State<_AddRoleDialog> {
  final _codeCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _codeCtrl,
            decoration: const InputDecoration(
              labelText: 'Role Code',
              hintText: 'e.g. INVENTORY_MANAGER',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Role Name',
              hintText: 'e.g. Inventory Manager',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save Role'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final code = _codeCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (code.isEmpty || name.isEmpty) {
      setState(() => _error = 'Both Role Code and Role Name are required.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await widget.onSave(code, name);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }
}

// ─── Edit Role Dialog ─────────────────────────────────────────────────────────

class _EditRoleDialog extends StatefulWidget {
  final RoleModel role;
  final Future<void> Function(String roleCode, String roleName) onSave;
  const _EditRoleDialog({required this.role, required this.onSave});

  @override
  State<_EditRoleDialog> createState() => _EditRoleDialogState();
}

class _EditRoleDialogState extends State<_EditRoleDialog> {
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.role.roleCode);
    _nameCtrl = TextEditingController(text: widget.role.roleName);
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Role'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _codeCtrl,
            decoration: const InputDecoration(labelText: 'Role Code'),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Role Name'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save Changes'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final code = _codeCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (code.isEmpty || name.isEmpty) {
      setState(() => _error = 'Both Role Code and Role Name are required.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await widget.onSave(code, name);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }
}
