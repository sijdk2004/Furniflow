import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/format_helper.dart';
import '../data/quotation_api_provider.dart';

class QuotationViewScreen extends ConsumerWidget {
  final String id;
  const QuotationViewScreen({super.key, required this.id});

  void _updateStatus(BuildContext context, WidgetRef ref, String newStatus) async {
    try {
      await ref.read(quotationApiRepositoryProvider).updateStatus(id, newStatus);
      ref.refresh(quotationsApiProvider);
      if (mounted(context)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $newStatus')));
        context.go('/quotations');
      }
    } catch (e) {
      if (mounted(context)) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  bool mounted(BuildContext context) => context.mounted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Quotation $id'),
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft), onPressed: () => context.go('/quotations')),
      ),
      body: FutureBuilder(
        future: ref.read(quotationApiRepositoryProvider).getQuotation(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          
          final q = snapshot.data!;
          final cusName = q.customer != null ? "${q.customer!['name'] ?? 'Unknown'}" : 'Unknown';
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (q.quotationNumber != null && q.quotationNumber!.isNotEmpty)
                          Text('Quotation No: ${q.quotationNumber}', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
                        Text('Customer: $cusName', style: theme.textTheme.titleLarge),
                        if (q.salesPerson != null && q.salesPerson!.isNotEmpty)
                          Text('Sales Person: ${q.salesPerson}', style: theme.textTheme.titleMedium?.copyWith(color: Colors.blueGrey)),
                        Text('Valid Until: ${FormatHelper.formatDate(q.validUntil)}', style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
                          child: Text('Status: ${q.status}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        if (q.status != 'Converted') const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Text('Workflow Actions:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ),
                        if (q.status == 'Draft') ...[
                          ElevatedButton(onPressed: () => _updateStatus(context, ref, 'Submitted'), child: const Text('Submit')),
                        ],
                        if (q.status == 'Submitted') ...[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            onPressed: () => _updateStatus(context, ref, 'Approved'), child: const Text('Approve')
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            onPressed: () => _updateStatus(context, ref, 'Rejected'), child: const Text('Reject')
                          ),
                        ],
                        if (q.status == 'Approved') ...[
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white),
                            onPressed: () => _updateStatus(context, ref, 'Converted'), 
                            icon: const Icon(LucideIcons.fileCheck2, size: 18),
                            label: const Text('Convert to Sales Order')
                          ),
                        ],
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Line Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 16),
                        Table(
                          border: TableBorder.all(color: Colors.grey[300]!),
                          children: [
                            TableRow(
                              decoration: BoxDecoration(color: Colors.grey[100]),
                              children: const [
                                Padding(padding: EdgeInsets.all(8), child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.all(8), child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.all(8), child: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.bold))),
                                Padding(padding: EdgeInsets.all(8), child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                              ]
                            ),
                            ...q.items.map((i) => TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (i.productCode != null)
                                        Text(i.productCode!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                      Text(
                                        i.productName ?? i.productId,
                                        style: TextStyle(fontSize: i.productName != null ? 13 : 11, color: i.productName != null ? null : Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(padding: const EdgeInsets.all(8), child: Text(i.quantity.toString())),
                                Padding(padding: const EdgeInsets.all(8), child: Text(FormatHelper.formatCurrency(i.unitPrice))),
                                Padding(padding: const EdgeInsets.all(8), child: Text(FormatHelper.formatCurrency((i.totalPrice ?? 0.0)))),
                              ]
                            ))
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Subtotal: ${FormatHelper.formatCurrency(q.subtotal)}'),
                                Text('Discount: ${FormatHelper.formatCurrency(q.discount)}'),
                                Text('Tax: ${FormatHelper.formatCurrency(q.tax)}'),
                                const SizedBox(height: 8),
                                Text('Total: ${FormatHelper.formatCurrency(q.total)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                Text('Advance: ${FormatHelper.formatCurrency(q.advanceAmount)}', style: TextStyle(color: Colors.green[700])),
                                const SizedBox(height: 4),
                                Text('Balance: ${FormatHelper.formatCurrency(q.balanceAmount)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  )
                )
              ],
            ),
          );
        }
      )
    );
  }
}
