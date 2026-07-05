import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../data/quotation_api_provider.dart';
import '../domain/quotation_model_api.dart';
import '../../../core/utils/shared_dialogs.dart';

class QuotationsScreen extends ConsumerStatefulWidget {
  const QuotationsScreen({super.key});

  @override
  ConsumerState<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends ConsumerState<QuotationsScreen> {
  String _searchQuery = '';

  String _formatQuoteId(String id) {
    int hash = id.hashCode.abs();
    String numStr = hash.toString().padLeft(8, '0');
    if (numStr.length > 8) numStr = numStr.substring(0, 8);
    return numStr;
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    switch (status) {
      case 'Approved': statusColor = Colors.green; break;
      case 'Converted': statusColor = Colors.teal; break;
      case 'Submitted': statusColor = Colors.blue; break;
      case 'Rejected': statusColor = Colors.red; break;
      default: statusColor = Colors.grey; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quotationsFuture = ref.watch(quotationsApiProvider);

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
                    Text('Quotations', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Manage price quotes and proposals', style: theme.textTheme.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/quotations/create'),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Create Quote'),
                ),
              ],
            ).animate().fade().slideY(begin: -0.2),
          ),

          // Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Search by Quote ID or Customer...',
                        prefixIcon: Icon(LucideIcons.search, size: 20),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => SharedDialogs.showFilterDialog(context),
                  icon: const Icon(LucideIcons.filter, size: 18),
                  label: const Text('Filter'),
                ),
              ],
            ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
          ),

          const SizedBox(height: 24),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                child: quotationsFuture.when(
                  data: (data) {
                    final quotations = data.where((q) {
                      final cusName = q.customer != null ? (q.customer!['name'] ?? '') : '';
                      final displayId = _formatQuoteId(q.id);
                      return q.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          displayId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          cusName.toString().toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();

                    return Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              _headerCell('Quote ID', flex: 2),
                              _headerCell('Customer', flex: 3),
                              _headerCell('Date Created', flex: 2),
                              _headerCell('Valid Until', flex: 2),
                              _headerCell('Amount', flex: 2),
                              _headerCell('Status', flex: 2),
                              _headerCell('', flex: 1),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // Table Rows
                        Expanded(
                          child: quotations.isEmpty
                              ? const Center(child: Text('No quotations found'))
                              : ListView.separated(
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemCount: quotations.length,
                                  itemBuilder: (context, i) {
                                    final q = quotations[i];
                                    final cusName = q.customer != null ? (q.customer!['name'] ?? 'Unknown') : 'Unknown';
                                    final cusEmail = q.customer != null ? (q.customer!['email'] ?? '') : '';
                                    final isExpired = q.validUntil.isBefore(DateTime.now()) &&
                                        q.status != 'Approved' && q.status != 'Converted';

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              _formatQuoteId(q.id),
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  cusName,
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (cusEmail.isNotEmpty)
                                                  Text(
                                                    cusEmail,
                                                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              DateFormat('MMM dd, yyyy').format(q.dateCreated),
                                              style: theme.textTheme.bodyMedium,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              DateFormat('MMM dd, yyyy').format(q.validUntil),
                                              style: TextStyle(
                                                color: isExpired ? Colors.red : null,
                                                fontSize: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '\$${NumberFormat('#,##0.00').format(q.total)}',
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: _buildStatusBadge(q.status),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: PopupMenuButton<String>(
                                              icon: const Icon(LucideIcons.moreHorizontal, size: 18),
                                              onSelected: (value) async {
                                                if (value == 'edit') {
                                                  context.go('/quotations/edit/${q.id}');
                                                } else if (value == 'view') {
                                                  context.go('/quotations/view/${q.id}');
                                                } else if (value == 'delete') {
                                                  final confirmed = await SharedDialogs.showDeleteConfirmation(context, itemName: 'quotation');
                                                  if (confirmed == true) {
                                                    try {
                                                      await ref.read(quotationApiRepositoryProvider).deleteQuotation(q.id);
                                                      ref.refresh(quotationsApiProvider);
                                                      if (context.mounted) {
                                                        SharedDialogs.showSuccessSnackbar(context, 'Quotation deleted successfully');
                                                      }
                                                    } catch (e) {
                                                      if (context.mounted) {
                                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                                      }
                                                    }
                                                  }
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(value: 'view', child: Text('View Details')),
                                                if (q.status == 'Draft' || q.status == 'Rejected')
                                                  const PopupMenuItem(value: 'edit', child: Text('Edit Quotation')),
                                                if (q.status == 'Draft' || q.status == 'Rejected')
                                                  const PopupMenuItem(
                                                    value: 'delete',
                                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error loading quotations: $e')),
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
