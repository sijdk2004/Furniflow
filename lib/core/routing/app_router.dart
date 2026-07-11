import 'package:flutter/material.dart';
import '../../features/production/presentation/production_tracking_screen.dart';
import '../../features/production/presentation/production_board_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/sales_dashboard_screen.dart';
import '../../features/dashboard/presentation/manufacturing_dashboard_screen.dart';
import '../../features/dashboard/presentation/delivery_dashboard_screen.dart';
import '../../features/catalog/presentation/catalog_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/customers/presentation/customers_screen.dart';
import '../../features/inquiries/presentation/inquiries_screen.dart';
import '../../features/quotations/presentation/quotations_screen.dart';
import '../../features/quotations/presentation/quotation_form_screen.dart';
import '../../features/quotations/presentation/quotation_view_screen.dart';
import '../../features/customers/presentation/customer_form_screen.dart';
import '../../features/customers/presentation/customer_view_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/profile_screen.dart';
import '../../features/settings/presentation/security_screen.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/rol/presentation/roles_screen.dart';
import '../../features/rol/presentation/role_details_screen.dart';
import '../../features/usr/presentation/users_screen.dart';
import '../../features/usr/presentation/user_form_screen.dart';
import '../../features/usr/presentation/user_view_screen.dart';
import '../../features/sales_orders/presentation/sales_orders_screen.dart';
import '../../features/sales_orders/presentation/sales_order_view_screen.dart';
import '../../features/sales_orders/presentation/sales_order_edit_screen.dart';
import '../../features/master_data/presentation/master_data_screen.dart';
import '../../features/bom/presentation/bom_list_screen.dart';
import '../../features/production/presentation/production_order_list_screen.dart';
import '../../features/production/presentation/production_order_create_screen.dart';
import '../../features/production/presentation/production_order_view_screen.dart';
import '../../features/production/presentation/production_board_screen.dart';
import '../../features/production/presentation/production_tracking_screen.dart';
import '../../features/production/presentation/production_tracking_list_screen.dart';
import '../../features/bom/presentation/bom_form_screen.dart';
import '../../features/bom/presentation/bom_view_screen.dart';
import '../../features/production/presentation/production_screen.dart';
import '../../features/job_orders/presentation/job_orders_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/delivery/presentation/delivery_list_screen.dart';
import '../../features/delivery/presentation/delivery_create_screen.dart';
import '../../features/delivery/presentation/delivery_view_screen.dart';
import '../../features/invoices/presentation/invoices_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/finance/presentation/financial_overview_screen.dart';
import '../../features/catalog/presentation/category_list_screen.dart';
import '../../features/catalog/presentation/category_form_screen.dart';
import '../../features/catalog/presentation/category_view_screen.dart';
import '../../features/catalog/presentation/product_form_screen.dart';
import '../../features/catalog/presentation/product_view_screen.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/rbac_provider.dart';
import '../../features/auth/presentation/unauthorized_screen.dart';
import 'permission_guard.dart';
// Placeholder for missing screens

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuth = authState.status == AuthStateStatus.authenticated;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (authState.status == AuthStateStatus.initial) {
        return null; // wait for initial state check
      }

      String getDefaultRoute() {
        final perms = ref.read(rbacProvider).permissions;
        if (perms.contains('DSH.DSH_HOME.VIEW')) return '/dashboard';
        if (perms.contains('DSH.SALES_DSH.VIEW')) return '/sales-dashboard';
        if (perms.contains('MFG.DSH.VIEW')) return '/manufacturing-dashboard';
        if (perms.contains('DLV.DLV_LIST.VIEW')) return '/delivery-dashboard';
        if (perms.contains('CAT.CAT_PROD.VIEW')) return '/catalog';
        if (perms.contains('CUS.CUS_LIST.VIEW')) return '/customers';
        return '/unauthorized'; 
      }

      if (state.matchedLocation == '/') {
        return isAuth ? getDefaultRoute() : '/login';
      }

      if (!isAuth && !isGoingToLogin) {
        return '/login';
      }
      if (isAuth && isGoingToLogin) {
        return getDefaultRoute();
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (context, state) {
          final isAuth = ref.read(authProvider).status == AuthStateStatus.authenticated;
          if (!isAuth) return '/login';
          final perms = ref.read(rbacProvider).permissions;
          if (perms.contains('DSH.DSH_HOME.VIEW')) return '/dashboard';
          if (perms.contains('DSH.SALES_DSH.VIEW')) return '/sales-dashboard';
          if (perms.contains('MFG.DSH.VIEW')) return '/manufacturing-dashboard';
          if (perms.contains('DLV.DLV_LIST.VIEW')) return '/delivery-dashboard';
          if (perms.contains('CAT.CAT_PROD.VIEW')) return '/catalog';
          return '/customers'; 
        },
      ),

      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),

      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: 'DSH.DSH_HOME.VIEW',
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/sales-dashboard',
            name: 'sales_dashboard',
            builder: (context, state) => const SalesDashboardScreen(),
          ),
          GoRoute(
            path: '/manufacturing-dashboard',
            name: 'manufacturing_dashboard',
            builder: (context, state) => const ManufacturingDashboardScreen(),
          ),
          GoRoute(
            path: '/delivery-dashboard',
            name: 'delivery_dashboard',
            builder: (context, state) => const DeliveryDashboardScreen(),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const UserFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => UserFormScreen(id: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => UserViewScreen(id: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/roles',
            builder: (context, state) => const RolesScreen(),
            routes: [
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => RoleDetailsScreen(roleId: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/master-data',
            builder: (context, state) => const MasterDataScreen(),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const PermissionGuard(
              requiredPermission: 'CUS.CUS_LIST.VIEW',
              child: CustomersScreen(),
            ),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CustomerFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => CustomerFormScreen(id: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => CustomerViewScreen(id: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/inquiries',
            name: 'inquiries',
            builder: (context, state) => const InquiriesScreen(),
          ),
          GoRoute(
            path: '/quotations',
            name: 'quotations',
            builder: (context, state) => const QuotationsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const QuotationFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => QuotationFormScreen(id: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => QuotationViewScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/sales-orders',
            name: 'sales_orders',
            builder: (context, state) => const SalesOrdersScreen(),
            routes: [
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => SalesOrderViewScreen(orderId: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => SalesOrderEditScreen(orderId: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/catalog',
            builder: (context, state) => const CatalogScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const ProductFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => ProductFormScreen(id: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => ProductViewScreen(id: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'categories',
                builder: (context, state) => const CategoryListScreen(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const CategoryFormScreen(),
                  ),
                  GoRoute(
                    path: 'edit/:id',
                    builder: (context, state) => CategoryFormScreen(id: state.pathParameters['id']),
                  ),
                  GoRoute(
                    path: 'view/:id',
                    builder: (context, state) => CategoryViewScreen(id: state.pathParameters['id']!),
                  ),
                ],
              ),
            ]
          ),
          GoRoute(
            path: '/bom',
            name: 'bom',
            builder: (context, state) => const BomListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const BomFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) => BomFormScreen(bomId: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => BomViewScreen(bomId: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/production',
            name: 'production',
            builder: (context, state) => const ProductionOrderListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const ProductionOrderCreateScreen(),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => ProductionOrderViewScreen(orderId: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/tracking/board',
            builder: (context, state) => const ProductionBoardScreen(),
          ),
          GoRoute(
            path: '/tracking',
            builder: (context, state) => const ProductionTrackingListScreen(),
          ),
          GoRoute(
            path: '/tracking/view/:id',
            builder: (context, state) => ProductionTrackingScreen(trackingId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/job_orders',
            name: 'job_orders',
            builder: (context, state) => const JobOrdersScreen(),
          ),
          GoRoute(
            path: '/inventory',
            name: 'inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/delivery',
            builder: (context, state) => const DeliveryListScreen(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const DeliveryCreateScreen(),
              ),
              GoRoute(
                path: 'view/:id',
                builder: (context, state) => DeliveryViewScreen(id: state.pathParameters['id']!),
              ),
            ]
          ),
          GoRoute(
            path: '/invoices',
            name: 'invoices',
            builder: (context, state) => const InvoicesScreen(),
          ),
          GoRoute(
            path: '/financial-overview',
            name: 'financial_overview',
            builder: (context, state) => const FinancialOverviewScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                name: 'settings_profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: 'security',
                name: 'settings_security',
                builder: (context, state) => const SecurityScreen(),
              ),
              GoRoute(
                path: 'about',
                name: 'settings_about',
                builder: (context, state) => const AboutScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(child: Text('Building $title...', style: Theme.of(context).textTheme.headlineMedium)),
    );
  }
}
