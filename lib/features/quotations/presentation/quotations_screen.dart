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
                      final cusName = q.customer != null ? q.customer!['first_name'] : '';
                      return q.id.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                             cusName.toString().toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();

                    return ListView(
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            dataTextStyle: theme.textTheme.bodyMedium,
                            dividerThickness: 1,
                            columns: const [
                              DataColumn(label: Text('Quote ID')),
                              DataColumn(label: Text('Customer')),
                              DataColumn(label: Text('Date Created')),
                              DataColumn(label: Text('Valid Until')),
                              DataColumn(label: Text('Amount')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('')),
                            ],
                            rows: quotations.map((q) => _buildDataRow(q, theme)).toList(),
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

  DataRow _buildDataRow(QuotationModel quote, ThemeData theme) {
    Color statusColor;
    switch (quote.status) {
      case 'Approved': statusColor = Colors.green; break;
      case 'Converted': statusColor = Colors.teal; break;
      case 'Submitted': statusColor = Colors.blue; break;
      case 'Rejected': statusColor = Colors.red; break;
      default: statusColor = Colors.grey; break; // Draft
    }

    final cusName = quote.customer != null ? "${quote.customer!['first_name']} ${quote.customer!['last_name'] ?? ''}" : 'Unknown';
    final company = quote.customer != null ? (quote.customer!['company_name'] ?? '') : '';

    return DataRow(
      cells: [
        DataCell(Text(quote.id, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary))),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(cusName, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (company.isNotEmpty)
                Text(company, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ),
        DataCell(Text(DateFormat('MMM dd, yyyy').format(quote.dateCreated))),
        DataCell(
          Text(
            DateFormat('MMM dd, yyyy').format(quote.validUntil),
            style: TextStyle(
              color: quote.validUntil.isBefore(DateTime.now()) && quote.status != 'Approved' && quote.status != 'Converted' ? Colors.red : null,
            ),
          ),
        ),
        DataCell(Text('\$${NumberFormat('#,##0.00').format(quote.total)}', style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              quote.status,
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataCell(
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreHorizontal, size: 20),
            onSelected: (value) {
              if (value == 'edit') {
                context.go('/quotations/edit/${quote.id}');
              } else if (value == 'view') {
                context.go('/quotations/view/${quote.id}');
              } else if (value == 'delete') {
                ref.read(quotationApiRepositoryProvider).deleteQuotation(quote.id).then((_) {
                  ref.refresh(quotationsApiProvider);
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'view', child: Text('View Details')),
              if (quote.status == 'Draft' || quote.status == 'Rejected')
                const PopupMenuItem(value: 'edit', child: Text('Edit Quotation')),
              if (quote.status == 'Draft' || quote.status == 'Rejected')
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          )
        ),
      ],
    );
  }
}
