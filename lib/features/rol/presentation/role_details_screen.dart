import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/roles_provider.dart';
import 'tabs/role_overview_tab.dart';
import 'tabs/role_permissions_tab.dart';
import 'tabs/role_users_tab.dart';
import 'tabs/role_audit_tab.dart';

class RoleDetailsScreen extends ConsumerWidget {
  final String roleId;
  const RoleDetailsScreen({super.key, required this.roleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(roleDetailsProvider(roleId));

    return roleAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $error')),
      ),
      data: (role) {
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Role: ${role.roleName}'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/roles'),
              ),
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Overview'),
                  Tab(text: 'Permissions'),
                  Tab(text: 'Assigned Users'),
                  Tab(text: 'Audit History'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                RoleOverviewTab(role: role),
                RolePermissionsTab(roleId: roleId),
                RoleUsersTab(roleId: roleId),
                RoleAuditTab(roleId: roleId),
              ],
            ),
          ),
        );
      },
    );
  }
}
