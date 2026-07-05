import 'package:flutter_riverpod/flutter_riverpod.dart';

class RbacState {
  final List<String> permissions;

  RbacState({required this.permissions});

  bool hasPermission(String requiredPermission) {

    return permissions.contains(requiredPermission);
  }
}

class RbacNotifier extends Notifier<RbacState> {
  @override
  RbacState build() {
    return RbacState(permissions: []);
  }

  void setPermissions(List<String> perms) {
    state = RbacState(permissions: perms);
  }

  void clear() {
    state = RbacState(permissions: []);
  }
}

final rbacProvider = NotifierProvider<RbacNotifier, RbacState>(() {
  return RbacNotifier();
});
