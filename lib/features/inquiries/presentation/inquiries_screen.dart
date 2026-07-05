import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/utils/format_helper.dart';
import '../data/inquiry_providers.dart';
import '../domain/inquiry_model.dart';
import '../../../core/utils/shared_dialogs.dart';
import '../../../core/presentation/widgets/searchable_dropdown.dart';

class InquiriesScreen extends ConsumerStatefulWidget {
  const InquiriesScreen({super.key});

  @override
  ConsumerState<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends ConsumerState<InquiriesScreen> {
  final List<String> _statuses = ['New', 'Reviewed', 'Qualified', 'Waiting', 'Closed'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inquiries = ref.watch(inquiriesProvider);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inquiries', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Manage customer requests and leads', style: theme.textTheme.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showNewInquiryDialog(context),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('New Inquiry'),
                ),
              ],
            ).animate().fade().slideY(begin: -0.2),
          ),
          
          // Kanban Board
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _statuses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final status = entry.value;
                  final columnInquiries = inquiries.where((i) => i.status == status).toList();
                  
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    status,
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${columnInquiries.length}',
                                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: columnInquiries.length,
                              itemBuilder: (context, iIndex) {
                                return _buildKanbanCard(columnInquiries[iIndex], theme)
                                    .animate()
                                    .fade(delay: (100 * iIndex).ms)
                                    .slideY(begin: 0.1);
                              },
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: (50 * index).ms).slideX(begin: 0.1),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildKanbanCard(Inquiry inquiry, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: () => _showInquiryDetailsDialog(context, inquiry),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  inquiry.id,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  FormatHelper.formatDate(inquiry.dateReceived),
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              inquiry.subject,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(LucideIcons.building, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    inquiry.company,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        inquiry.customerName[0],
                        style: TextStyle(color: theme.colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(inquiry.customerName.split(' ').first, style: theme.textTheme.bodySmall),
                  ],
                ),
                Text(
                  FormatHelper.formatCurrency(inquiry.estimatedValue),
                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showInquiryDetailsDialog(BuildContext context, Inquiry inquiry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Inquiry: ${inquiry.id}'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(inquiry.status, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(inquiry.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDetailRow('Company', inquiry.company)),
                  Expanded(child: _buildDetailRow('Contact', inquiry.customerName)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildDetailRow('Received', FormatHelper.formatDate(inquiry.dateReceived))),
                  Expanded(child: _buildDetailRow('Est. Value', FormatHelper.formatCurrency(inquiry.estimatedValue))),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Notes / Requirements', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Customer requested specific dimensions and material alternatives. Needs follow up by end of week.'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context), 
            icon: const Icon(LucideIcons.edit, size: 16), 
            label: const Text('Edit Inquiry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  void _showNewInquiryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log New Inquiry'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(decoration: const InputDecoration(labelText: 'Inquiry Subject / Title')),
              const SizedBox(height: 16),
              SearchableDropdown<String>(
                label: 'Customer / Lead',
                items: const ['Jenkins Interiors', 'Chang Furniture', 'New Lead...'],
                itemAsString: (e) => e,
                onChanged: (v) {},
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Estimated Value (₹)'))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SearchableDropdown<String>(
                      label: 'Priority',
                      items: const ['High', 'Medium', 'Low'],
                      itemAsString: (e) => e,
                      onChanged: (v) {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes / Requirements', alignLabelWithHint: true),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save Inquiry')),
        ],
      ),
    );
  }
}
