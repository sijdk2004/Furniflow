import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/rbac_provider.dart';
import '../../features/auth/presentation/unauthorized_screen.dart';

class PermissionGuard extends ConsumerWidget {
  final String requiredPermission;
  final Widget child;
  final Widget? fallback;

  const PermissionGuard({
    Key? key,
    required this.requiredPermission,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rbacState = ref.watch(rbacProvider);
    
    if (rbacState.hasPermission(requiredPermission)) {
      return child;
    }
    
    return fallback ?? const UnauthorizedScreen();
  }
}
