import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../data/invoice_providers.dart';
import '../domain/invoice_model.dart';
import '../../../core/utils/shared_dialogs.dart';
import '../../../core/presentation/widgets/searchable_dropdown.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allInvoices = ref.watch(invoicesProvider);
    final invoices = allInvoices.where((i) => 
      i.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
      i.salesOrderId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      i.id.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

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
                    Text('Invoices', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Manage billing and payment tracking', style: theme.textTheme.bodyMedium),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showNewInvoiceDialog(context),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Create Invoice'),
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
                        hintText: 'Search by Customer, Order ID or Invoice ID...',
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
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
              itemCount: invoices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return _buildInvoiceCard(invoice, theme).animate().fade(delay: (50 * index).ms).slideX(begin: 0.1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice, ThemeData theme) {
    return Card(
      child: InkWell(
        onTap: () => _showInvoiceDetailsDialog(context, invoice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: invoice.status == 'Overdue' 
                              ? Colors.red.withValues(alpha: 0.1) 
                              : theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.fileSpreadsheet, 
                          color: invoice.status == 'Overdue' ? Colors.red : theme.colorScheme.primary, 
                          size: 20
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(invoice.customerName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${invoice.id} • ${invoice.salesOrderId}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  _buildStatusBadge(invoice.status),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn('Issue Date', DateFormat('MMM dd, yyyy').format(invoice.issueDate), theme),
                  _buildInfoColumn('Due Date', DateFormat('MMM dd, yyyy').format(invoice.dueDate), theme, isRed: invoice.status == 'Overdue'),
                  _buildInfoColumn('Total Amount', '₹${invoice.total.toStringAsFixed(2)}', theme, isBold: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, ThemeData theme, {bool isRed = false, bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: isRed ? Colors.red : null,
          fontSize: isBold ? 16 : null,
        )),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Paid': color = Colors.teal; break;
      case 'Sent': color = Colors.blue; break;
      case 'Overdue': color = Colors.red; break;
      default: color = Colors.grey; break; // Draft
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showNewInvoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Invoice'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SearchableDropdown<String>(
                label: 'Select Customer',
                items: const ['Sarah Jenkins', 'Michael Chang', 'Emma Watson'],
                itemAsString: (e) => e,
                onChanged: (v) {},
              ),
              const SizedBox(height: 16),
              SearchableDropdown<String>(
                label: 'Select Sales Order',
                items: const ['SO-24-1029', 'SO-24-1030', 'SO-24-1031'],
                itemAsString: (e) => e,
                onChanged: (v) {},
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Issue Date', prefixIcon: Icon(LucideIcons.calendar)))),
                  const SizedBox(width: 16),
                  Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Due Date', prefixIcon: Icon(LucideIcons.calendar)))),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Create Draft')),
        ],
      ),
    );
  }

  void _showInvoiceDetailsDialog(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Invoice: ${invoice.id}'),
            _buildStatusBadge(invoice.status),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Billed To', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(invoice.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Sales Order: ${invoice.salesOrderId}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Amount Due', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('₹${invoice.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Line Items', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 3, child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 1, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                          Expanded(flex: 1, child: Text('Unit Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.right)),
                          Expanded(flex: 1, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                    ...invoice.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(item.description)),
                          Expanded(flex: 1, child: Text('${item.quantity}', textAlign: TextAlign.center)),
                          Expanded(flex: 1, child: Text('₹${item.unitPrice.toStringAsFixed(2)}', textAlign: TextAlign.right)),
                          Expanded(flex: 1, child: Text('₹${item.total.toStringAsFixed(2)}', textAlign: TextAlign.right)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Subtotal: ₹${invoice.subtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text('Tax (10%): ₹${invoice.tax.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          if (invoice.status == 'Draft')
            ElevatedButton.icon(
              onPressed: () {
                ref.read(invoicesProvider.notifier).updateStatus(invoice.id, 'Sent');
                Navigator.pop(context);
              },
              icon: const Icon(LucideIcons.send, size: 16), 
              label: const Text('Send to Customer'),
            )
          else if (invoice.status == 'Sent' || invoice.status == 'Overdue')
            ElevatedButton.icon(
              onPressed: () {
                ref.read(invoicesProvider.notifier).updateStatus(invoice.id, 'Paid');
                Navigator.pop(context);
              },
              icon: const Icon(LucideIcons.checkCircle, size: 16), 
              label: const Text('Mark as Paid'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            )
        ],
      ),
    );
  }
}
