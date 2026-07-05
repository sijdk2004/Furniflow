import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../../../../main.dart';
import '../../notifications/presentation/notification_drawer.dart';
import '../../ai_assistant/presentation/ai_assistant_panel.dart';
import '../../auth/presentation/auth_provider.dart';
import '../presentation/menu_provider.dart';
import '../../settings/data/settings_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Widget? _currentEndDrawer;
  
  final Map<String, bool> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(menuProvider.notifier).loadMenusForRole();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _currentEndDrawer,
      appBar: isDesktop
          ? _buildTopNavigation(context, theme)
          : AppBar(
              leading: IconButton(
                icon: const Icon(LucideIcons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: const Text('FurniFlow'),
              actions: _buildAppBarActions(),
            ),
      drawer: isDesktop ? null : _buildDrawer(context, theme),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context, theme),
          if (isDesktop) const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTopNavigation(BuildContext context, ThemeData theme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Text(
              'FurniFlow',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 48),
            // Global Search
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: TextField(
                  readOnly: true,
                  onTap: () => _showCommandPaletteDialog(context),
                  decoration: InputDecoration(
                    hintText: 'Search anywhere (Cmd+K)...',
                    prefixIcon: const Icon(LucideIcons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
            const Spacer(),
            ..._buildAppBarActions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    final theme = Theme.of(context);
    return [
      IconButton(
        icon: const Icon(LucideIcons.user),
        onPressed: () => _showProfileDialog(context),
      ),
    ];
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    return Drawer(
      child: _buildSidebarContent(context, theme),
    );
  }

  Widget _buildSidebar(BuildContext context, ThemeData theme) {
    return Material(
      color: theme.colorScheme.surface,
      child: SizedBox(
        width: 260,
        child: _buildSidebarContent(context, theme),
      ),
    );
  }

  Widget _buildSidebarContent(BuildContext context, ThemeData theme) {
    final menus = ref.watch(menuProvider);
    final currentPath = GoRouterState.of(context).uri.path;

    // Group the menus by their group property
    final groupedMenus = groupBy(menus, (MenuItem m) => m.group);
    
    // Sort groups according to requirement
    final groupOrder = ['Dashboards', 'Sales', 'Manufacturing', 'Logistics', 'Administration', 'Other'];
    final sortedGroups = groupedMenus.keys.toList()
      ..sort((a, b) {
        int indexA = groupOrder.indexOf(a);
        int indexB = groupOrder.indexOf(b);
        if (indexA == -1) indexA = 999;
        if (indexB == -1) indexB = 999;
        return indexA.compareTo(indexB);
      });

    return Column(
      children: [
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _buildSectionTitle('MAIN MENU'),
              for (final group in sortedGroups)
                _buildMenuGroup(context, theme, group, groupedMenus[group]!, currentPath),
            ],
          ),
        ),
        const Divider(),
        _buildNavItem(context, 'Settings', LucideIcons.settings, '/settings', currentPath),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ListTile(
            leading: const Icon(LucideIcons.logOut, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ),
      ],
    );
  }

  IconData _getGroupIcon(String groupName) {
    switch (groupName) {
      case 'Dashboards': return LucideIcons.layoutDashboard;
      case 'Sales': return LucideIcons.briefcase;
      case 'Manufacturing': return LucideIcons.factory;
      case 'Logistics': return LucideIcons.truck;
      case 'Administration': return LucideIcons.settings;
      default: return LucideIcons.layers;
    }
  }

  Widget _buildMenuGroup(BuildContext context, ThemeData theme, String groupName, List<MenuItem> items, String currentPath) {
    // Check if any child is currently active
    final hasActiveChild = items.any((m) {
      final path = m.route;
      return currentPath == path || (path != '/' && currentPath.startsWith(path) && !currentPath.startsWith('\$path/'));
    });

    // If active and not explicitly collapsed, auto-expand it
    if (hasActiveChild && !_expandedGroups.containsKey(groupName)) {
      _expandedGroups[groupName] = true;
    }
    
    final isExpanded = _expandedGroups[groupName] ?? false;

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: Key('$groupName-$isExpanded'),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              _expandedGroups.forEach((k, v) => _expandedGroups[k] = false);
            }
            _expandedGroups[groupName] = expanded;
          });
        },
        leading: Icon(_getGroupIcon(groupName), color: hasActiveChild ? theme.colorScheme.primary : theme.iconTheme.color, size: 20),
        title: Text(
          groupName,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: hasActiveChild ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: hasActiveChild ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.only(left: 24),
        children: () {
          final sortedItems = List<MenuItem>.from(items);
          if (groupName == 'Dashboards') {
            sortedItems.sort((a, b) {
              if (a.title == 'CEO Dashboard') return -1;
              if (b.title == 'CEO Dashboard') return 1;
              return 0; // maintain original order for others
            });
          }
          return sortedItems.map((m) => _buildNavItem(context, m.title, _getIcon(m.icon), m.route, currentPath)).toList();
        }(),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'dashboard': return LucideIcons.layoutDashboard;
      case 'barChart': return LucideIcons.barChart2;
      case 'business': return LucideIcons.building2;
      case 'settings': return LucideIcons.settings;
      case 'users': return LucideIcons.users;
      case 'box': return LucideIcons.box;
      case 'truck': return LucideIcons.truck;
      case 'factory': return LucideIcons.factory;
      default: return LucideIcons.circle;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, String path, String currentPath) {
    // Exact match OR the current path starts with this path AND no longer/more-specific menu item matches.
    // We use exact match first; fall back to prefix only when path is NOT a prefix of another menu item
    // that is itself selected. This prevents /tracking matching when /tracking/board is active.
    final isSelected = currentPath == path ||
        (path != '/' && currentPath.startsWith(path) && !currentPath.startsWith('$path/'));
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.iconTheme.color, size: 20),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          context.go(path);
          if (_scaffoldKey.currentState?.isDrawerOpen == true) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Profile'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final profileAsync = ref.watch(profileProvider);
                  return profileAsync.when(
                    data: (user) {
                      final lastNameStr = user.lastName ?? '';
                      final departmentStr = user.department ?? '';
                      
                      final initials = '${user.firstName.isNotEmpty ? user.firstName[0] : ''}${lastNameStr.isNotEmpty ? lastNameStr[0] : ''}'.toUpperCase();
                      final fullName = '${user.firstName} $lastNameStr'.trim();
                      return Column(
                        children: [
                          CircleAvatar(radius: 40, backgroundColor: Colors.blue, child: Text(initials.isEmpty ? 'U' : initials, style: const TextStyle(fontSize: 24, color: Colors.white))),
                          const SizedBox(height: 16),
                          Text(fullName.isEmpty ? 'User' : fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(user.email, style: const TextStyle(color: Colors.grey)),
                          const Divider(height: 32),
                          if (departmentStr.isNotEmpty)
                            ListTile(leading: const Icon(LucideIcons.building), title: const Text('Department'), subtitle: Text(departmentStr)),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
                    ),
                  );
                },
              ),
              const Divider(),
              Consumer(
                builder: (context, ref, child) {
                  final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle dark/light theme'),
                    value: isDarkMode,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).toggle(val);
                    },
                    secondary: const Icon(LucideIcons.moon),
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () {
            Navigator.pop(context);
            context.go('/settings/profile');
          }, child: const Text('View Profile')),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Settings'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Toggle dark/light theme'),
                    value: isDarkMode,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).toggle(val);
                    },
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive alerts for order updates'),
                value: true,
                onChanged: (val) {},
              ),
              SwitchListTile(
                title: const Text('Email Summaries'),
                subtitle: const Text('Daily digest of production metrics'),
                value: true,
                onChanged: (val) {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(LucideIcons.globe),
                title: const Text('Language'),
                trailing: const Text('English (US)'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(LucideIcons.shield),
                title: const Text('Security & Privacy'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save Changes')),
        ],
      ),
    );
  }

  void _showCommandPaletteDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.only(top: 100, left: 16, right: 16),
        alignment: Alignment.topCenter,
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, spreadRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search commands, orders, customers...',
                    prefixIcon: const Icon(LucideIcons.search, size: 24),
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: TextStyle(fontSize: 18, color: Colors.grey.shade500),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildCommandSection('QUICK ACTIONS', theme),
                    _buildCommandItem(LucideIcons.plusCircle, 'Create New Sales Order', 'Sales > New', theme, context),
                    _buildCommandItem(LucideIcons.fileSignature, 'Approve Q1 Discount Request', 'Approvals', theme, context, isHighlight: true),
                    _buildCommandItem(LucideIcons.truck, 'View Delayed Deliveries', 'Logistics', theme, context),
                    
                    _buildCommandSection('RECENT SEARCHES', theme),
                    _buildCommandItem(LucideIcons.history, 'ORD-1042', 'Order', theme, context),
                    _buildCommandItem(LucideIcons.history, 'Acme Corp', 'Customer', theme, context),
                    
                    _buildCommandSection('SUGGESTED ANALYTICS', theme),
                    _buildCommandItem(LucideIcons.barChart3, 'Show Q3 Revenue Forecast', 'AI Suggestion', theme, context),
                    _buildCommandItem(LucideIcons.pieChart, 'Inventory Valuation by Category', 'Report', theme, context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommandSection(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCommandItem(IconData icon, String title, String subtitle, ThemeData theme, BuildContext context, {bool isHighlight = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: isHighlight ? theme.colorScheme.primary : theme.iconTheme.color?.withOpacity(0.7)),
      title: Text(title, style: TextStyle(fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500, color: isHighlight ? theme.colorScheme.primary : theme.colorScheme.onSurface)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
        child: Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
      ),
      hoverColor: theme.colorScheme.primary.withOpacity(0.05),
      onTap: () => Navigator.pop(context),
    );
  }
}
