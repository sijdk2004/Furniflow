import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationDrawer extends StatefulWidget {
  final VoidCallback onClose;
  const NotificationDrawer({super.key, required this.onClose});

  @override
  State<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final String type; // 'approval', 'alert', 'info', 'success'
  final bool isUnread;

  _NotificationItem(this.id, this.title, this.message, this.time, this.type, this.isUnread);
}

class _NotificationDrawerState extends State<NotificationDrawer> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Unread', 'Approvals', 'Alerts'];

  final List<_NotificationItem> _notifications = [
    _NotificationItem('1', 'Quotation Approved', 'Q-2023-089 has been approved by management.', '10 mins ago', 'success', true),
    _NotificationItem('2', 'Order Delayed', 'Production for SO-1029 is delayed due to material shortage.', '1 hour ago', 'alert', true),
    _NotificationItem('3', 'Inventory Shortage', 'Oak Wood Panels are below minimum stock level.', '2 hours ago', 'alert', true),
    _NotificationItem('4', 'Production Completed', 'Job Order JO-5092 (Sofa Set) is ready for delivery.', '4 hours ago', 'success', false),
    _NotificationItem('5', 'Invoice Overdue', 'Invoice INV-2023-041 is 5 days overdue.', '1 day ago', 'alert', false),
    _NotificationItem('6', 'Discount Request', 'Pending discount approval for Acme Corp (15%).', '1 day ago', 'approval', false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _notifications.where((n) {
      if (_selectedFilter == 'Unread') return n.isUnread;
      if (_selectedFilter == 'Approvals') return n.type == 'approval';
      if (_selectedFilter == 'Alerts') return n.type == 'alert';
      return true;
    }).toList();

    return Container(
      width: 400,
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            _buildFilters(theme),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) => _buildNotificationTile(filtered[index], theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final unreadCount = _notifications.where((n) => n.isUnread).length;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('Notifications', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                  child: Text('$unreadCount New', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          IconButton(icon: const Icon(LucideIcons.x), onPressed: widget.onClose),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = filter),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? theme.colorScheme.primary : Colors.transparent),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationTile(_NotificationItem item, ThemeData theme) {
    IconData icon;
    Color color;

    switch (item.type) {
      case 'success':
        icon = LucideIcons.checkCircle2;
        color = Colors.green;
        break;
      case 'alert':
        icon = LucideIcons.alertTriangle;
        color = Colors.red;
        break;
      case 'approval':
        icon = LucideIcons.clipboardSignature;
        color = Colors.orange;
        break;
      default:
        icon = LucideIcons.info;
        color = Colors.blue;
    }

    return Container(
      color: item.isUnread ? theme.colorScheme.primary.withOpacity(0.05) : Colors.transparent,
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                    Text(item.time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(item.message, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
                if (item.type == 'approval') ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), minimumSize: Size.zero),
                        child: const Text('Review', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (item.isUnread) ...[
            const SizedBox(width: 12),
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
          ],
        ],
      ),
    );
  }
}
