import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/rbac_provider.dart';
import '../../../core/network/providers/network_providers.dart';

class MenuItem {
  final String title;
  final String route;
  final String icon;
  final String? permissionCode;
  final String? requiredPermission;
  final String group;

  MenuItem({
    required this.title, 
    required this.route, 
    required this.icon, 
    this.permissionCode,
    this.requiredPermission,
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
    String? reqPerm;
    if (screenCode == 'DSH_HOME') { routePath = '/dashboard'; reqPerm = 'DSH.DSH_HOME.VIEW'; }
    else if (screenCode == 'USR_LIST') { routePath = '/users'; reqPerm = 'USR.USR_LIST.VIEW'; }
    else if (screenCode == 'CUS_LIST') { routePath = '/customers'; reqPerm = 'CUS.CUS_LIST.VIEW'; }
    else if (screenCode == 'ROL_LIST') { routePath = '/roles'; reqPerm = 'ROL.ROL_LIST.VIEW'; }
    else if (screenCode == 'PRD_LIST') { routePath = '/catalog'; reqPerm = 'CAT.CAT_PROD.VIEW'; }
    else if (screenCode == 'BOM_LIST') { routePath = '/bom'; reqPerm = 'MFG.BOM.VIEW'; }
    else if (screenCode == 'MFG_DSH') { routePath = '/manufacturing-dashboard'; reqPerm = 'MFG.DSH.VIEW'; }
    else if (screenCode == 'DLV_DSH') { routePath = '/delivery-dashboard'; reqPerm = 'DLV.DSH.VIEW'; }
    else if (screenCode == 'MFG_ORD_LIST') { routePath = '/production'; reqPerm = 'MFG.PRD.VIEW'; }
    else if (screenCode == 'TRK_BOARD') { routePath = '/tracking/board'; reqPerm = 'MFG.TRK.VIEW_BOARD'; }
    else if (screenCode == 'TRK_LIST') { routePath = '/tracking'; reqPerm = 'MFG.TRK.VIEW'; }
    else if (screenCode == 'DLV_LIST') { routePath = '/delivery'; reqPerm = 'DLV.DLV_LIST.VIEW'; }
    else if (screenCode != null) { routePath = '/${screenCode.toLowerCase()}'; }

    return MenuItem(
      title: json['MenuName'] ?? json['menu_name'] ?? 'Unknown',
      route: routePath,
      icon: json['IconName'] ?? json['icon_name'] ?? 'circle',
      permissionCode: json['ModuleCode'] ?? json['module_code'],
      requiredPermission: reqPerm,
      group: _determineGroup(routePath)
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
    if (permissions.contains('DSH.DSH_HOME.VIEW')) {
      filteredMenus.add(MenuItem(title: 'Sales Dashboard', route: '/sales-dashboard', icon: 'barChart', group: MenuItem._determineGroup('/sales-dashboard')));
    }
    if (permissions.contains('SYS.MASTER_DATA.VIEW')) {
      filteredMenus.add(MenuItem(title: 'Master Data', route: '/master-data', icon: 'settings', group: MenuItem._determineGroup('/master-data')));
    }
    if (permissions.contains('QTN.QTN_MGMT.VIEW')) {
      filteredMenus.add(MenuItem(title: 'Quotations', route: '/quotations', icon: 'fileText', group: MenuItem._determineGroup('/quotations')));
    }
    if (permissions.contains('SO.SO_LIST.VIEW')) {
      filteredMenus.add(MenuItem(title: 'Sales Orders', route: '/sales-orders', icon: 'shoppingCart', group: MenuItem._determineGroup('/sales-orders')));
    }
    if (permissions.contains('MFG.DSH.VIEW')) {
      filteredMenus.add(MenuItem(title: 'Manufacturing Dashboard', route: '/manufacturing-dashboard', icon: 'factory', group: MenuItem._determineGroup('/manufacturing-dashboard')));
    }
    if (permissions.contains('DLV.DLV_LIST.VIEW')) {
      filteredMenus.add(MenuItem(title: 'Delivery Dashboard', route: '/delivery-dashboard', icon: 'truck', group: MenuItem._determineGroup('/delivery-dashboard')));
    }

    try {
      final response = await apiClient.get('/v1/system/menus');
      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'] as List;
        List<MenuItem> allMenus = data.map((e) => MenuItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();

        for (var menu in allMenus) {
          if (menu.requiredPermission != null && permissions.contains(menu.requiredPermission)) {
            filteredMenus.add(menu);
          }
        }
      }
    } catch (e) {
      print('Error loading menus: $e');
    }

    state = filteredMenus;
  }
}

final menuProvider = NotifierProvider<MenuNotifier, List<MenuItem>>(() {
  return MenuNotifier();
});
