import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/roles_provider.dart';
import '../../../usr/data/users_provider.dart';

class RoleUsersTab extends ConsumerStatefulWidget {
  final String roleId;
  const RoleUsersTab({super.key, required this.roleId});

  @override
  ConsumerState<RoleUsersTab> createState() => _RoleUsersTabState();
}

class _RoleUsersTabState extends ConsumerState<RoleUsersTab> {
  Set<String> _selectedUserIds = {};
  bool _initialized = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(usersProvider);
    final roleUsersAsync = ref.watch(roleUsersProvider(widget.roleId));

    if (allUsersAsync.isLoading || roleUsersAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allUsersAsync.hasError || roleUsersAsync.hasError) {
      return const Center(child: Text('Error loading users'));
    }

    final allUsers = allUsersAsync.value ?? [];
    final roleUsers = roleUsersAsync.value ?? [];

    if (!_initialized) {
      _selectedUserIds = roleUsers.map((e) => e.id).toSet();
      _initialized = true;
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24.0),
            itemCount: allUsers.length,
            itemBuilder: (context, index) {
              final user = allUsers[index];
              final isSelected = _selectedUserIds.contains(user.id);
              return Card(
                child: CheckboxListTile(
                  title: Text('${user.firstName} ${user.lastName ?? ''}'),
                  subtitle: Text(user.email),
                  value: isSelected,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedUserIds.add(user.id);
                      } else {
                        _selectedUserIds.remove(user.id);
                      }
                    });
                  },
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
                onPressed: _isSaving ? null : _saveUsers,
                icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
                label: const Text('Save Users'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveUsers() async {
    setState(() {
      _isSaving = true;
    });
    try {
      await ref.read(roleRepositoryProvider).updateRoleUsers(widget.roleId, _selectedUserIds.toList());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Users updated successfully')));
      ref.invalidate(roleUsersProvider(widget.roleId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
