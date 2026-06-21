import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/rbac_provider.dart';
import '../../../core/network/providers/network_providers.dart';

class MenuItem {
  final String title;
  final String route;
  final String icon;
  final String? permissionCode;
  final String group;

  MenuItem({
    required this.title, 
    required this.route, 
    required this.icon, 
    this.permissionCode, 
    required this.group
  });

  static String _determineGroup(String routePath) {
    if (routePath.contains('dashboard')) return 'Dashboards';
    if (['/customers', '/quotations', '/sales-orders', '/catalog'].contains(routePath)) return 'Sales';
    if (['/bom', '/production', '/tracking', '/tracking/board'].contains(routePath)) return 'Manufacturing';
    if (routePath.contains('/delivery')) return 'Logistics';
    if (['/users', '/roles', '/master-data'].contains(routePath)) return 'Administration';
    return 'Other';
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    String? screenCode = json['ScreenCode'] ?? json['screen_code'];
    String routePath = '/';
    if (screenCode == 'DSH_HOME') routePath = '/dashboard';
    else if (screenCode == 'USR_LIST') routePath = '/users';
    else if (screenCode == 'CUS_LIST') routePath = '/customers';
    else if (screenCode == 'ROL_LIST') routePath = '/roles';
    else if (screenCode == 'PRD_LIST') routePath = '/catalog';
    else if (screenCode == 'BOM_LIST') routePath = '/bom';
    else if (screenCode == 'MFG_DSH') routePath = '/manufacturing-dashboard';
    else if (screenCode == 'DLV_DSH') routePath = '/delivery-dashboard';
    else if (screenCode == 'MFG_ORD_LIST') routePath = '/production';
    else if (screenCode == 'TRK_BOARD') routePath = '/tracking/board';
    else if (screenCode == 'TRK_LIST') routePath = '/tracking';
    else if (screenCode == 'DLV_LIST') routePath = '/delivery';
    else if (screenCode != null) routePath = '/${screenCode.toLowerCase()}';

    return MenuItem(
      title: json['MenuName'] ?? json['menu_name'] ?? 'Unknown',
      route: routePath,
      icon: json['IconName'] ?? json['icon_name'] ?? 'circle',
      permissionCode: json['ModuleCode'] ?? json['module_code'],
      group: _determineGroup(routePath),
    );
  }
}

class MenuNotifier extends Notifier<List<MenuItem>> {
  @override
  List<MenuItem> build() => [];

  Future<void> loadMenusForRole() async {
    final permissions = ref.read(rbacProvider).permissions;
    final apiClient = ref.read(apiClientProvider);

    List<MenuItem> filteredMenus = [];

    // Fallback for POC modules not yet in DB
    if (permissions.contains('PLATFORM_ADMIN') || permissions.contains('DSH.DSH_HOME.VIEW')) {
      filteredMenus.add(MenuItem(title: 'Sales Dashboard', route: '/sales-dashboard', icon: 'barChart', group: MenuItem._determineGroup('/sales-dashboard')));
    }
    if (permissions.contains('PLATFORM_ADMIN') || permissions.contains('SYS.MASTER_DATA.VIEW')) {
      filteredMenus.add(MenuItem(title: 'Master Data', route: '/master-data', icon: 'settings', group: MenuItem._determineGroup('/master-data')));
    }
    if (permissions.contains('PLATFORM_ADMIN') || permissions.contains('QTN.QTN_MGMT.VIEW')) {
      filteredMenus.add(MenuItem(title: 'Quotations', route: '/quotations', icon: 'fileText', group: MenuItem._determineGroup('/quotations')));
    }
    if (permissions.contains('PLATFORM_ADMIN') || permissions.contains('SO.SO_LIST.VIEW')) {
      filteredMenus.add(MenuItem(title: 'Sales Orders', route: '/sales-orders', icon: 'shoppingCart', group: MenuItem._determineGroup('/sales-orders')));
    }
    if (permissions.contains('PLATFORM_ADMIN') || permissions.contains('MFG.DSH.VIEW')) {
      filteredMenus.add(MenuItem(title: 'Manufacturing Dashboard', route: '/manufacturing-dashboard', icon: 'factory', group: MenuItem._determineGroup('/manufacturing-dashboard')));
    }
    if (permissions.contains('PLATFORM_ADMIN') || permissions.contains('DLV.DLV_LIST.VIEW')) {
      filteredMenus.add(MenuItem(title: 'Delivery Dashboard', route: '/delivery-dashboard', icon: 'truck', group: MenuItem._determineGroup('/delivery-dashboard')));
    }

    try {
      final response = await apiClient.get('/v1/system/menus');
      final data = response.data['data'] as List;
      
      List<MenuItem> allMenus = data.map((e) => MenuItem.fromJson(e)).toList();

      for (var menu in allMenus) {
        if (permissions.contains('PLATFORM_ADMIN') || 
           (menu.permissionCode != null && permissions.contains('${menu.permissionCode}.${menu.permissionCode}_LIST.VIEW'))) {
          filteredMenus.add(menu);
        }
      }
    } catch (e) {
      // API call failed, ignore for POC
    }

    state = filteredMenus;
  }
}

final menuProvider = NotifierProvider<MenuNotifier, List<MenuItem>>(() {
  return MenuNotifier();
});
